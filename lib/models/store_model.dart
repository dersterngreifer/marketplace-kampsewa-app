class StoreAlamatModel {
  final String? provinsi;
  final String? kota;
  final String? detailAlamat;

  StoreAlamatModel({
    this.provinsi,
    this.kota,
    this.detailAlamat,
  });

  factory StoreAlamatModel.fromJson(Map<String, dynamic> json) {
    return StoreAlamatModel(
      provinsi: json['provinsi']?.toString(),
      kota: json['kota']?.toString(),
      detailAlamat: json['detail_alamat']?.toString(),
    );
  }

  /// Mengembalikan string lokasi dalam format "Kota, Provinsi"
  String get displayLocation {
    final parts = <String>[];
    if (kota != null && kota!.isNotEmpty) parts.add(kota!);
    if (provinsi != null && provinsi!.isNotEmpty) parts.add(provinsi!);
    return parts.join(', ');
  }
}

class ActivePromoModel {
  final int idPromo;
  final String judulPromo;
  final String deskripsi;
  final String tipeDiskon;
  final double nilaiDiskon;
  final String cakupan;
  final String? tanggalSelesai;

  ActivePromoModel({
    required this.idPromo,
    required this.judulPromo,
    required this.deskripsi,
    required this.tipeDiskon,
    required this.nilaiDiskon,
    required this.cakupan,
    this.tanggalSelesai,
  });

  factory ActivePromoModel.fromJson(Map<String, dynamic> json) {
    return ActivePromoModel(
      idPromo: json['id_promo'] is int
          ? json['id_promo']
          : int.tryParse(json['id_promo']?.toString() ?? '0') ?? 0,
      judulPromo: json['judul_promo']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      tipeDiskon: json['tipe_diskon']?.toString() ?? 'persen',
      nilaiDiskon:
          double.tryParse(json['nilai_diskon']?.toString() ?? '0') ?? 0.0,
      cakupan: json['cakupan']?.toString() ?? 'all_products',
      tanggalSelesai: json['tanggal_selesai']?.toString(),
    );
  }
}

/// Program diskon produk aktif milik sebuah toko.
///
/// Sumber: `GET /api/diskon/toko/{id_toko}`. Terpisah dari fitur iklan
/// (banner promosi berbayar) — ini murni potongan harga sewa produk.
class DiskonTokoModel {
  final int idDiskon;
  final String namaDiskon;
  final String tipeDiskon;
  final double nilaiDiskon;
  final String labelDiskon;
  final String cakupan;
  final String? tanggalMulai;
  final String? tanggalSelesai;

