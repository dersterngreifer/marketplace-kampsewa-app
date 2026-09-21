class ApiEndpoints {
  static const String baseUrl = "http://192.168.0.2:8000";
  static AuthEndPoints authendpoints = AuthEndPoints();
}

String getImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return 'https://ui-avatars.com/api/?name=User&background=random';
  }
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }

  const String baseHost = ApiEndpoints.baseUrl;

  if (imageUrl.startsWith('/')) {
    imageUrl = imageUrl.substring(1);
  }

  if (imageUrl.startsWith('storage/')) {
    imageUrl = imageUrl.substring(8);
  }

  return '$baseHost/$imageUrl';
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
  if (filename.startsWith('http://') || filename.startsWith('https://')) {
    return filename;
  }
  return '${ApiEndpoints.baseUrl}/assets/image/customers/banner/$filename';
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
}
