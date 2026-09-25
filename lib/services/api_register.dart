import 'package:project_camp_sewa/services/api_client.dart';
// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:project_camp_sewa/components/dialog/loading_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/screens/screen_login.dart';

class ApiRegistrasi extends GetxController {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController jenisKelaminController = TextEditingController();
  final Dio dio = ApiClient().dio;
  final LoadingDialog loading = Get.put(LoadingDialog());

  Future<void> registrasi(BuildContext context) async {
    if (namaController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        tanggalLahirController.text.trim().isEmpty ||
        jenisKelaminController.text.trim().isEmpty) {
      CustomSnackBar.show(
        context,
        sukses: false,
        title: "Perhatian",
        teks: "Harap isi semua kolom pendaftaran.",
      );
      return;
    }

    try {
      loading.showLoadingDialog();
      var header = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      var url = ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.register;
      Map body = {
        'name': namaController.text,
        'email': emailController.text.trim(),
        'nomor_telephone': phoneNumberController.text,
        'password': passwordController.text,
        'tanggal_lahir': tanggalLahirController.text,
        'jenis_kelamin': jenisKelaminController.text
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
          json = {'status': false, 'message': 'Terjadi kesalahan pada server (Bukan JSON)'};
        }
      } else {
        json = response.data;
      }

      loading.hideLoadingDialog();

      if (response.statusCode == 201) {
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: json['message'],
        );

        namaController.clear();
        emailController.clear();
        phoneNumberController.clear();
        passwordController.clear();
        tanggalLahirController.clear();
        jenisKelaminController.clear();
        if (context.mounted) {
          Get.to(const LoginScreen());
        }
      } else{
        String errorMessage = json['error'];
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
      }
    } on DioException catch (dioError) {
        if (context.mounted) {
          loading.hideLoadingDialog();
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
