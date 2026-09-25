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
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    StoreAlamatModel? alamat;
    if (json['alamat'] != null && json['alamat'] is Map) {
      alamat = StoreAlamatModel.fromJson(
          json['alamat'] as Map<String, dynamic>);
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
