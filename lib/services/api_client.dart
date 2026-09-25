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
          // You might have responses that are technically 200 OK but contain business logic errors, 
          // but we handle specifically 500 status codes here as requested.
          if (response.statusCode == 500) {
            NetworkErrorDialog.show(
              title: "Server Error",
              message: "Terjadi kesalahan pada server. Data tidak dapat dimuat saat ini. Sistem sedang mencoba kembali...",
              isServerError: true,
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError ||
              (e.type == DioExceptionType.unknown && e.error != null)) {
            // Usually network issues
            NetworkErrorDialog.show(
              title: "Koneksi Terputus",
              message: "Tidak ada koneksi internet atau jaringan tidak stabil. Sedang memuat ulang...",
              isServerError: false,
            );
          } else if (e.response?.statusCode == 500 || e.response?.statusCode == 502 || e.response?.statusCode == 503) {
            NetworkErrorDialog.show(
              title: "Server Error",
              message: "Terjadi kesalahan pada server. Data tidak dapat dimuat saat ini. Sistem sedang mencoba kembali...",
              isServerError: true,
            );
          }
          return handler.next(e);
        },
      ),
    );
  }
}
