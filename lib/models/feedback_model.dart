// Model untuk fitur Feedback & Chat Admin-Customer
// Arsitektur v2: Per-Admin Session
//   → 1 feedback bisa punya banyak admin session (feedback_admin_sessions)
//   → Setiap sesi = percakapan terpisah Customer ↔ Admin tertentu
//   → Di list Mobile: 1 kartu per sesi admin (bukan per feedback)
import 'package:project_camp_sewa/constants/api_endpoint.dart';

// ─── Helper: resolve URL foto ────────────────────────────────────────────────
String buildAdminFotoUrl(String? foto) {
  if (foto == null || foto.isEmpty) return '';
  if (foto.startsWith('http://') || foto.startsWith('https://')) return foto;
  return '${ApiEndpoints.baseUrl}/assets/image/developers/profiles/$foto';
}

// ─── Model: Admin dalam sesi (embedded di FeedbackItem & FeedbackThread) ────
class FeedbackAdmin {
  final int id;
  final String name;
  final String? foto;

  FeedbackAdmin({required this.id, required this.name, this.foto});

  String get resolvedFotoUrl => buildAdminFotoUrl(foto);
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
  }

  factory FeedbackAdmin.fromJson(Map<String, dynamic> json) {
    return FeedbackAdmin(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Admin',
      foto: json['foto']?.toString(),
    );
  }
}

// ─── Model: Pengirim pesan ringkas (untuk latest_message) ────────────────────
class FeedbackSender {
  final int? id;
  final String? name;
  final String? foto;

  FeedbackSender({this.id, this.name, this.foto});

  factory FeedbackSender.fromJson(Map<String, dynamic> json) {
    return FeedbackSender(
      id: json['id'],
      name: json['name'],
      foto: json['foto'],
    );
  }
}

// ─── Model: Pesan terakhir di list feedback ──────────────────────────────────
class FeedbackLatestMessage {
  final int? id;
  final int? feedbackId;
  final int? senderId;
  final String senderType; // 'admin' | 'customer'
  final String message;
  final String? readAt;
  final String createdAt;
  final FeedbackSender? sender;

  FeedbackLatestMessage({
    this.id,
    this.feedbackId,
    this.senderId,
    required this.senderType,
    required this.message,
    this.readAt,
    required this.createdAt,
    this.sender,
  });

  String get displaySenderName {
    if (senderType == 'admin') return sender?.name ?? 'Admin KampSewa';
    return sender?.name ?? 'Kamu';
  }

  factory FeedbackLatestMessage.fromJson(Map<String, dynamic> json) {
    return FeedbackLatestMessage(
      id: json['id'],
      feedbackId: json['feedback_id'],
      senderId: json['sender_id'],
      senderType: json['sender_type'] ?? 'customer',
      message: json['message'] ?? '',
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      sender: json['sender'] != null
          ? FeedbackSender.fromJson(json['sender'])
          : null,
    );
  }
}

// ─── Model: User singkat (embedded di FeedbackItem) ──────────────────────────
class FeedbackUser {
  final int id;
  final String name;
  final String? email;
  final String? nomorTelephone;
  final String? foto;
  final int type;
  final String? nameStore;

  FeedbackUser({
    required this.id,
    required this.name,
    this.email,
    this.nomorTelephone,
    this.foto,
    required this.type,
    this.nameStore,
  });

  factory FeedbackUser.fromJson(Map<String, dynamic> json) {
    return FeedbackUser(
      id: json['id'],
      name: json['name'] ?? 'User',
      email: json['email'],
      nomorTelephone: json['nomor_telephone'],
      foto: json['foto'],
      type: json['type'] ?? 0,
      nameStore: json['name_store'],
    );
  }
}

// ─── Model: Satu kartu di list (= 1 admin session per feedback) ──────────────
//
// PENTING — Arsitektur v2:
//   Backend kini mengembalikan SATU item per sesi admin.
//   Jika feedback #12 dibalas Admin A dan Admin B, list customer berisi 2 item:
//     • FeedbackItem(id:12, sessionId:1, admin: AdminA)
//     • FeedbackItem(id:12, sessionId:2, admin: AdminB)
//   Jika belum ada yang membalas: FeedbackItem(id:12, sessionId:null, admin:null)
class FeedbackItem {
  final int id;           // feedback_id
  final int? sessionId;   // fallback for old structure
  final String? roomId;   // string unik dari backend
  final int? adminId;     // ID admin lawan bicara (0 atau null jika belum ada)
  final int idUser;
  final String deskripsi;
  final String kriteria;
  final String status; // 'Belum Dibalas' | 'Dibalas'
  final String createdAt;
  final String updatedAt;
  final FeedbackUser? user;
  final FeedbackAdmin? admin;       // admin pemilik sesi ini (null = belum dibalas)
  final FeedbackLatestMessage? latestMessage;
  final int unreadAdminMessagesCount;
  final int unreadCustomerMessagesCount;
  final String? lastAdminName;
  final String? lastAdminFoto;

