import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/mitra_diskon_model.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiDiskon extends GetxController {
  final Dio dio = ApiClient().dio;

  final RxList<MitraDiskonModel> listDiskon = <MitraDiskonModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasActiveStoreWide = false.obs;
  final Rx<ActiveStoreWidePromoModel?> activeStoreWide =
      Rx<ActiveStoreWidePromoModel?>(null);

  Future<Map<String, String>> _getHeaders() async {
    final Authorization auth = Authorization();
    final String? token = await auth.getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Mengambil daftar seluruh promo diskon yang pernah dibuat mitra.
  Future<List<MitraDiskonModel>> getDiskonList() async {
    try {
      isLoading.value = true;
      final headers = await _getHeaders();
      final url = ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.mitraDiskon;

      final response = await dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        hasActiveStoreWide.value = data['has_active_store_wide_promo'] == true;
        if (data['active_store_wide_promo'] != null &&
            data['active_store_wide_promo'] is Map) {
          activeStoreWide.value = ActiveStoreWidePromoModel.fromJson(
              Map<String, dynamic>.from(data['active_store_wide_promo'] as Map));
        } else {
          activeStoreWide.value = null;
        }

        final List<MitraDiskonModel> result = [];
        if (data['data'] is List) {
          for (var item in data['data'] as List) {
            if (item is Map) {
              result.add(MitraDiskonModel.fromJson(
                  Map<String, dynamic>.from(item)));
            }
          }
        }
        listDiskon.assignAll(result);
        return result;
      }
    } catch (e) {
      debugPrint("getDiskonList error: $e");
    } finally {
      isLoading.value = false;
    }
    return [];
  }

  /// Mengambil produk milik mitra beserta status penguncian diskon (`is_locked`).
  Future<AvailableProductsResponse?> getAvailableProducts(
      {int? excludePromoId}) async {
    try {
      final headers = await _getHeaders();
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.mitraDiskonAvailableProducts;
      if (excludePromoId != null && excludePromoId > 0) {
        url += "?exclude_promo_id=$excludePromoId";
      }

      final response = await dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        return AvailableProductsResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint("getAvailableProducts error: $e");
    }
    return null;
  }

  /// Menyimpan diskon baru (POST) atau memperbarui diskon (PUT).
  Future<Map<String, dynamic>> saveDiskon({
    int? idPromo,
    required String namaDiskon,
    required String tipeDiskon,
    required double nilaiDiskon,
    required String cakupan,
    required String konflikDiskon,
    required List<int> selectedProductIds,
    required String tanggalMulai,
    required String tanggalSelesai,
    bool isActive = true,
  }) async {
    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final Map<String, dynamic> payload = {
        'nama_diskon': namaDiskon,
        'judul_promo': namaDiskon,
        'tipe_diskon': tipeDiskon,
        'nilai_diskon': nilaiDiskon,
        'cakupan': cakupan,
        'konflik_diskon': konflikDiskon,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'status': isActive ? 'active' : 'inactive',
      };

      if (cakupan == 'selected_products') {
        payload['selected_products'] = selectedProductIds;
      }

      final bool isEdit = idPromo != null && idPromo > 0;
      final String url = isEdit
          ? "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.mitraDiskon}/$idPromo"
          : "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.mitraDiskon}";

      final response = isEdit
          ? await dio.put(
              url,
              data: jsonEncode(payload),
              options: Options(
                headers: headers,
                validateStatus: (status) => status != null && status < 500,
              ),
            )
          : await dio.post(
              url,
              data: jsonEncode(payload),
              options: Options(
                headers: headers,
                validateStatus: (status) => status != null && status < 500,
              ),
            );

      final Map<String, dynamic> resData =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh list
        getDiskonList();
        return {
          'success': true,
          'message': resData['message'] ?? 'Diskon berhasil disimpan',
          'data': resData['data'],
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'statusCode': 422,
          'code': resData['code'],
          'message': resData['message'] ?? 'Validasi gagal',
          'conflicting_products': resData['conflicting_products'],
          'active_store_promo': resData['active_store_promo'],
          'errors': resData['errors'],
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': resData['message'] ?? 'Gagal memproses data diskon',
        };
      }
    } on DioException catch (dioError) {
      if (dioError.response != null && dioError.response?.data != null) {
        final errData = dioError.response?.data is String
            ? jsonDecode(dioError.response?.data)
            : dioError.response?.data;
        return {
          'success': false,
          'statusCode': dioError.response?.statusCode,
          'code': errData['code'],
          'message': errData['message'] ?? dioError.message,
          'conflicting_products': errData['conflicting_products'],
          'active_store_promo': errData['active_store_promo'],
        };
      }
      return {
        'success': false,
        'message': dioError.message ?? 'Terjadi kesalahan koneksi',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Menghapus program diskon produk toko.
  Future<bool> deleteDiskon(int idPromo) async {
    try {
      final headers = await _getHeaders();
      final url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.mitraDiskon}/$idPromo";

      final response = await dio.delete(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        listDiskon.removeWhere((item) => item.idPromo == idPromo);
        getDiskonList();
        return true;
      }
    } catch (e) {
      debugPrint("deleteDiskon error: $e");
    }
    return false;
  }
}
