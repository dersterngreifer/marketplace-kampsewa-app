// ignore_for_file: avoid_print
// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:project_camp_sewa/components/dialog/loading_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/screens/screen_dashboard.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiLogin extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final Dio dio = Dio();
  final LoadingDialog loading = Get.put(LoadingDialog());
  Authorization auth = Authorization();

  Future<void> login(BuildContext context) async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      CustomSnackBar.show(context, sukses: false,
            title: "Perhatian",
            teks: "Harap isi email dan password Anda.",);
      return;
    }

    try {
      loading.showLoadingDialog();
      var header = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      var url = ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.login;

      Map body = {
        "identifier": emailController.text,
        "password": passwordController.text
      };

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

        Map<String, dynamic> json = {};
        if (response.data is String) {
          try {
            json = jsonDecode(response.data);
          } catch (e) {
            // Jika backend membalas HTML/Error, maka buat json fallback
            json = {'status': false, 'message': 'Terjadi kesalahan pada server (Bukan JSON)'};
          }
        } else {
          json = response.data;
        }

      loading.hideLoadingDialog();

      if (response.statusCode == 200) {
        if (json['access_token'] != null) {
          var token = json['access_token'];
          var idUser = json['user']['id'];
          auth.saveToken(token);
          auth.saveId(idUser);

          int userType = json['user']['type'] ?? 1;
          auth.saveType(userType);

          emailController.clear();
          passwordController.clear();

          CustomSnackBar.show(context, sukses: true,
                teks: "Login Berhasil Sebagai ${json['user']['name']}",);

          if (context.mounted) {
            Get.offAll(() => const ScreenDashboard());
          }
        } else {
          CustomSnackBar.show(context, sukses: false,
                teks: "Anda tidak memiliki akses untuk Login",);
        }
      } else if (response.statusCode == 401) {
        String errorMessage = json['message'];
        CustomSnackBar.show(context, sukses: false,
              title: "Error",
              teks: errorMessage,);
      }
    } on DioException catch (dioError) {
      loading.hideLoadingDialog();
      print(dioError.message);
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          sukses: false,
          title: "Koneksi Bermasalah",
          teks: dioError.message ?? "Terjadi kesalahan yang tidak diketahui",
        );
      }
    }
  }
}
