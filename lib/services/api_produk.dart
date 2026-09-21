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
  Dio dio = Dio();
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
    } on DioException catch (dioError) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
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
    } on DioException catch (dioError) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
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
    } on DioException catch (dioError) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
                ),
              );
            });
      }
    }
  }

  Future<void> getUserProducts(BuildContext context) async {
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
    } on DioException catch (dioError) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
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
        List<VariantProductModel> variants =
            (data['all_variants'] as List)
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
        CustomSnackBar.show(context, sukses: false,
              teks: "Data Produk Gagal Dimuat",);
      }
    } on DioException catch (dioError) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
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
        detailProduk.value = DetailProdukModel.fromJson(data['detail_produk'][0]);

        if(data['detail_produk'] != null){
          List<String> rawImages = [
            detailProduk.value!.fotoDepan,
            detailProduk.value!.fotoBelakang,
            detailProduk.value!.fotoKiri,
            detailProduk.value!.fotoKanan,
          ];

          if (data['detail_produk'][0]['foto_array'] != null) {
            var additional = (data['detail_produk'][0]['foto_array'] as List)
                .map((e) => e['url'].toString())
                .toList();
            rawImages.addAll(additional);
          }

          imageDetailProduk.assignAll(rawImages.where((url) => 
              url.isNotEmpty && 
              !url.contains('ui-avatars.com') && 
              url != 'Belum di isi'
          ).toList());
        } else {
          detailProduk.value = null;
          imageDetailProduk.clear();
        }
      } else {
        CustomSnackBar.show(context, sukses: false,
              teks: "Data Produk Gagal Dimuat",);
      }
    } on DioException catch (dioError) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
                ),
              );
            });
      }
    }
  }
}

