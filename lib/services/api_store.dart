// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/models/store_model.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiStore extends GetxController {
  final Dio _dio = ApiClient().dio;

  /// Mengambil profil toko publik berdasarkan [idUser].
  ///
  /// Endpoint: GET /api/store/{id_user}
  /// Auth: Opsional (public endpoint)
  ///
  /// Mengembalikan [StoreModel] jika berhasil, atau `null` jika terjadi
  /// error (404 tidak ditemukan, dll.). Pesan error dikembalikan via
  /// [errorMessage].
  Future<({StoreModel? store, String? errorMessage})> getStoreProfile(
      int idUser) async {
    try {
      final Authorization auth = Authorization();
      final String? token = await auth.getToken();

      final Map<String, String> headers = {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      final String url =
          '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getStoreProfile}$idUser';

      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 && data['success'] == true) {
        final store = StoreModel.fromJson(data['data'] as Map<String, dynamic>);
        return (store: store, errorMessage: null);
      } else {
        final String message =
            data['message']?.toString() ?? 'Toko tidak ditemukan.';
        return (store: null, errorMessage: message);
      }
    } on DioException catch (e) {
      final String message =
          e.message ?? 'Terjadi kesalahan saat memuat profil toko.';
      return (store: null, errorMessage: message);
    } catch (e) {
      return (store: null, errorMessage: e.toString());
    }
  }

  /// Mengambil daftar produk toko publik berdasarkan [idUser].
  ///
  /// Endpoint: GET /api/store/{id_user}/products
  /// Auth: Opsional — jika token disertakan, nilai `is_liked` akan akurat.
  ///
  /// [kategori] — filter berdasarkan nama kategori (opsional)
  /// [search]   — pencarian nama/deskripsi produk (opsional)
  ///
  /// Mengembalikan list [ProdukModel] jika berhasil, atau list kosong beserta
  /// pesan error.
  Future<({List<ProdukModel> products, String? errorMessage})> getStoreProducts(
    int idUser, {
    String? kategori,
    String? search,
  }) async {
    try {
      final Authorization auth = Authorization();
      final String? token = await auth.getToken();

      final Map<String, String> headers = {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      final Map<String, String> queryParams = {};
      if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
        queryParams['kategori'] = kategori;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      String url =
          '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getStoreProducts}$idUser/products';

      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 && data['success'] == true) {
        final rawData = data['data'] as List? ?? [];
        final List<ProdukModel> produkList = rawData
            .map((e) => ProdukModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return (products: produkList, errorMessage: null);
      } else if (response.statusCode == 404) {
        return (products: <ProdukModel>[], errorMessage: 'Toko tidak ditemukan.');
      } else {
        final String message =
            data['message']?.toString() ?? 'Gagal memuat produk toko.';
        return (products: <ProdukModel>[], errorMessage: message);
      }
    } on DioException catch (e) {
      final String message =
          e.message ?? 'Terjadi kesalahan saat memuat produk toko.';
      return (products: <ProdukModel>[], errorMessage: message);
    } catch (e) {
      return (products: <ProdukModel>[], errorMessage: e.toString());
    }
  }
}
