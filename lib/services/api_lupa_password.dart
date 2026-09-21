// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog.dart';
import 'package:project_camp_sewa/components/dialog/loading_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/layouts/layout_lupa_password_new_pass.dart';
import 'package:project_camp_sewa/layouts/layout_lupa_password_otp.dart';
import 'package:project_camp_sewa/screens/screen_login.dart';

class ApiLupaPassword extends GetxController {
  TextEditingController telephoneController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  final Dio dio = Dio();
  final LoadingDialog loading = Get.put(LoadingDialog());

  Future<void> lupaPass(BuildContext context) async {
    try {
      loading.showLoadingDialog();
      var header = {'Accept': 'application/json'};
      var url = ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.lupaPass;

      Map body = {
        "nomor_telephone": telephoneController.text.trim(),
      };

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! <= 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      loading.hideLoadingDialog();

      if (response.statusCode == 200) {
        CustomSnackBar.show(context, sukses: true,
              teks: json['message'],);
        if (context.mounted) {
          var kirimData = {'nomor_telephone': telephoneController.text.trim()};
          Get.to(const LayoutLupaPasswordOTP(), arguments: kirimData);
        }
        telephoneController.clear();
      } else {
        String errorMessage = json['message'];
        CustomSnackBar.show(context, sukses: false,
              teks: errorMessage,);
      }
    } on DioException catch (dioError) {
      loading.hideLoadingDialog();
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

  Future<void> lupaPassVerifikasiOTP(
      BuildContext context, String verifikasiOtp, String noTelephone) async {
    try {
      loading.showLoadingDialog();
      var header = {'Accept': 'application/json'};
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.lupaPassOTP +
          noTelephone;

      Map body = {
        "otp": verifikasiOtp,
      };

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      loading.hideLoadingDialog();

      if (response.statusCode == 200) {
        CustomSnackBar.show(context, sukses: true,
              teks: json['message'],);

        if (context.mounted) {
          var kirimData = {
            'nomor_telephone': noTelephone,
            'lupa_password': true
          };
          Get.to(const LayoutLupaPasswordNewPass(), arguments: kirimData);
        }
      } else {
        String errorMessage = json['message'];
        CustomSnackBar.show(context, sukses: false,
              teks: errorMessage,);
      }
    } on DioException catch (dioError) {
      loading.hideLoadingDialog();
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

  Future<void> lupaPassResetPass(
      BuildContext context, String noTelephone, bool lupaPass) async {
    try {
      loading.showLoadingDialog();
      var header = {'Accept': 'application/json'};
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.lupaPassResetPass +
          noTelephone;

      Map body = {
        "password": newPassController.text.trim(),
        "confirm-password": confirmPassController.text.trim()
      };

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      loading.hideLoadingDialog();

      if (response.statusCode == 200) {
        CustomSnackBar.show(context, sukses: true,
              teks: json['message'],);

        newPassController.clear();
        confirmPassController.clear();
        if (context.mounted) {
          if (lupaPass) {
            Get.off(const LoginScreen());
          } else {
            Get.back();
          }
        }
      } else {
        String errorMessage = json['message'];
        CustomSnackBar.show(context, sukses: false,
              teks: errorMessage,);
      }
    } on DioException catch (dioError) {
      loading.hideLoadingDialog();
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

