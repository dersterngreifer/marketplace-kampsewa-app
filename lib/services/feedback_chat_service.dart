// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/feedback_model.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

/// Service untuk fitur Chat Admin–Customer — Arsitektur v2 (Per-Admin Session).
///
/// Perubahan v2:
///   • loadMessages(feedbackId, sessionId) — kirim ?session_id= ke API
///   • sendMessage(..., sessionId)         — sertakan session_id di body POST
///   • Polling juga menyimpan sessionId
class FeedbackChatService extends GetxController {
  final Dio _dio = Dio();

  // ── State: List ──────────────────────────────────────────────────────────
  final RxList<FeedbackItem> feedbackList = <FeedbackItem>[].obs;
  final RxBool isLoadingList = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalUnread = 0.obs;

  // ── State: Chat Room ─────────────────────────────────────────────────────
  final RxList<FeedbackMessage> messages = <FeedbackMessage>[].obs;
  final RxBool isLoadingMessages = false.obs;
  final Rx<FeedbackThread?> currentThread = Rx<FeedbackThread?>(null);
  final RxBool isSending = false.obs;

  // ── Polling ──────────────────────────────────────────────────────────────
  Timer? _pollingTimer;
  int? _pollingFeedbackId;
  int? _pollingAdminId; // admin ID untuk filter polling

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }

  Future<Map<String, String>> _authHeaders() async {
    final auth = Authorization();
    final token = await auth.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. GET /api/feedback — Daftar sesi per-admin (Customer list)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadFeedbackList({String? statusFilter}) async {
    isLoadingList.value = true;
    currentPage.value = 1;
    hasMorePages.value = true;
    feedbackList.clear();
    await _fetchFeedbackPage(page: 1, statusFilter: statusFilter);
    isLoadingList.value = false;
  }

  Future<void> loadMoreFeedback({String? statusFilter}) async {
    if (!hasMorePages.value || isLoadingList.value) return;
    await _fetchFeedbackPage(
      page: currentPage.value + 1,
      statusFilter: statusFilter,
    );
  }

  Future<void> _fetchFeedbackPage({
    required int page,
    String? statusFilter,
  }) async {
    try {
      final headers = await _authHeaders();
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 15,
        if (statusFilter != null && statusFilter.isNotEmpty)
          'status': statusFilter,
      };

      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/api/chat-room',
        queryParameters: queryParams,
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final body =
            response.data is String ? jsonDecode(response.data) : response.data;
        
        // Handle paginated or non-paginated data safely
        final dataField = body['data'];
        List<dynamic> rawList = [];
        int currentPageNumber = page;
        int lastPageNumber = 1;

        if (dataField is Map<String, dynamic>) {
          rawList = dataField['data'] ?? [];
          currentPageNumber = dataField['current_page'] ?? page;
          lastPageNumber = dataField['last_page'] ?? 1;
        } else if (dataField is List) {
          rawList = dataField;
          // If it's a flat list, we assume there's no pagination
          currentPageNumber = 1;
          lastPageNumber = 1;
        }

        final items = rawList.map((e) {
          try {
             return FeedbackItem.fromJson(e);
          } catch(err) {
             debugPrint('[FeedbackChat] Error parsing item: $err. Data: $e');
             return null;
          }
        }).whereType<FeedbackItem>().toList();

        if (page == 1) {
          feedbackList.assignAll(items);
        } else {
          feedbackList.addAll(items);
        }

        currentPage.value = currentPageNumber;
        hasMorePages.value = currentPage.value < lastPageNumber;

        totalUnread.value = feedbackList
            .fold(0, (sum, item) => sum + item.unreadAdminMessagesCount);
      }
    } catch (e) {
      debugPrint('[FeedbackChat] loadList error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. POST /api/feedback — Buat feedback baru
  // ─────────────────────────────────────────────────────────────────────────

  Future<FeedbackItem?> submitFeedback({
    required BuildContext context,
    required String deskripsi,
    required String kriteria,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/api/feedback',
        data: {'deskripsi': deskripsi, 'kriteria': kriteria},
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      final body =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 201) {
        return FeedbackItem.fromJson(body['data']);
      } else {
        final msg = body['message'] ?? 'Terjadi kesalahan';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('[FeedbackChat] submitFeedback error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. GET /api/chat-room/{feedback_id}/{admin_id}/messages — Isi chat per sesi
  // ─────────────────────────────────────────────────────────────────────────

  /// [adminId] = null atau 0 → feedback belum dibalas (tidak ada sesi aktif),
  ///                           API mengembalikan hanya pesan awal customer.
  /// [adminId] = int         → filter pesan: initial customer + sesi admin ini.
  Future<void> loadMessages(
    int feedbackId, {
    int? adminId,
    bool silent = false,
  }) async {
    if (!silent) isLoadingMessages.value = true;
    try {
      final headers = await _authHeaders();
      final adminIdPath = adminId ?? 0;

      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/api/chat-room/$feedbackId/$adminIdPath/messages',
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final body =
            response.data is String ? jsonDecode(response.data) : response.data;
        final data = body['data'];

        currentThread.value = FeedbackThread.fromJson(data['feedback']);

        final List<dynamic> rawMsgs = data['messages'] ?? [];
        final newMsgs = rawMsgs.map((e) => FeedbackMessage.fromJson(e)).toList();

        if (silent) {
          final existingIds = messages.map((m) => m.id).toSet();
          final added =
              newMsgs.where((m) => !existingIds.contains(m.id)).toList();
          if (added.isNotEmpty) messages.addAll(added);
        } else {
          messages.assignAll(newMsgs);
        }
      }
    } catch (e) {
      debugPrint('[FeedbackChat] loadMessages error: $e');
    } finally {
      if (!silent) isLoadingMessages.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. POST /api/chat-room/{feedback_id}/{admin_id}/messages — Kirim pesan
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> sendMessage({
    required BuildContext context,
    required int feedbackId,
    required String message,
    int? adminId,
  }) async {
    if (message.trim().isEmpty) return false;
    isSending.value = true;
    try {
      final headers = await _authHeaders();
      final body = <String, dynamic>{
        'message': message.trim(),
        if (adminId != null) 'admin_id': adminId,
      };

      final adminIdPath = adminId ?? 0;

      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/api/chat-room/$feedbackId/$adminIdPath/messages',
        data: body,
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      final respBody =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 201) {
        final newMsg = FeedbackMessage.fromJson(respBody['data']);
        if (!messages.any((m) => m.id == newMsg.id)) {
          messages.add(newMsg);
        }
        return true;
      } else {
        final msg = respBody['message'] ?? 'Gagal mengirim pesan';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint('[FeedbackChat] sendMessage error: $e');
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Polling — polling list chat dan polling room chat
  // ─────────────────────────────────────────────────────────────────────────
  
  Timer? _listPollingTimer;
  String? _currentListStatusFilter;

  void startListPolling({String? statusFilter}) {
    stopListPolling();
    _currentListStatusFilter = statusFilter;
    _listPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!isLoadingList.value) { // jangan nimpa kalau masih fetch page 1 
         _fetchFeedbackPage(
           page: 1, 
           statusFilter: _currentListStatusFilter, 
         );
      }
    });
  }

  void stopListPolling() {
    _listPollingTimer?.cancel();
    _listPollingTimer = null;
  }

  void startPolling(int feedbackId, {int? adminId}) {
    stopPolling();
    _pollingFeedbackId = feedbackId;
    _pollingAdminId = adminId;
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pollingFeedbackId != null) {
        // Jika kita sedang menunggu balasan (adminId null/0), cek apakah di list 
        // polling sudah muncul admin yang membalas. Jika ada, gunakan adminId tersebut!
        if (_pollingAdminId == null || _pollingAdminId == 0) {
          try {
            final updatedItem = feedbackList.firstWhere(
              (item) => item.id == _pollingFeedbackId && item.adminId != null && item.adminId! > 0,
            );
            _pollingAdminId = updatedItem.adminId;
          } catch (_) {
            // Belum ada admin yang membalas
          }
        }

        loadMessages(
          _pollingFeedbackId!,
          adminId: _pollingAdminId,
          silent: true,
        );
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollingFeedbackId = null;
    _pollingAdminId = null;
  }

  void clearChatRoom() {
    stopPolling();
    messages.clear();
    currentThread.value = null;
  }
}
