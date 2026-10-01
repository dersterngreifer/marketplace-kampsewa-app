import 'package:dio/dio.dart';
import 'package:project_camp_sewa/components/dialog/network_error_dialog.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio();
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Beberapa service memakai validateStatus <= 500, jadi 500 masih bisa
          // sampai ke sini. Semua notifikasi error server/jaringan tetap lewat
          // NetworkErrorDialog supaya tidak ada dialog ganda.
          if (response.statusCode == 500) {
            NetworkErrorDialog.showServerError();
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Hanya connection/timeout/5xx yanghandled di sini. Error lain
          // (mis. 400/401) tetap ditangani service masing-masing.
          NetworkErrorDialog.showForError(e);
          return handler.next(e);
        },
      ),
    );
  }
}