  FeedbackItem({
    required this.id,
    this.sessionId,
    this.roomId,
    this.adminId,
    required this.idUser,
    required this.deskripsi,
    required this.kriteria,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.admin,
    this.latestMessage,
    this.unreadAdminMessagesCount = 0,
    this.unreadCustomerMessagesCount = 0,
    this.lastAdminName,
    this.lastAdminFoto,
  });

  bool get sudahDibalas =>
      (adminId != null && adminId! > 0) ||
      status == 'Dibalas' ||
      (admin != null && admin!.id > 0);
  bool get belumDibalas => !sudahDibalas;

  /// Nama yang ditampilkan di kartu list
  String get displayName {
    if (admin != null && admin!.name.trim().isNotEmpty) return admin!.name;
    if (lastAdminName != null && lastAdminName!.trim().isNotEmpty) return lastAdminName!;
    if (latestMessage?.senderType == 'admin' &&
        latestMessage?.sender?.name != null &&
        latestMessage!.sender!.name!.isNotEmpty) {
      return latestMessage!.sender!.name!;
    }
    if (status == 'Dibalas') return 'Admin KampSewa';
    return 'Menunggu Admin Pembalas';
  }

  /// URL foto admin sesi ini
  String get adminFotoUrl {
    if (admin != null && admin!.resolvedFotoUrl.isNotEmpty) return admin!.resolvedFotoUrl;
    if (lastAdminFoto != null && lastAdminFoto!.isNotEmpty) return buildAdminFotoUrl(lastAdminFoto);
    if (latestMessage?.senderType == 'admin') return buildAdminFotoUrl(latestMessage?.sender?.foto);
    return '';
  }

  /// Inisial admin untuk fallback avatar
  String get adminInitials {
    if (admin != null) return admin!.initials;
    String nameStr = '';
    if (lastAdminName != null && lastAdminName!.isNotEmpty) {
      nameStr = lastAdminName!;
    } else if (latestMessage?.senderType == 'admin' && latestMessage?.sender?.name != null) {
      nameStr = latestMessage!.sender!.name!;
    } else if (status == 'Dibalas') {
      nameStr = 'Admin KampSewa';
    }
    
    if (nameStr.isNotEmpty) {
      final words = nameStr.trim().split(RegExp(r'\s+'));
      return words.take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    }
    return 'A';
  }

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    // Backend mengirimkan json['id'] sebagai string unik (feedbackId-adminId)
    // dan menyertakan json['feedback_id'] sebagai integer aslinya.
    final rawId = json['id']?.toString() ?? '';
    final feedbackId = json['feedback_id'] != null
        ? (int.tryParse(json['feedback_id'].toString()) ?? 0)
        : (int.tryParse(rawId) ?? 0);

    final parsedAdminId = int.tryParse(json['admin_id']?.toString() ?? '');

    FeedbackAdmin? adminObj;
    if (json['admin'] != null && json['admin'] is Map<String, dynamic>) {
      adminObj = FeedbackAdmin.fromJson(json['admin']);
    } else if (json['last_admin_name'] != null &&
        json['last_admin_name'].toString().trim().isNotEmpty) {
      adminObj = FeedbackAdmin(
        id: parsedAdminId ?? 0,
        name: json['last_admin_name'].toString(),
        foto: json['last_admin_foto']?.toString(),
      );
    }

