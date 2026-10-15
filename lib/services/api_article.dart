import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/network_error_dialog.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/article_model.dart';
import 'package:project_camp_sewa/services/api_client.dart';

class ApiArticle extends GetxController {
  final Dio dio = ApiClient().dio;

  // ── Reactive State untuk Dashboard ──
  final RxList<ArticleModel> listWisataDashboard = <ArticleModel>[].obs;
  final RxList<ArticleModel> listBeritaDashboard = <ArticleModel>[].obs;
  final RxBool isLoadingWisataDashboard = false.obs;
  final RxBool isLoadingBeritaDashboard = false.obs;

  // ── Cache detail artikel lokal untuk optimasi rendering ──
  final RxMap<int, ArticleModel> articleDetailCache = <int, ArticleModel>{}.obs;

  /// Mengambil preview rekomendasi wisata untuk dashboard (default limit: 6)
  Future<void> fetchWisataDashboard({int limit = 6}) async {
    try {
      isLoadingWisataDashboard.value = true;
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getWisata}';

      final response = await dio.get(
        url,
        queryParameters: {'limit': limit},
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final dynamic rawData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && rawData is Map && rawData['data'] is List) {
        final List<dynamic> items = rawData['data'];
        final List<ArticleModel> result = items
            .whereType<Map>()
            .map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        listWisataDashboard.assignAll(result);
      } else {
        debugPrint("fetchWisataDashboard info: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      debugPrint("fetchWisataDashboard DioException: ${dioError.message}");
    } catch (e) {
      debugPrint("fetchWisataDashboard error: $e");
    } finally {
      isLoadingWisataDashboard.value = false;
    }
  }

  /// Mengambil preview berita terkini untuk dashboard (default limit: 5)
  Future<void> fetchBeritaDashboard({int limit = 5}) async {
    try {
      isLoadingBeritaDashboard.value = true;
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getBerita}';

      final response = await dio.get(
        url,
        queryParameters: {'limit': limit},
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final dynamic rawData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && rawData is Map && rawData['data'] is List) {
        final List<dynamic> items = rawData['data'];
        final List<ArticleModel> result = items
            .whereType<Map>()
            .map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        listBeritaDashboard.assignAll(result);
      } else {
        debugPrint("fetchBeritaDashboard info: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      debugPrint("fetchBeritaDashboard DioException: ${dioError.message}");
    } catch (e) {
      debugPrint("fetchBeritaDashboard error: $e");
    } finally {
      isLoadingBeritaDashboard.value = false;
    }
  }

  /// Mengambil list rekomendasi wisata berhalaman (pagination) dengan sorting & filtering
  Future<Map<String, dynamic>> fetchWisataList({
    int page = 1,
    int perPage = 10,
    String? sortBy,
    String? filterWaktu,
    String? lokasi,
    String? search,
  }) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getWisata}';
      final Map<String, dynamic> qParams = {
        'page': page,
        'per_page': perPage,
      };

      if (sortBy != null && sortBy.isNotEmpty) qParams['sort_by'] = sortBy;
      if (filterWaktu != null && filterWaktu.isNotEmpty && filterWaktu != 'semua') {
        qParams['filter_waktu'] = filterWaktu;
      }
      if (lokasi != null && lokasi.isNotEmpty) qParams['lokasi'] = lokasi;
      if (search != null && search.trim().isNotEmpty) qParams['search'] = search.trim();

      final response = await dio.get(
        url,
        queryParameters: qParams,
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final dynamic rawData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && rawData is Map && rawData['data'] is List) {
        final List<dynamic> items = rawData['data'];
        final List<ArticleModel> result = items
            .whereType<Map>()
            .map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final Map<String, dynamic> pagination = rawData['pagination'] is Map
            ? Map<String, dynamic>.from(rawData['pagination'])
            : {};

        return {
          'success': true,
          'data': result,
          'pagination': pagination,
        };
      }

      return {
        'success': false,
        'message': rawData is Map ? (rawData['message'] ?? 'Gagal memuat data wisata') : 'Gagal memuat data wisata',
        'data': <ArticleModel>[],
      };
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) {
        return {'success': false, 'message': 'Koneksi terputus', 'data': <ArticleModel>[]};
      }
      return {'success': false, 'message': dioError.message ?? 'Kesalahan jaringan', 'data': <ArticleModel>[]};
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': <ArticleModel>[]};
    }
  }

  /// Mengambil list berita terkini berhalaman (pagination) dengan sorting & filtering
  Future<Map<String, dynamic>> fetchBeritaList({
    int page = 1,
    int perPage = 10,
    String? sortBy,
    String? filterWaktu,
    String? search,
  }) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getBerita}';
      final Map<String, dynamic> qParams = {
        'page': page,
        'per_page': perPage,
      };

      if (sortBy != null && sortBy.isNotEmpty) qParams['sort_by'] = sortBy;
      if (filterWaktu != null && filterWaktu.isNotEmpty && filterWaktu != 'semua') {
        qParams['filter_waktu'] = filterWaktu;
      }
      if (search != null && search.trim().isNotEmpty) qParams['search'] = search.trim();

      final response = await dio.get(
        url,
        queryParameters: qParams,
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final dynamic rawData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && rawData is Map && rawData['data'] is List) {
        final List<dynamic> items = rawData['data'];
        final List<ArticleModel> result = items
            .whereType<Map>()
            .map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final Map<String, dynamic> pagination = rawData['pagination'] is Map
            ? Map<String, dynamic>.from(rawData['pagination'])
            : {};

        return {
          'success': true,
          'data': result,
          'pagination': pagination,
        };
      }

      return {
        'success': false,
        'message': rawData is Map ? (rawData['message'] ?? 'Gagal memuat berita terkini') : 'Gagal memuat berita terkini',
        'data': <ArticleModel>[],
      };
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) {
        return {'success': false, 'message': 'Koneksi terputus', 'data': <ArticleModel>[]};
      }
      return {'success': false, 'message': dioError.message ?? 'Kesalahan jaringan', 'data': <ArticleModel>[]};
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': <ArticleModel>[]};
    }
  }

  /// Mengambil detail satu rekomendasi wisata berdasarkan ID (juga menambah views_count di backend)
  Future<ArticleModel?> fetchDetailWisata(int id) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getWisata}/$id';
      final response = await dio.get(
        url,
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final dynamic rawData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && rawData is Map && rawData['data'] is Map) {
        final article = ArticleModel.fromJson(Map<String, dynamic>.from(rawData['data']));
        articleDetailCache[id] = article;
        return article;
      }
      return null;
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return null;
      debugPrint("fetchDetailWisata DioException: ${dioError.message}");
      return null;
    } catch (e) {
      debugPrint("fetchDetailWisata error: $e");
      return null;
    }
  }

  /// Mengambil detail satu berita terkini berdasarkan ID (juga menambah views_count di backend)
  Future<ArticleModel?> fetchDetailBerita(int id) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getBerita}/$id';
      final response = await dio.get(
        url,
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final dynamic rawData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && rawData is Map && rawData['data'] is Map) {
        final article = ArticleModel.fromJson(Map<String, dynamic>.from(rawData['data']));
        articleDetailCache[id] = article;
        return article;
      }
      return null;
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return null;
      debugPrint("fetchDetailBerita DioException: ${dioError.message}");
      return null;
    } catch (e) {
      debugPrint("fetchDetailBerita error: $e");
      return null;
    }
  }
}
