import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/network_error_dialog.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiRiwayatCari extends GetxController {
  final RxList<String> riwayatCari = <String>[].obs;
  Dio dio = ApiClient().dio;

  Future<void> showRiwayatCari(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();

      if (token == null || id == null) {
        riwayatCari.clear();
        return;
      }

      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.showRiwayatCari +
          idStr;

      final response = await dio.get(
        url,
        options: Options(
          headers: header,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 && data['data'] is List) {
        List<dynamic> dataList = data['data'];
        riwayatCari.assignAll(
          dataList
              .map((item) => item['kata_kunci']?.toString() ?? '')
              .where((item) => item.isNotEmpty)
              .toList(),
        );
      } else {
        riwayatCari.clear();
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      debugPrint("showRiwayatCari DioException: ${dioError.message}");
    } catch (e) {
      debugPrint("showRiwayatCari error: $e");
    }
  }

  Future<void> insertRiwayatCari(BuildContext? context, String cari) async {
    final cleanKeyword = cari.trim();
    if (cleanKeyword.isEmpty) return;

    // Simpan optimistik di state lokal agar riwayat langsung muncul di UI
    if (!riwayatCari.contains(cleanKeyword)) {
      riwayatCari.insert(0, cleanKeyword);
    }

    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();

      if (token == null || id == null) {
        // Pengguna guest / belum login, cukup simpan lokal di memory
        return;
      }

      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.insertRiwayatCari +
          idStr;

      Map body = {'kata_kunci': cleanKeyword};

      final response = await dio.post(
        url,
        data: body,
        options: Options(
          headers: header,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Status 200 / 201 (Created) dianggap sukses
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Riwayat pencarian berhasil disimpan: $cleanKeyword");
      } else {
        // Silent logging: jangan mengganggu alur belanja / navigasi pengguna dengan snackbar error
        debugPrint(
            "insertRiwayatCari info: status ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (dioError) {
      debugPrint("insertRiwayatCari DioException: ${dioError.message}");
    } catch (e) {
      debugPrint("insertRiwayatCari error: $e");
    }
  }

  Future<void> deleteRiwayatCari(BuildContext? context, String? riwayat) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();

      // Hapus optimistik dari state lokal
      if (riwayat != null) {
        riwayatCari.remove(riwayat);
      } else {
        riwayatCari.clear();
      }

      if (token == null || id == null) {
        return;
      }

      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.deleteRiwayatCari}$idStr";

      Map<String, String> queryParams = {};
      if (riwayat != null) {
        queryParams['keyword'] = riwayat;
      }

      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await dio.delete(
        url,
        options: Options(
          headers: header,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("Riwayat pencarian berhasil dihapus dari server");
      } else {
        debugPrint(
            "deleteRiwayatCari info: status ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      debugPrint("deleteRiwayatCari DioException: ${dioError.message}");
    } catch (e) {
      debugPrint("deleteRiwayatCari error: $e");
    }
  }
}