    return FeedbackItem(
      id: feedbackId,
      sessionId: int.tryParse(json['session_id']?.toString() ?? ''),
      roomId: rawId, // string unik dari backend
      adminId: parsedAdminId ?? adminObj?.id,
      idUser: int.tryParse(json['id_user']?.toString() ?? '') ?? 0,
      deskripsi: json['deskripsi']?.toString() ?? '',
      kriteria: json['kriteria']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Belum Dibalas',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: json['user'] != null ? FeedbackUser.fromJson(json['user']) : null,
      admin: adminObj,
      latestMessage: json['latest_message'] != null
          ? FeedbackLatestMessage.fromJson(json['latest_message'])
          : null,
      unreadAdminMessagesCount: int.tryParse(json['unread_admin_messages_count']?.toString() ?? '0') ?? 0,
      unreadCustomerMessagesCount: int.tryParse(json['unread_customer_messages_count']?.toString() ?? '0') ?? 0,
      lastAdminName: json['last_admin_name']?.toString() ?? adminObj?.name,
      lastAdminFoto: json['last_admin_foto']?.toString() ?? adminObj?.foto,
    );
  }
}

// ─── Model: Satu pesan chat ───────────────────────────────────────────────────
class FeedbackMessage {
  /// id bisa string 'initial-{id}' atau angka
  final String id;
  final int feedbackId;
  final int? sessionId;
  final String senderType; // 'admin' | 'customer'
  final int? senderId;
  final String senderName;
  final String? senderFoto;
  final String message;
  final String? readAt;
  final String createdAt;
  final bool isInitial;

  FeedbackMessage({
    required this.id,
    required this.feedbackId,
    this.sessionId,
    required this.senderType,
    this.senderId,
    required this.senderName,
    this.senderFoto,
    required this.message,
    this.readAt,
    required this.createdAt,
    this.isInitial = false,
  });

  bool get isFromAdmin => senderType == 'admin';
  String get resolvedFotoUrl => buildAdminFotoUrl(senderFoto);
  String get senderInitials {
    if (senderName.trim().isEmpty) return isFromAdmin ? 'A' : 'U';
    final words = senderName.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
  }

  factory FeedbackMessage.fromJson(Map<String, dynamic> json) {
    return FeedbackMessage(
      id: json['id']?.toString() ?? '',
      feedbackId: json['feedback_id'] ?? 0,
      sessionId: json['session_id'],
      senderType: json['sender_type'] ?? 'customer',
      senderId: json['sender_id'],
      senderName: json['sender_name'] ?? '',
      senderFoto: json['sender_foto'],
      message: json['message'] ?? '',
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      isInitial: json['is_initial'] == true,
    );
  }
}

// ─── Model: Header thread dari GET /api/feedback/{id}/messages?session_id={s} ─
class FeedbackThread {
  final int id;           // feedback_id
  final int? sessionId;   // session ID yang sedang dibuka
  final int idUser;
  final String customerName;
  final String kriteria;
  final String status;
  final String createdAt;
  final FeedbackAdmin? admin; // admin pemilik sesi ini

  FeedbackThread({
    required this.id,
    this.sessionId,
    required this.idUser,
    required this.customerName,
    required this.kriteria,
    required this.status,
    required this.createdAt,
    this.admin,
  });

  /// Nama di AppBar: nama admin sesi, atau "Menunggu Admin Pembalas"
  String get appBarName {
    if (admin != null && admin!.name.trim().isNotEmpty) return admin!.name;
    if (status == 'Dibalas') return 'Admin KampSewa';
    return 'Menunggu Admin Pembalas';
  }

  /// URL foto AppBar
  String get appBarFotoUrl => admin?.resolvedFotoUrl ?? '';

  /// Inisial untuk fallback avatar AppBar
  String get appBarInitials => admin?.initials ?? 'A';

  bool get isMenunggu {
    if (admin != null && admin!.id > 0) return false;
    return status != 'Dibalas';
  }

  factory FeedbackThread.fromJson(Map<String, dynamic> json) {
    final parsedAdminId = int.tryParse(json['admin_id']?.toString() ?? '');
    FeedbackAdmin? adminObj;
    if (json['admin'] != null && json['admin'] is Map<String, dynamic>) {
      adminObj = FeedbackAdmin.fromJson(json['admin']);
    } else if (json['last_admin_name'] != null &&
        json['last_admin_name'].toString().trim().isNotEmpty) {
      adminObj = FeedbackAdmin(
        id: parsedAdminId ?? 0,
        name: json['last_admin_name'].toString(),
        foto: json['last_admin_foto']?.toString(),
      );
    }

    return FeedbackThread(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      sessionId: int.tryParse(json['session_id']?.toString() ?? ''),
      idUser: int.tryParse(json['id_user']?.toString() ?? '') ?? 0,
      customerName: json['customer_name']?.toString() ?? '',
      kriteria: json['kriteria']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      admin: adminObj,
    );
  }
}
