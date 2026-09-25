import 'package:project_camp_sewa/services/api_client.dart';
// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/detail_produk_model.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/models/variant_model.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiProduk extends GetxController {
  Dio dio = ApiClient().dio;
  final RxList<ProdukModel> listProdukRekomendasi = <ProdukModel>[].obs;
  final RxList<ProdukModel> listProduk = <ProdukModel>[].obs;
  // Separate list for home featured products (uses rekomendasi endpoint
  // which does NOT exclude the logged-in user's own products).
  final RxList<ProdukModel> listProdukHome = <ProdukModel>[].obs;
  final RxBool isLoadingHome = true.obs;
  final RxList<ProdukModel> listUserProduk = <ProdukModel>[].obs;
  final RxBool isLoadingUserProducts = true.obs;
  final Rx<DetailProdukModel?> detailProduk = Rx<DetailProdukModel?>(null);
  var groupedByColor = <String, List<Map<String, dynamic>>>{}.obs;
  var uniqueSizes = <String>[].obs;
  var colors = <String>[].obs;
  var imageDetailProduk = <String>[].obs;
  final RxList<String> listKategori = <String>[].obs;

  Future<void> getProdukRekomendasiPencarian(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.getProdukRekomendasiPencarian;

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        var rawData = data['data_rekomendasi'] ?? data['data'] ?? [];
        List<ProdukModel> produkList = List<ProdukModel>.from(
            rawData.map((e) => ProdukModel.fromJson(e)).toList());
        listProdukRekomendasi.assignAll(produkList);
      } else if (response.statusCode == 404) {
        listProdukRekomendasi.clear();
      } else {
        listProdukRekomendasi.clear();
      }
    } catch (error) {
      String msg = "Gagal memuat produk";
      if (error is DioException)
        msg = error.message ?? msg;
      else
        msg = error.toString();
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: msg,
                ),
              );
            });
      }
    }
  }

  /// Fetch products for the Home featured section.
  /// Uses the rekomendasi endpoint which shows all products regardless of
  /// whether they belong to the logged-in user.
  Future<void> getFeaturedProduk(BuildContext context) async {
    isLoadingHome.value = true;
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.getProdukRekomendasiPencarian;

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500;
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        var rawData = data['data_rekomendasi'] ?? data['data'] ?? [];
        List<ProdukModel> produkList = List<ProdukModel>.from(
            rawData.map((e) => ProdukModel.fromJson(e)).toList());
        listProdukHome.assignAll(produkList);
      } else {
        listProdukHome.clear();
      }
    } catch (error) {
      String msg = "Gagal memuat produk";
      if (error is DioException)
        msg = error.message ?? msg;
      else
        msg = error.toString();
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: msg,
                ),
              );
            });
      }
    } finally {
      isLoadingHome.value = false;
    }
  }

  Future<void> getProduk(
      BuildContext context, String? search, String? filter) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getProduk}";

      // Buat query parameters
      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      // Tambahkan query parameters ke URL jika ada
      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        var rawData = data['data'] ?? data['data_produk'] ?? [];
        List<ProdukModel> produkList = List<ProdukModel>.from(
            rawData.map((e) => ProdukModel.fromJson(e)).toList());
        listProduk.assignAll(produkList);
      } else if (response.statusCode == 404) {
        listProduk.clear();
      } else {
        listProduk.clear();
      }
    } catch (error) {
      String msg = "Gagal memuat produk";
      if (error is DioException)
        msg = error.message ?? msg;
      else
        msg = error.toString();
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: msg,
                ),
              );
            });
      }
    }
  }

  Future<void> getUserProducts(BuildContext context, {String? filter}) async {
    isLoadingUserProducts.value = true;
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getUserProducts}";

      Map<String, String> queryParams = {};
      if (filter != null && filter.isNotEmpty && filter != 'Semua') {
        queryParams['filter'] = filter;
      }
      
      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        var rawData = data['data'] ?? [];
        List<ProdukModel> produkList = List<ProdukModel>.from(
            rawData.map((e) => ProdukModel.fromJson(e)).toList());
        listUserProduk.assignAll(produkList);
      } else if (response.statusCode == 404) {
        listUserProduk.clear();
      } else {
        listUserProduk.clear();
      }
    } catch (error) {
      String msg = "Gagal memuat produk";
      if (error is DioException)
        msg = error.message ?? msg;
      else
        msg = error.toString();
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: msg,
                ),
              );
            });
      }
    } finally {
      isLoadingUserProducts.value = false;
    }
  }

  Future<void> getProdukBottomSheet(BuildContext context, String? warna,
      String? ukuran, String idBarang) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getProdukBottomSheet}$idBarang";

      // Buat query parameters
      Map<String, String> queryParams = {};
      if (warna != null && warna.isNotEmpty) {
        queryParams['warna'] = warna;
      }
      if (ukuran != null && ukuran.isNotEmpty) {
        queryParams['ukuran'] = ukuran;
      }

      // Tambahkan query parameters ke URL jika ada
      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        List<VariantProductModel> variants = (data['all_variants'] as List)
            .map((variantJson) => VariantProductModel.fromJson(
                variantJson as Map<String, dynamic>))
            .toList();

        groupedByColor.clear();

        for (var variant in variants) {
          if (!groupedByColor.containsKey(variant.warna)) {
            groupedByColor[variant.warna] = [];
          }
          groupedByColor[variant.warna]!.add({
            'ukuran': variant.ukuran,
            'stok': variant.stok,
            'harga': variant.hargaSewa
          });
        }

        updateAllUniqueSizes();
        updateColors();
      } else {
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: "Data Produk Gagal Dimuat",
        );
      }
    } catch (error) {
      String msg = "Gagal memuat produk";
      if (error is DioException)
        msg = error.message ?? msg;
      else
        msg = error.toString();
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: msg,
                ),
              );
            });
      }
    }
  }

  void updateAllUniqueSizes({String? color}) {
    Set<String> uniqueSizesSet = {};

    if (color == null) {
      groupedByColor.forEach((color, variants) {
        for (var variant in variants) {
          uniqueSizesSet.add(variant['ukuran']);
        }
      });
    } else {
      if (groupedByColor.containsKey(color)) {
        for (var variant in groupedByColor[color]!) {
          uniqueSizesSet.add(variant['ukuran']);
        }
      }
    }

    // Update uniqueSizes RxList
    uniqueSizes.assignAll(uniqueSizesSet.toList());
  }

  void updateColors() {
    colors.assignAll(groupedByColor.keys.toList());
  }

  Map<String, dynamic>? getStockAndPrice(String color, String size) {
    if (groupedByColor.containsKey(color)) {
      for (var variant in groupedByColor[color]!) {
        if (variant['ukuran'] == size) {
          return {'stok': variant['stok'], 'harga': variant['harga']};
        }
      }
    }
    return null;
  }

  Future<void> getDetailProduk(BuildContext context, String idBarang) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getDetailProduk}$idBarang";

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        var detailData = data['detail_produk'];
        if (detailData is List && detailData.isNotEmpty)
          detailData = detailData[0];
        detailProduk.value = DetailProdukModel.fromJson(detailData);

        if (data['detail_produk'] != null) {
          List<String> rawImages = [];
          if (detailProduk.value!.fotoDepan.isNotEmpty) {
            rawImages.add(detailProduk.value!.fotoDepan);
          }

          if (detailProduk.value!.fotoArray.isNotEmpty) {
            rawImages.addAll(detailProduk.value!.fotoArray);
          }
          
          // Deduplicate by filename
          List<String> uniqueImages = [];
          for (var img in rawImages) {
            String filename = img.split('/').last;
            if (!uniqueImages.any((e) => e.split('/').last == filename)) {
              uniqueImages.add(img);
            }
          }
          rawImages = uniqueImages;

          imageDetailProduk.assignAll(rawImages
              .map((url) {
                if (url.startsWith('[') && url.endsWith(']')) {
                  return url
                      .replaceAll(RegExp(r'[\[\]\"]'), '')
                      .split(',')
                      .first;
                }
                return url;
              })
              .where((url) => url.isNotEmpty)
              .toList());
        } else {
          detailProduk.value = null;
          imageDetailProduk.clear();
        }
      } else {
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: "Data Produk Gagal Dimuat",
        );
      }
    } catch (error) {
      String msg = "Gagal memuat produk";
      if (error is DioException)
        msg = error.message ?? msg;
      else
        msg = error.toString();
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: msg,
                ),
              );
            });
      }
    }
  }

  Future<void> getListKategori() async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = "${ApiEndpoints.baseUrl}/api/produk/list-kategori";

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) => status! < 500,
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 && data['data'] != null) {
        List<String> kats = List<String>.from(data['data']);
        listKategori.assignAll(kats);
      } else {
        listKategori.clear();
      }
    } catch (e) {
      listKategori.clear();
    }
  }

  Future<Map<String, dynamic>> toggleLike(String idProduk) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Anda harus login untuk menyukai produk'};
      }

      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      var url = "${ApiEndpoints.baseUrl}/api/produk/$idProduk/toggle-like";

      final response = await dio.post(
        url,
        data: {},
        options: Options(
          headers: header,
          validateStatus: (status) => status! < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      print("=== SUCCESS TOGGLE LIKE ===");
      print(data);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Success',
          'is_liked': data['data']?['is_liked'],
          'total_likes': data['data']?['total_likes']
        };
      } else {
        print("\x1B[31m=== FAILED TOGGLE LIKE ===\x1B[0m");
        print("\x1B[31m$data\x1B[0m");
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memproses like produk',
        };
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        print("\x1B[31m=== ERROR TOGGLE LIKE (DIO EXCEPTION) ===\x1B[0m");
        print("\x1B[31mStatus Code: ${e.response?.statusCode}\x1B[0m");
        print("\x1B[31mResponse Data: ${e.response?.data}\x1B[0m");
        print("\x1B[31m=========================================\x1B[0m");
        
        if (e.response != null && e.response!.data != null) {
          try {
            var responseData = e.response!.data;
            if (responseData is Map && responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            } else if (responseData is String) {
              if (responseData.toLowerCase().contains("<!doctype html>")) {
                errorMessage = "Terjadi kesalahan internal server (500). Cek console debug untuk detail lengkapnya.";
              } else {
                errorMessage = responseData;
              }
            }
          } catch (_) {}
        }
      } else {
        print("\x1B[31m=== ERROR TOGGLE LIKE ===\x1B[0m");
        print("\x1B[31m${e.toString()}\x1B[0m");
        print("\x1B[31m=========================\x1B[0m");
      }
      return {
        'success': false,
        'message': 'Gagal: $errorMessage',
      };
    }
  }
}






