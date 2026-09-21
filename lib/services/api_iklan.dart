// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/iklan_model.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiIklan extends GetxController {
  Dio dio = Dio();
  final RxList<IklanModel> listIklan = <IklanModel>[].obs;

  Future<void> getIklan(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.getIklan;

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
        List<IklanModel> iklanList = List<IklanModel>.from(
            data['data'].map((e) => IklanModel.fromJson(e)).toList());
        listIklan.assignAll(iklanList);
      } else {
        String errorMessage = data['message'];
        CustomSnackBar.show(context, sukses: false,
              teks: errorMessage,);
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

