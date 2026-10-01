import 'package:project_camp_sewa/constants/api_endpoint.dart';

/// Helper: parse nilai JSON ke int secara aman.
/// Menangani semua tipe: int, bool, String, dan null.
int _parseIntField(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return value == '1' || value == 'true' ? 1 : 0;
  return defaultValue;
}

class ChatRoomModel {
  int? roomId;
  String? lastMessage;
  String? updatedAt;
  int unreadCount;
  int isReadLast; // 1 = sudah dibaca / pengirim bukan kita, 0 = kita kirim & belum dibaca
  ChatUserModel? user;

  ChatRoomModel({
    this.roomId,
    this.lastMessage,
    this.updatedAt,
    this.unreadCount = 0,
    this.isReadLast = 1,
    this.user,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      roomId: json['room_id'],
      lastMessage: json['last_message'],
      updatedAt: json['updated_at'],
      unreadCount: _parseIntField(json['unread_count'], defaultValue: 0),
      isReadLast: _parseIntField(json['is_read_last'], defaultValue: 1),
      user: json['user'] != null ? ChatUserModel.fromJson(json['user']) : null,
    );
  }
}

class ChatUserModel {
  int? id;
  String? name;
  String? fotoProfile; // sudah full URL, siap pakai
  String? namaToko;

  ChatUserModel({
    this.id,
    this.name,
    this.fotoProfile,
    this.namaToko,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    final String namaToko = (json['nama_toko'] ?? '').toString().trim();
    final bool isToko = namaToko.isNotEmpty;

    // Backend mungkin mengembalikan 'foto_toko' atau 'foto_profile' atau 'avatar'
    final String rawFotoToko = (json['foto_toko'] ?? '').toString().trim();
    final String rawFotoProfile = (json['foto_profile'] ?? json['avatar'] ?? '').toString().trim();

    String? resolvedFoto;

    if (isToko && rawFotoToko.isNotEmpty) {
      resolvedFoto = getFotoTokoUrl(rawFotoToko);
    } else if (rawFotoProfile.isNotEmpty) {
      if (rawFotoProfile.startsWith('http')) {
        resolvedFoto = rawFotoProfile;
      } else if (isToko) {
        resolvedFoto = getFotoTokoUrl(rawFotoProfile);
      } else {
        resolvedFoto = resolveFullUrl(rawFotoProfile, ApiEndpoints.authendpoints.getFotoProfile);
      }
    }

    return ChatUserModel(
      id: json['id'],
      name: json['name'],
      fotoProfile: (resolvedFoto?.isNotEmpty == true) ? resolvedFoto : null,
      namaToko: json['nama_toko'],
    );
  }
}
