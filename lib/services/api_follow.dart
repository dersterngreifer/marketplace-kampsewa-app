// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/follow_model.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

/// Service untuk semua operasi Follow / Unfollow.
///
/// Endpoint:
/// - POST /api/follow/{user_id}      — Follow akun
/// - POST /api/unfollow/{user_id}    — Unfollow akun
/// - GET  /api/user/{user_id}/followers — List followers
/// - GET  /api/user/{user_id}/following — List following
class ApiFollow extends GetxController {
  final Dio _dio = ApiClient().dio;

  /// Mengambil header Authorization + Accept.
  Future<Map<String, String>> _buildHeaders() async {
    final Authorization auth = Authorization();
    final String? token = await auth.getToken();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── Follow ───────────────────────────────────────────────────────────────────

  /// Follow akun dengan [userId].
  ///
  /// Mengembalikan `true` jika berhasil, `false` beserta [errorMessage] jika gagal.
  Future<({bool success, String? errorMessage})> followUser(int userId) async {
    try {
      final headers = await _buildHeaders();
      final String url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.followUser(userId);

      final response = await _dio.post(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (success: true, errorMessage: null);
      } else {
        final String message =
            data['message']?.toString() ?? 'Gagal follow akun.';
        return (success: false, errorMessage: message);
      }
    } on DioException catch (e) {
      return (success: false, errorMessage: e.message ?? 'Terjadi kesalahan.');
    } catch (e) {
      return (success: false, errorMessage: e.toString());
    }
  }

  // ── Unfollow ─────────────────────────────────────────────────────────────────

  /// Unfollow akun dengan [userId].
  ///
  /// Mengembalikan `true` jika berhasil, `false` beserta [errorMessage] jika gagal.
  Future<({bool success, String? errorMessage})> unfollowUser(
      int userId) async {
    try {
      final headers = await _buildHeaders();
      final String url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.unfollowUser(userId);

      final response = await _dio.post(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        return (success: true, errorMessage: null);
      } else {
        final String message =
            data['message']?.toString() ?? 'Gagal unfollow akun.';
        return (success: false, errorMessage: message);
      }
    } on DioException catch (e) {
      return (success: false, errorMessage: e.message ?? 'Terjadi kesalahan.');
    } catch (e) {
      return (success: false, errorMessage: e.toString());
    }
  }

  // ── List Followers ───────────────────────────────────────────────────────────

  /// Mengambil list user yang mem-follow [userId].
  ///
  /// Endpoint: GET /api/user/{user_id}/followers
  Future<({List<FollowUserModel> data, String? errorMessage})> getFollowers(
      int userId) async {
    try {
      final headers = await _buildHeaders();
      final String url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.getFollowers(userId);

      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
      );

      final Map<String, dynamic> responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        final rawList = responseData['data'] as List? ?? [];
        final List<FollowUserModel> list = rawList
            .map((e) => FollowUserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return (data: list, errorMessage: null);
      } else {
        final String message =
            responseData['message']?.toString() ?? 'Gagal memuat followers.';
        return (data: <FollowUserModel>[], errorMessage: message);
      }
    } on DioException catch (e) {
      return (
        data: <FollowUserModel>[],
        errorMessage: e.message ?? 'Terjadi kesalahan.'
      );
    } catch (e) {
      return (data: <FollowUserModel>[], errorMessage: e.toString());
    }
  }

  // ── List Following ───────────────────────────────────────────────────────────

  /// Mengambil list user yang di-follow oleh [userId].
  ///
  /// Endpoint: GET /api/user/{user_id}/following
  Future<({List<FollowUserModel> data, String? errorMessage})> getFollowing(
      int userId) async {
    try {
      final headers = await _buildHeaders();
      final String url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.getFollowing(userId);

      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
      );

      final Map<String, dynamic> responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        final rawList = responseData['data'] as List? ?? [];
        final List<FollowUserModel> list = rawList
            .map((e) => FollowUserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return (data: list, errorMessage: null);
      } else {
        final String message =
            responseData['message']?.toString() ?? 'Gagal memuat following.';
        return (data: <FollowUserModel>[], errorMessage: message);
      }
    } on DioException catch (e) {
      return (
        data: <FollowUserModel>[],
        errorMessage: e.message ?? 'Terjadi kesalahan.'
      );
    } catch (e) {
      return (data: <FollowUserModel>[], errorMessage: e.toString());
    }
  }
}
