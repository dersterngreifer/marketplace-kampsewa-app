import 'package:project_camp_sewa/constants/api_endpoint.dart';

/// Model yang merepresentasikan satu item user di dalam list
/// followers / following yang dikembalikan backend.
class FollowUserModel {
  final int id;
  final String name;

  /// URL avatar lengkap (sudah di-resolve dengan base URL + path folder).
  /// Bisa kosong string jika user tidak punya foto.
  final String avatar;

  /// True jika user yang sedang login sudah mem-follow akun ini.
  final bool isFollowedByMe;

  /// True jika user ini memiliki toko (mitra).
  final bool isToko;

  /// Tanggal & waktu follow terjadi (di-pivot table backend).
  final DateTime? createdAt;

  FollowUserModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isFollowedByMe,
    this.isToko = false,
    this.createdAt,
  });

  /// Mengembalikan true jika follow terjadi dalam kurun waktu 24 jam terakhir.
  bool get isNew {
    if (createdAt == null) return false;
    final diff = DateTime.now().difference(createdAt!);
    return diff.inHours < 24 && diff.inMinutes >= -60;
  }

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    // Prioritaskan nama_store jika ada dan tidak kosong, jika tidak gunakan name biasa
    final String nameStore = json['name_store']?.toString() ?? '';
    final String userName = json['name']?.toString() ?? '';
    final String displayName = nameStore.isNotEmpty ? nameStore : userName;

    final bool isUserToko = json['is_toko'] == true;
    final String? rawAvatar = json['avatar']?.toString();
    
    // Resolve full URL tergantung tipe user (toko vs user biasa)
    String resolvedAvatar = '';
    if (rawAvatar != null && rawAvatar.isNotEmpty) {
      if (isUserToko) {
        resolvedAvatar = getFotoTokoUrl(rawAvatar);
      } else {
        resolvedAvatar = resolveFullUrl(rawAvatar, '/assets/image/customers/profile/');
      }
    }

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null && json['created_at'].toString().isNotEmpty) {
      parsedCreatedAt =
          DateTime.tryParse(json['created_at'].toString())?.toLocal();
    }

    return FollowUserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: displayName,
      avatar: resolvedAvatar,
      isFollowedByMe: json['is_followed_by_me'] == true,
      isToko: isUserToko,
      createdAt: parsedCreatedAt,
    );
  }

  /// Membuat salinan model dengan field yang diubah.
  FollowUserModel copyWith({
    bool? isFollowedByMe,
    DateTime? createdAt,
  }) {
    return FollowUserModel(
      id: id,
      name: name,
      avatar: avatar,
      isFollowedByMe: isFollowedByMe ?? this.isFollowedByMe,
      isToko: isToko,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
