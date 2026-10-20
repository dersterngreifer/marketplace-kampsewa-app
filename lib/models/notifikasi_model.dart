class NotifikasiModel {
  final int id;
  final int idUser;
  final String tipe;
  final int? idReferensi;
  final String judul;
  final String pesan;
  final String? alasan;
  final String? url;
  bool isRead;
  final String createdAt;

  NotifikasiModel({
    required this.id,
    required this.idUser,
    required this.tipe,
    this.idReferensi,
    required this.judul,
    required this.pesan,
    this.alasan,
    this.url,
    this.isRead = false,
    required this.createdAt,
  });

  bool get isSuspend => tipe == 'produk_suspend';
  bool get isPulih => tipe == 'produk_pulih' || tipe == 'produk_aktif';
  bool get isUlasanMilestone =>
      tipe == 'ulasan_milestone' || tipe == 'ulasan_produk';
  bool get isIklan => tipe.startsWith('iklan_');
  bool get isPesanan =>
      tipe.startsWith('pesanan_') ||
      tipe.startsWith('transaksi_') ||
      tipe == 'pembayaran_masuk';
  bool get isWebOnly => isSuspend || isIklan;

  /// Menentukan tab index target pada RiwayatScreen (0: Pembayaran, 1: Pengambilan, 2: Berlangsung, 3: Selesai, 4: Denda, 5: Dibatalkan)
  int? get targetRiwayatTabIndex {
    switch (tipe) {
      case 'pesanan_masuk':
      case 'pembayaran_masuk':
      case 'pesanan_bayar':
        return 0; // Pembayaran
      case 'pesanan_disetujui':
      case 'pesanan_approved':
      case 'pesanan_siap_ambil':
      case 'siap_ambil':
        return 1; // Pengambilan
      case 'pesanan_diambil':
      case 'pesanan_berlangsung':
      case 'pesanan_aktif':
        return 2; // Berlangsung
      case 'pesanan_selesai':
        return 3; // Selesai
      case 'pesanan_denda':
      case 'denda':
      case 'denda_belum_lunas':
        return 4; // Denda Belum Lunas
      case 'pesanan_dibatalkan':
      case 'pesanan_batal':
        return 5; // Dibatalkan
      default:
        if (tipe.contains('denda')) return 4;
        if (tipe.contains('ambil') || tipe.contains('setuju')) return 1;
        if (tipe.contains('berlangsung') || tipe.contains('aktif')) return 2;
        if (tipe.contains('selesai')) return 3;
        if (tipe.contains('batal')) return 5;
        return isPesanan ? 1 : null;
    }
  }

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.tryParse(json['id_user']?.toString() ?? '0') ?? 0,
      tipe: json['tipe']?.toString() ?? '',
      idReferensi: json['id_referensi'] is int
          ? json['id_referensi']
          : int.tryParse(json['id_referensi']?.toString() ?? ''),
      judul: json['judul']?.toString() ?? '',
      pesan: json['pesan']?.toString() ?? '',
      alasan: json['alasan']?.toString(),
      url: json['url']?.toString(),
      isRead: json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read'] == '1',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'tipe': tipe,
      'id_referensi': idReferensi,
      'judul': judul,
      'pesan': pesan,
      'alasan': alasan,
      'url': url,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}