  DiskonTokoModel({
    required this.idDiskon,
    required this.namaDiskon,
    required this.tipeDiskon,
    required this.nilaiDiskon,
    required this.labelDiskon,
    required this.cakupan,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  bool get isSemuaProduk => cakupan == 'all_products';

  factory DiskonTokoModel.fromJson(Map<String, dynamic> json) {
    final double nilai =
        double.tryParse(json['nilai_diskon']?.toString() ?? '0') ?? 0.0;
    final String tipe = json['tipe_diskon']?.toString() ?? 'persen';
    final String? label = json['label_diskon']?.toString();

    return DiskonTokoModel(
      idDiskon: json['id_diskon'] is int
          ? json['id_diskon']
          : int.tryParse(json['id_diskon']?.toString() ?? '0') ?? 0,
      namaDiskon: json['nama_diskon']?.toString() ?? '',
      tipeDiskon: tipe,
      nilaiDiskon: nilai,
      // Fallback jika label tidak dikirim backend.
      labelDiskon: (label != null && label.isNotEmpty)
          ? label
          : (tipe == 'persen' ? '${nilai.toInt()}%' : 'Rp ${nilai.toInt()}'),
      cakupan: json['cakupan']?.toString() ?? 'all_products',
      tanggalMulai: json['tanggal_mulai']?.toString(),
      tanggalSelesai: json['tanggal_selesai']?.toString(),
    );
  }
}

class StoreModel {
  final int idUser;
  final String namaStore;
  final String deskripsiToko;
  final String? fotoToko;
  final String? bannerToko;
  final double ratingToko;
  final int totalUlasan;
  final int totalProdukAktif;
  final int totalTransaksiSelesai;
  final StoreAlamatModel? alamat;
  final String? tanggalBergabung;
  final ActivePromoModel? activePromo;

  /// Email pemilik toko — dipakai untuk menyusun URL share profil toko
  /// (`abbmamarketplacekampsewa.com/{email}`).
  final String? email;

  /// Jumlah akun yang mem-follow toko/user ini.
  final int totalFollowers;

  /// Jumlah akun yang di-follow oleh toko/user ini.
  final int totalFollowing;

  /// True jika user yang sedang login sudah mem-follow profil ini.
  /// Digunakan untuk menentukan state tombol "Ikuti" / "Mengikuti".
  final bool isFollowedByMe;

  /// True jika profil ini adalah mitra/toko. False jika pengguna reguler.
  final bool isToko;

  StoreModel({
    required this.idUser,
    required this.namaStore,
    required this.deskripsiToko,
    this.fotoToko,
    this.bannerToko,
    required this.ratingToko,
    required this.totalUlasan,
    required this.totalProdukAktif,
    required this.totalTransaksiSelesai,
    this.alamat,
    this.tanggalBergabung,
    this.activePromo,
    this.email,
    this.totalFollowers = 0,
    this.totalFollowing = 0,
    this.isFollowedByMe = false,
    this.isToko = true, // Default true untuk legacy data
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    StoreAlamatModel? alamat;
    if (json['alamat'] != null && json['alamat'] is Map) {
      alamat = StoreAlamatModel.fromJson(
          json['alamat'] as Map<String, dynamic>);
    }

    ActivePromoModel? activePromo;
    if (json['active_promo'] != null && json['active_promo'] is Map) {
      activePromo = ActivePromoModel.fromJson(
          Map<String, dynamic>.from(json['active_promo'] as Map));
    }

    return StoreModel(
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.tryParse(json['id_user']?.toString() ?? '0') ?? 0,
      namaStore: json['nama_store']?.toString() ?? '',
      deskripsiToko: json['deskripsi_toko']?.toString() ?? '',
      fotoToko: json['foto_toko']?.toString(),
      bannerToko: json['banner_toko']?.toString(),
      ratingToko:
          double.tryParse(json['rating_toko']?.toString() ?? '0') ?? 0.0,
      totalUlasan: json['total_ulasan'] is int
          ? json['total_ulasan']
          : int.tryParse(json['total_ulasan']?.toString() ?? '0') ?? 0,
      totalProdukAktif: json['total_produk_aktif'] is int
          ? json['total_produk_aktif']
          : int.tryParse(json['total_produk_aktif']?.toString() ?? '0') ?? 0,
      totalTransaksiSelesai: json['total_transaksi_selesai'] is int
          ? json['total_transaksi_selesai']
          : int.tryParse(
                  json['total_transaksi_selesai']?.toString() ?? '0') ??
              0,
      alamat: alamat,
      tanggalBergabung: json['tanggal_bergabung']?.toString(),
      activePromo: activePromo,
      email: json['email']?.toString(),
      totalFollowers: json['total_followers'] is int
          ? json['total_followers']
          : int.tryParse(json['total_followers']?.toString() ?? '0') ?? 0,
      totalFollowing: json['total_following'] is int
          ? json['total_following']
          : int.tryParse(json['total_following']?.toString() ?? '0') ?? 0,
      isFollowedByMe: json['is_followed_by_me'] == true,
      isToko: json['is_toko'] == null ? true : json['is_toko'] == true,
    );
  }

  /// Format tanggal bergabung ke bentuk yang lebih ramah (mis. "Januari 2025")
  String get formattedJoinDate {
    if (tanggalBergabung == null || tanggalBergabung!.isEmpty) return '';
    try {
      final dt = DateTime.parse(tanggalBergabung!);
      const bulan = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${bulan[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return tanggalBergabung!;
    }
  }
}
