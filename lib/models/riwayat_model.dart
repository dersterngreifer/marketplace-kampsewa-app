class RiwayatModel {
  final int id;
  final int idProduk;
  final String namaToko;
  final String namaProduk;
  final String qty;
  final String warna;
  final String ukuran;
  final String qtyProdukLain;
  final String rating;
  final String harga;
  final String totalPesanan;
  final String hari;
  final String fotoProduk;
  final String statusTransaksi;
  final String? rekeningBank;
  final String? namaBank;
  final String? metode;
  final List<RiwayatItemModel> items;
  final String? waktuDeadlinePengembalian;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final bool isTerlambat;
  final String? durasiTerlambat;
  final int? nominalDenda;
  final String? statusDenda;
  final int? nominalDendaTersimpan;
  final String? statusPembayaran;
  final String? buktiPembayaran;
  final String? jenisTransaksi;
  final String? opsiPengiriman;
  final int? biayaAntar;
  final String? alamatPengiriman;

  const RiwayatModel({
    required this.id,
    this.idProduk = 0,
    required this.namaToko,
    required this.namaProduk,
    required this.fotoProduk,
    required this.qty,
    required this.warna,
    required this.ukuran,
    required this.qtyProdukLain,
    required this.rating,
    required this.harga,
    required this.totalPesanan,
    required this.hari,
    required this.statusTransaksi,
    this.rekeningBank,
    this.namaBank,
    this.metode,
    this.items = const [],
    this.waktuDeadlinePengembalian,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.isTerlambat = false,
    this.durasiTerlambat,
    this.nominalDenda,
    this.statusDenda,
    this.nominalDendaTersimpan,
    this.statusPembayaran,
    this.buktiPembayaran,
    this.jenisTransaksi,
    this.opsiPengiriman,
    this.biayaAntar,
    this.alamatPengiriman,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? [];
    final firstItem = items.isNotEmpty ? items.first : {};

    int totalItem = json['total_item'] ?? 1;
    String qtyLain = json['qty_produk_lain']?.toString() ?? (totalItem > 1 ? (totalItem - 1).toString() : '0');

    int parsedIdProduk = 0;
    if (json['id_produk'] != null) {
      parsedIdProduk = int.tryParse(json['id_produk'].toString()) ?? 0;
    } else if (firstItem['id_produk'] != null) {
      parsedIdProduk = int.tryParse(firstItem['id_produk'].toString()) ?? 0;
    }

    String hariRaw = json['durasi_hari']?.toString() ?? json['hari']?.toString() ?? '0';
    String hariFinal = hariRaw.replaceAll(RegExp(r'[^0-9]'), '');
    if (hariFinal.isEmpty) hariFinal = '0';

    return RiwayatModel(
      id: json['id_penyewaan'] ?? json['id_transaksi'] ?? 0,
      idProduk: parsedIdProduk,
      namaToko: json['nama_toko'] ?? '',
      namaProduk: firstItem['nama_produk'] ?? json['nama_produk'] ?? '',
      fotoProduk: firstItem['foto_produk'] ?? json['foto_produk'] ?? '',
      qty: firstItem['qty']?.toString() ?? json['qty']?.toString() ?? '0',
      warna: firstItem['warna'] ?? json['variasi_warna'] ?? '',
      ukuran: firstItem['ukuran'] ?? json['variasi_ukuran'] ?? '',
      qtyProdukLain: qtyLain,
      rating: json['rating']?.toString() ?? '0',
      harga: (firstItem['subtotal'] != null && firstItem['qty'] != null) 
          ? ((int.tryParse(firstItem['subtotal'].toString()) ?? 0) ~/ (int.tryParse(firstItem['qty'].toString()) ?? 1)).toString()
          : json['harga']?.toString() ?? '0',
      totalPesanan: json['total_pembayaran']?.toString() ?? json['total_pesanan']?.toString() ?? '0',
      hari: hariFinal,
      statusTransaksi: json['status_transaksi'] ?? '',
      rekeningBank: json['rekening_bank']?.toString(),
      namaBank: json['nama_bank']?.toString(),
      metode: json['metode_pembayaran']?.toString() ?? json['metode']?.toString(),
      waktuDeadlinePengembalian: json['waktu_deadline_pengembalian']?.toString(),
      tanggalMulai: json['tanggal_mulai']?.toString() ?? json['tgl_mulai']?.toString() ?? json['tanggal_sewa']?.toString() ?? json['mulai_sewa']?.toString(),
      tanggalSelesai: json['tanggal_selesai']?.toString() ?? json['tgl_selesai']?.toString() ?? json['tanggal_kembali']?.toString() ?? json['kembali_sewa']?.toString(),
      isTerlambat: json['is_terlambat'] == true || json['is_terlambat'] == 1 || json['is_terlambat'] == '1' || json['is_terlambat'] == 'true',
      durasiTerlambat: json['durasi_terlambat']?.toString(),
      nominalDenda: (json['nominal_denda'] != null) ? int.tryParse(json['nominal_denda'].toString()) : null,
      statusDenda: json['status_denda']?.toString(),
      nominalDendaTersimpan: (json['nominal_denda_tersimpan'] != null) ? int.tryParse(json['nominal_denda_tersimpan'].toString()) : null,
      statusPembayaran: json['status_pembayaran']?.toString(),
      buktiPembayaran: json['bukti_pembayaran']?.toString(),
      jenisTransaksi: json['jenis_transaksi']?.toString(),
      opsiPengiriman: json['opsi_pengiriman']?.toString(),
      biayaAntar: json['biaya_antar'] != null ? int.tryParse(json['biaya_antar'].toString()) : null,
      alamatPengiriman: json['alamat_pengiriman']?.toString(),
      items: List<RiwayatItemModel>.from(
        (json['items'] as List<dynamic>? ?? []).map(
          (e) => RiwayatItemModel.fromJson(Map<String, dynamic>.from(e as Map))
        )
      ),
    );
  }

  /// Mengecek apakah metode transaksi adalah COD (Bayar di tempat)
  bool get isCOD {
    final m = (metode ?? '').toLowerCase().trim();
    return m == 'cod' || m.contains('ditempat') || m.contains('di tempat') || m.contains('cash');
  }

  /// Mengecek apakah bukti pembayaran transfer sudah diunggah oleh user
  bool get hasUploadedBukti {
    final b = (buktiPembayaran ?? '').trim().toLowerCase();
    return b.isNotEmpty && b != 'belum di isi' && b != 'null';
  }

  /// Mengecek apakah pesanan sedang menunggu verifikasi pembayaran oleh toko
  bool get isMenungguVerifikasi {
    final sp = (statusPembayaran ?? '').toLowerCase().trim();
    final st = statusTransaksi.toLowerCase().trim();
    return sp == 'menunggu verifikasi' ||
        sp == 'menunggu_verifikasi' ||
        st == 'menunggu verifikasi' ||
        st == 'menunggu_verifikasi' ||
        hasUploadedBukti;
  }

  /// Menentukan apakah tombol pembayaran transfer ("Lakukan Pembayaran" / "Bayar Sekarang")
  /// harus dimunculkan kepada user.
  /// Tombol HANYA muncul jika:
  /// 1. Metode bayar BUKAN COD.
  /// 2. Pembayaran BELUM menunggu verifikasi (belum upload bukti transfer dan KTP).
  /// 3. Status transaksi masih "Belum Bayar" / "Pending" (misal user menutup halaman pembayaran).
  bool get isPerluBayarTransfer {
    if (isCOD) return false;
    if (isMenungguVerifikasi) return false;
    final st = statusTransaksi.toLowerCase().trim();
    final sp = (statusPembayaran ?? '').toLowerCase().trim();
    if (sp == 'lunas' || st == 'lunas' || st == 'selesai' || st == 'pengambilan' || st == 'berlangsung' || st == 'dibatalkan') {
      return false;
    }
    return (st == 'belum bayar' || st == 'belum-bayar' || st == 'pending');
  }
}

class RiwayatItemModel {
  final int idProduk;
  final String namaProduk;
  final String fotoProduk;
  final String qty;
  final String ukuran;
  final String warna;
  final String subtotal;
  final String hargaSatuan;

  RiwayatItemModel({
    required this.idProduk,
    required this.namaProduk,
    required this.fotoProduk,
    required this.qty,
    required this.ukuran,
    required this.warna,
    required this.subtotal,
    required this.hargaSatuan,
  });

  factory RiwayatItemModel.fromJson(Map<String, dynamic> json) {
    String q = json['qty']?.toString() ?? '1';
    String s = json['subtotal']?.toString() ?? json['harga']?.toString() ?? '0';
    String h = ((int.tryParse(s) ?? 0) ~/ (int.tryParse(q) ?? 1)).toString();
    return RiwayatItemModel(
      idProduk: json['id_produk'] ?? 0,
      namaProduk: json['nama_produk'] ?? '',
      fotoProduk: json['foto_produk'] ?? '',
      qty: q,
      ukuran: json['ukuran'] ?? json['variasi_ukuran'] ?? '',
      warna: json['warna'] ?? json['variasi_warna'] ?? '',
      subtotal: s,
      hargaSatuan: h,
    );
  }
}
