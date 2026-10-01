class ApiEndpoints {
  static const String baseUrl = "http://192.168.0.2:8000";

  /// Domain publik KampSewa Marketplace, dipakai untuk link yang dibagikan
  /// (share/deep-link) profil toko.
  static const String webDomain = "abbmamarketplacekampsewa.com";

  static AuthEndPoints authendpoints = AuthEndPoints();
}

/// Membangun URL profil toko publik yang bisa dibagikan ke orang lain.
///
/// Format: `https://abbmamarketplacekampsewa.com/{emailUser}`
///
/// [emailUser] adalah email pemilik toko. Kalau emailnya belum tersedia,
/// pemanggil boleh mengoper nilai cadangan (mis. nama toko) supaya link tetap
/// berisi path yang bisa dibuka.
String getShareProfileTokoUrl(String? emailUser) {
  final String slug = (emailUser ?? '').trim();
  if (slug.isEmpty) return 'https://${ApiEndpoints.webDomain}';
  return 'https://${ApiEndpoints.webDomain}/$slug';
}

String getImageUrl(String? imageUrl, {bool fallbackAvatar = true}) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return fallbackAvatar
        ? 'https://ui-avatars.com/api/?name=User&background=random'
        : '';
  }
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    if (imageUrl.contains('localhost') || imageUrl.contains('127.0.0.1')) {
      final uri = Uri.tryParse(imageUrl);
      if (uri != null) {
        return '${ApiEndpoints.baseUrl}${uri.path}';
      }
    }
    return imageUrl;
  }

  // The UI components (e.g. Profile, Dashboard, Keranjang) will prepend
  // the specific folder paths like /assets/image/customers/profile/
  // So we just return the raw filename.
  return imageUrl;
}

String resolveFullUrl(String path, String defaultPrefix) {
  if (path.isEmpty) return '';
  path = path.trim();
  if (path.startsWith('http://') || path.startsWith('https://')) {
    if (path.contains('localhost') || path.contains('127.0.0.1')) {
      final uri = Uri.tryParse(path);
      if (uri != null) {
        return '${ApiEndpoints.baseUrl}${uri.path}';
      }
    }
    return path;
  }

  if (path.startsWith('/')) path = path.substring(1);

  String cleanPrefix = defaultPrefix.startsWith('/')
      ? defaultPrefix.substring(1)
      : defaultPrefix;
  if (path.startsWith(cleanPrefix)) {
    return '${ApiEndpoints.baseUrl}/$path';
  }

  if (path.startsWith('assets/') || path.startsWith('storage/')) {
    return '${ApiEndpoints.baseUrl}/$path';
  }

  return '${ApiEndpoints.baseUrl}$defaultPrefix$path';
}

String getFotoIdentitasUrl(String? filename) {
  if (filename == null || filename.isEmpty) {
    return '';
  }
  if (filename.startsWith('http://') || filename.startsWith('https://')) {
    return filename;
  }
  return '${ApiEndpoints.baseUrl}/assets/image/customers/identitas/$filename';
}

String getBannerTokoUrl(String? filename) {
  if (filename == null || filename.isEmpty) {
    return '';
  }
  return resolveFullUrl(filename.trim(), '/assets/image/customers/banner/');
}

/// Membangun URL foto logo toko dari folder `/assets/image/customers/logo_toko/`.
///
/// Menangani semua format: URL absolut (http/https), path relatif (dimulai /),
/// path parsial (assets/image/...), atau nama file mentah.
/// Mengembalikan `''` untuk nilai kosong atau placeholder server.
String getFotoTokoUrl(String? filename) {
  if (filename == null || filename.isEmpty) {
    return '';
  }
  final String trimmed = filename.trim();
  // Tolak placeholder
  if (trimmed == 'placeholder-image.png' ||
      trimmed.endsWith('/placeholder-image.png')) {
    return '';
  }
  return resolveFullUrl(trimmed, '/assets/image/customers/logo_toko/');
}

