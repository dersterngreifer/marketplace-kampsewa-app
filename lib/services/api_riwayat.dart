import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:project_camp_sewa/models/riwayat_model.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/services/api_client.dart';

class ApiRiwayat extends GetxController {
  var isLoading = false.obs;
  var riwayatList = <RiwayatModel>[].obs;
  var errorMessage = "".obs;
  Dio dio = ApiClient().dio;

  Future<void> fetchRiwayat({String status = ""}) async {
    isLoading.value = true;
    errorMessage.value = "";
    try {
      final token = await Authorization().getToken();
      final idUser = await Authorization().getId();
      String url = '${ApiEndpoints.baseUrl}/api/riwayat?id_user=$idUser';
      if (status.isNotEmpty) {
        url += '&status=${status.toLowerCase().replaceAll(' ', '-')}';
      }

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          riwayatList.value = List<RiwayatModel>.from(data.map((json) => RiwayatModel.fromJson(json as Map<String, dynamic>)));
        } else {
          riwayatList.value = [];
        }
      } else {
        riwayatList.value = [];
        errorMessage.value = "Gagal memuat data (${response.statusCode})";
      }
    } catch (e) {
      print("Error fetching riwayat: $e");
      riwayatList.value = [];
      errorMessage.value = "Terjadi kesalahan: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
