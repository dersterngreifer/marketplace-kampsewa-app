// ignore_for_file: unused_local_variable
// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiRiwayatCari extends GetxController {
  final RxList<String> riwayatCari = <String>[].obs;
  Dio dio = Dio();

  Future<void> showRiwayatCari(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.showRiwayatCari +
          idStr;

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
        List<dynamic> dataList = data['data'];
        riwayatCari.assignAll(
            dataList.map((item) => item['kata_kunci'] as String).toList());
      } else if (response.statusCode == 404) {
        riwayatCari.clear();
      } else {
        riwayatCari.clear();
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

  Future<void> insertRiwayatCari(BuildContext context, String cari) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.insertRiwayatCari +
          idStr;

      Map body = {'kata_kunci': cari};

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
      } else {
        CustomSnackBar.show(context, sukses: false,
              teks: "Gagal Menambahkan Pencarian",);
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

  Future<void> deleteRiwayatCari(BuildContext context, String? riwayat) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.deleteRiwayatCari}$idStr";

      // Buat query parameters
      Map<String, String> queryParams = {};
      if (riwayat != null) {
        queryParams['keyword'] = riwayat;
        riwayatCari.remove(riwayat); // Optimistic UI update
      } else {
        riwayatCari.clear(); // Optimistic UI update
      }

      // Tambahkan query parameters ke URL jika ada
      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await dio.delete(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
      } else {
        CustomSnackBar.show(context, sukses: false,
              teks: "Gagal Menghapus Pencarian",);
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

