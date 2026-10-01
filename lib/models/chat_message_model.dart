class ChatMessageModel {
  int? id;
  int? roomId;
  int? senderId;
  int? receiverId;
  String? messageText;
  int isRead;
  String? createdAt;
  String? updatedAt;

  ChatMessageModel({
    this.id,
    this.roomId,
    this.senderId,
    this.receiverId,
    this.messageText,
    this.isRead = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      messageText: json['message_text'],
      isRead: json['is_read'] is int
          ? json['is_read']
          : (json['is_read'] == true || json['is_read'] == '1' ? 1 : 0),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
