import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/chat_message_model.dart';
import 'package:project_camp_sewa/models/chat_room_model.dart';
import 'package:project_camp_sewa/services/api_client.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class ApiChat extends GetxController {
  final Dio dio = ApiClient().dio;

  RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  RxList<ChatMessageModel> chatMessages = <ChatMessageModel>[].obs;
  RxInt totalUnread = 0.obs;
  RxBool isLoadingRooms = false.obs;
  RxBool isLoadingMessages = false.obs;

  Future<String?> _getToken() async {
    return await Authorization().getToken();
  }

  Future<void> getChatRooms() async {
    try {
      isLoadingRooms.value = true;
      String? token = await _getToken();
      if (token == null) return;

      var response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/chat/rooms',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List data = response.data['data'];
        chatRooms.value = data.map((e) => ChatRoomModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error getChatRooms: $e');
    } finally {
      isLoadingRooms.value = false;
      getUnreadSummary(); // Update badge
    }
  }

  Future<void> getChatMessages(int roomId, {bool isSilent = false}) async {
    try {
      if (!isSilent) isLoadingMessages.value = true;
      String? token = await _getToken();
      if (token == null) return;

      var response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/chat/room/$roomId/messages',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List data = response.data['data'];
        final newMessages = data.map((e) => ChatMessageModel.fromJson(e)).toList();
        if (chatMessages.length != newMessages.length ||
            (newMessages.isNotEmpty && chatMessages.isNotEmpty && newMessages.last.id != chatMessages.last.id)) {
          chatMessages.value = newMessages;
        }
        // After loading messages, update unread summary as they are read
        getUnreadSummary();
      }
    } catch (e) {
      print('Error getChatMessages: $e');
    } finally {
      if (!isSilent) isLoadingMessages.value = false;
    }
  }

  Future<void> getChatMessagesByUser(int userIdLawan, {bool isSilent = false}) async {
    try {
      if (!isSilent) isLoadingMessages.value = true;
      String? token = await _getToken();
      if (token == null) return;

      var response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/chat/messages/$userIdLawan',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List data = response.data['data'];
        final newMessages = data.map((e) => ChatMessageModel.fromJson(e)).toList();
        if (chatMessages.length != newMessages.length ||
            (newMessages.isNotEmpty && chatMessages.isNotEmpty && newMessages.last.id != chatMessages.last.id)) {
          chatMessages.value = newMessages;
        }
        getUnreadSummary();
      }
    } catch (e) {
      print('Error getChatMessagesByUser: $e');
    } finally {
      if (!isSilent) isLoadingMessages.value = false;
    }
  }

  Future<bool> sendMessage(int receiverId, String messageText) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      var response = await dio.post(
        '${ApiEndpoints.baseUrl}/api/chat/send',
        data: {
          'receiver_id': receiverId,
          'message': messageText,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        ChatMessageModel newMessage = ChatMessageModel.fromJson(response.data['data']);
        chatMessages.add(newMessage);
        getChatRooms(); // refresh list
        return true;
      }
    } catch (e) {
      print('Error sendMessage: $e');
    }
    return false;
  }

  Future<void> getUnreadSummary() async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      var response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/chat/unread-summary',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        totalUnread.value = response.data['data']['total_unread_count'] ?? 0;
      }
    } catch (e) {
      print('Error getUnreadSummary: $e');
    }
  }
}
