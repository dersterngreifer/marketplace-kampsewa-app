import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/network_error_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/notifikasi_model.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';
import 'package:project_camp_sewa/services/controller_riwayat_badge.dart';

class ApiNotifikasi extends GetxController {
  final Dio dio = ApiClient().dio;

  final RxList<NotifikasiModel> listNotifikasi = <NotifikasiModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifikasi();
  }

  /// Mengambil daftar notifikasi in-app
  Future<void> fetchNotifikasi({
    BuildContext? context,
    bool unreadOnly = false,
  }) async {
    isLoading.value = true;
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      if (token == null) {
        // Fallback retry jika token sedang ditulis ke disk (misal pasca-login)
        await Future.delayed(const Duration(milliseconds: 250));
        token = await auth.getToken();
      }
      if (token == null) {
        listNotifikasi.clear();
        unreadCount.value = 0;
        return;
      }

      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      String url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.notifikasi}";
      if (unreadOnly) {
        url += "?unread_only=true";
      }

      final response = await dio.get(
        url,
        options: Options(
          headers: header,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      final bool isSuccess = response.statusCode == 200 &&
          (data['success'] == true ||
              data['success'] == 1 ||
              data['success'] == 'true' ||
              data['status'] == true ||
              data['message'] == 'success');

      if (isSuccess) {
        var countRaw = data['unread_count'];
        int count = 0;
        if (countRaw is int) {
          count = countRaw;
        } else if (countRaw != null) {
          count = int.tryParse(countRaw.toString()) ?? 0;
        }

        var rawList = data['data'] ?? [];
        if (rawList is List) {
          List<NotifikasiModel> items = rawList
              .map((e) => NotifikasiModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          listNotifikasi.assignAll(items);
          if (countRaw == null) {
            count = items.where((n) => !n.isRead).length;
          }
          if (Get.isRegistered<RiwayatBadgeController>()) {
            Get.find<RiwayatBadgeController>().syncFromNotifications(items);
          }
        } else {
          listNotifikasi.clear();
          if (Get.isRegistered<RiwayatBadgeController>()) {
            Get.find<RiwayatBadgeController>().clearAll();
          }
        }
        unreadCount.value = count;
        unreadCount.refresh();
      } else {
        listNotifikasi.clear();
        if (Get.isRegistered<RiwayatBadgeController>()) {
          Get.find<RiwayatBadgeController>().clearAll();
        }
      }
    } catch (error) {
      if (NetworkErrorDialog.isNetworkOrServerError(error)) return;
      if (context != null && context.mounted) {
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: "Gagal memuat notifikasi",
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Menandai satu notifikasi sebagai telah dibaca
  Future<bool> markAsRead(int notifId) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      if (token == null) return false;

      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.markNotifikasiRead(notifId)}";

      final response = await dio.post(
        url,
        options: Options(
          headers: header,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final index = listNotifikasi.indexWhere((n) => n.id == notifId);
        if (index != -1 && !listNotifikasi[index].isRead) {
          listNotifikasi[index].isRead = true;
          listNotifikasi.refresh();
          if (unreadCount.value > 0) {
            unreadCount.value--;
          }
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Menandai semua notifikasi sebagai telah dibaca
  Future<bool> markAllAsRead({BuildContext? context}) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      if (token == null) return false;

      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.markAllNotifikasiRead}";

      final response = await dio.post(
        url,
        options: Options(
          headers: header,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        for (var n in listNotifikasi) {
          n.isRead = true;
        }
        listNotifikasi.refresh();
        unreadCount.value = 0;
        if (context != null && context.mounted) {
          CustomSnackBar.show(
            context,
            sukses: true,
            teks: "Semua notifikasi ditandai telah dibaca",
          );
        }
        return true;
      }
    } catch (_) {}
    return false;
  }
}
