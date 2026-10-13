import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/network_error_dialog.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/iklan_model.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiIklan extends GetxController {
  Dio dio = ApiClient().dio;
  final RxList<IklanModel> listIklan = <IklanModel>[].obs;

  Future<void> getIklan(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        header['Authorization'] = 'Bearer $token';
      }
      var url = ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.getIklan;

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
        final List<dynamic> rawList = data['data'];
        List<IklanModel> iklanList = [];
        for (var e in rawList) {
          if (e is Map<String, dynamic>) {
            iklanList.add(IklanModel.fromJson(e));
          } else if (e is Map) {
            iklanList.add(IklanModel.fromJson(Map<String, dynamic>.from(e)));
          }
        }
        listIklan.assignAll(iklanList);
      } else {
        debugPrint(
            "getIklan response info: status ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      debugPrint("getIklan DioException: ${dioError.message}");
    } catch (e) {
      debugPrint("getIklan error: $e");
    }
  }
}
