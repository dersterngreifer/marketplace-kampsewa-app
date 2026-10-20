import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';

class ApiLikesHistory extends GetxController {
  var isLoadingLikes = false.obs;
  var isLoadingFeedbacks = false.obs;

  var likesList = [].obs;
  var feedbackList = [].obs;

  Dio dio = ApiClient().dio;

  @override
  void onInit() {
    super.onInit();
    fetchLikes();
    fetchFeedbacks();
  }

  Future<void> fetchLikes() async {
    isLoadingLikes.value = true;
    try {
      final token = await Authorization().getToken();
      if (token == null) return;

      const url = '${ApiEndpoints.baseUrl}/api/user/likes';
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] != null) {
          likesList.assignAll(response.data['data']);
        }
      } else {
        print("Error fetchLikes: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "DioError fetchLikes: ${e.response?.statusCode} ${e.response?.data}");
      } else {
        print("Error fetchLikes: $e");
      }
    } finally {
      isLoadingLikes.value = false;
    }
  }

  Future<void> fetchFeedbacks() async {
    isLoadingFeedbacks.value = true;
    try {
      final token = await Authorization().getToken();
      if (token == null) return;

      const url = '${ApiEndpoints.baseUrl}/api/user/feedbacks';
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] != null) {
          feedbackList.assignAll(response.data['data']);
        }
      } else {
        print("Error fetchFeedbacks: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "DioError fetchFeedbacks: ${e.response?.statusCode} ${e.response?.data}");
      } else {
        print("Error fetchFeedbacks: $e");
      }
    } finally {
      isLoadingFeedbacks.value = false;
    }
  }
}
