import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/network_error_dialog.dart';
import 'package:project_camp_sewa/screens/screen_login.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  static bool _isKicking = false;

  factory ApiClient() {
    return _instance;
  }

  static void _handleUnauthorized() async {
    if (_isKicking) return;
    _isKicking = true;

    Authorization auth = Authorization();
    await auth.clearAll();

    Get.offAll(() => const LoginScreen());
    
    // We try to show CustomSnackBar if a context is available via Get.context
    // Otherwise fallback to Get.snackbar
    if (Get.context != null) {
      CustomSnackBar.show(
        Get.context!,
        sukses: false,
        title: "Sesi Berakhir",
        teks: "Akun Anda tidak valid atau telah dihapus. Silakan login kembali.",
      );
    } else {
      Get.snackbar(
        "Sesi Berakhir",
        "Akun Anda tidak valid atau telah dihapus. Silakan login kembali.",
        snackPosition: SnackPosition.TOP,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isKicking = false;
    });
  }

  ApiClient._internal() {
    dio = Dio();
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 401) {
            _handleUnauthorized();
          } else if (response.statusCode == 500) {
            NetworkErrorDialog.showServerError();
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            _handleUnauthorized();
          } else {
            NetworkErrorDialog.showForError(e);
          }
          return handler.next(e);
        },
      ),
    );
  }
}