class AuthEndPoints {
  final String getFotoProfile = "/assets/image/customers/profile/";
  final String getImageIklan = "/assets/image/customers/advert/";
  final String getImageProduk = "/assets/image/customers/produk/";
  final String login = "/api/login";
  final String register = "/api/register";
  final String logout = "/api/logout";
  final String lupaPass = "/api/lupa-password";
  final String lupaPassOTP = "/api/lupa-password/verifikasi-otp/";
  final String lupaPassResetPass = "/api/lupa-password/reset-password/";
  final String lupaPassKirimUlangOTP = "/api/lupa-password/kirim-ulang-otp/";
  final String getDataUser = "/api/user/";
  final String isiDataToko = "/api/user/input-store/";
  final String inputKYC = "/api/user/input-kyc/";
  final String verifyKTP = "/api/user/verify-ktp";
  final String updateDataUser = "/api/user/update-profile/";
  final String tambahAlamatUser = "/api/user/tambah-alamat";
  final String getAlamatUser = "/api/user/list-alamat/";
  final String updateAlamatUser = "/api/user/update-alamat/";
  final String deleteAlamatUser = "/api/user/delete-alamat/";
  final String tambahBankMetodeTransfer = "/api/user/tambah-bank/";
  final String getIklan = "/api/iklan";
  final String getProdukRekomendasiPencarian =
      "/api/produk/rekomendasi-pencarian";
  final String getProduk = "/api/produk/";
  final String getProdukBottomSheet = "/api/produk/detail-keranjang-produk/";
  final String getDetailProduk = "/api/produk/detail-produk/";
  final String getUserProducts = "/api/produk/user-products";
  final String insertRiwayatCari = "/api/riwayat-pencarian/insert/";
  final String showRiwayatCari = "/api/riwayat-pencarian/show/";
  final String deleteRiwayatCari = "/api/riwayat-pencarian/delete/";
  final String transaksiCheckout = "/api/transaksi/checkout/";
  final String getAlamatTokoCheckout = "/api/transaksi/lokasi-toko";
  final String getBankOpsiPembayaranTransfer = "/api/transaksi/bank-toko";
  final String transaksiPembayaran = "/api/transaksi/pembayaran";
  final String getStatistikPesanan = "/api/statistik-pesanan/";

  // ── Public Store Endpoints ──────────────────────────────────────────────────
  /// GET /api/store/{id_user} — Profil toko publik
  final String getStoreProfile = "/api/store/";

  /// GET /api/store/{id_user}/products — List produk toko publik (filter + search)
  /// Gunakan bersama [getStoreProfile]: "/api/store/{id_user}/products"
  final String getStoreProducts = "/api/store/";

  // ── Feedback & Chat Endpoints ────────────────────────────────────────────
  /// POST /api/feedback                    — Buat feedback baru (Customer only)
  final String postFeedback = "/api/feedback";

  /// GET  /api/chat-room                   — Daftar percakapan / Room (Customer: miliknya, Admin: semua)
  final String chatRoom = "/api/chat-room";

  /// GET  /api/chat-room/{feedback_id}/{admin_id}/messages      — Ambil isi chat + mark-as-read
  /// POST /api/chat-room/{feedback_id}/{admin_id}/messages      — Kirim pesan
  String chatRoomMessages(int feedbackId, int adminId) => "/api/chat-room/$feedbackId/$adminId/messages";

  // ── Follow / Unfollow Endpoints ─────────────────────────────────────────────
  /// POST /api/follow/{user_id} — Follow akun user
  String followUser(int userId) => "/api/follow/$userId";

  /// POST /api/unfollow/{user_id} atau DELETE /api/follow/{user_id} — Unfollow akun user
  String unfollowUser(int userId) => "/api/unfollow/$userId";

  /// GET /api/user/{user_id}/followers — List user yang mem-follow user tersebut
  String getFollowers(int userId) => "/api/user/$userId/followers";

  /// GET /api/user/{user_id}/following — List user yang difollow oleh user tersebut
  String getFollowing(int userId) => "/api/user/$userId/following";
}


