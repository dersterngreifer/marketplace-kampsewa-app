import 'package:intl/intl.dart';

/// Memformat angka ke format mata uang Indonesia (contoh: 50000 -> "50.000").
String formatCurrency(num number) {
  try {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  } catch (_) {
    return number.toString();
  }
}

/// Model untuk program diskon produk milik mitra (dari `GET /api/mitra/diskon`).
class MitraDiskonModel {
  final int idPromo;
  final String namaDiskon;
  final String tipeDiskon;
  final double nilaiDiskon;
  final String cakupan;
  final String konflikDiskon;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final bool isActive;
  final String status;
  final bool isCurrentlyActive;
  final int totalProduk;
  final List<int> selectedProductIds;
  final List<dynamic> produkList;
  final String? createdAt;

  MitraDiskonModel({
    required this.idPromo,
    required this.namaDiskon,
    required this.tipeDiskon,
    required this.nilaiDiskon,
    required this.cakupan,
    required this.konflikDiskon,
    this.tanggalMulai,
    this.tanggalSelesai,
    required this.isActive,
    required this.status,
    required this.isCurrentlyActive,
    required this.totalProduk,
    this.selectedProductIds = const [],
    this.produkList = const [],
    this.createdAt,
  });

  bool get isSemuaProduk => cakupan == 'all_products';
  bool get isReplace => konflikDiskon == 'replace';

  String get labelDiskon {
    if (tipeDiskon == 'persen') {
      final int persen = nilaiDiskon.toInt();
      return '$persen%';
    } else {
      final int nominal = nilaiDiskon.toInt();
      return 'Rp ${formatCurrency(nominal)}';
    }
  }

  factory MitraDiskonModel.fromJson(Map<String, dynamic> json) {
    final double nilai =
        double.tryParse(json['nilai_diskon']?.toString() ?? '0') ?? 0.0;

    List<int> selectedIds = [];
    if (json['selected_product_ids'] is List) {
      selectedIds = (json['selected_product_ids'] as List)
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    } else if (json['produk'] is List) {
      selectedIds = (json['produk'] as List)
          .map((p) => p is Map ? (int.tryParse(p['id']?.toString() ?? '0') ?? 0) : 0)
          .where((id) => id > 0)
          .toList();
    }

    return MitraDiskonModel(
      idPromo: json['id_promo'] is int
          ? json['id_promo']
          : int.tryParse(json['id_promo']?.toString() ?? '0') ?? 0,
      namaDiskon: json['nama_diskon']?.toString() ??
          json['judul_promo']?.toString() ??
          'Diskon Toko',
      tipeDiskon: json['tipe_diskon']?.toString() ?? 'persen',
      nilaiDiskon: nilai,
      cakupan: json['cakupan']?.toString() ?? 'all_products',
      konflikDiskon: json['konflik_diskon']?.toString() ?? 'replace',
      tanggalMulai: json['tanggal_mulai']?.toString(),
      tanggalSelesai: json['tanggal_selesai']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      status: json['status']?.toString() ?? 'active',
      isCurrentlyActive: json['is_currently_active'] == true,
      totalProduk: json['total_produk'] is int
          ? json['total_produk']
          : int.tryParse(json['total_produk']?.toString() ?? '0') ?? 0,
      selectedProductIds: selectedIds,
      produkList: json['produk'] is List ? json['produk'] : const [],
      createdAt: json['created_at']?.toString(),
    );
  }
}

/// Informasi diskon toko keseluruhan (store-wide promo) yang sedang aktif.
class ActiveStoreWidePromoModel {
  final int idPromo;
  final String namaDiskon;
  final double nilaiDiskon;
  final String tipeDiskon;
  final String konflikDiskon;
  final String? tanggalSelesai;

  ActiveStoreWidePromoModel({
    required this.idPromo,
    required this.namaDiskon,
    required this.nilaiDiskon,
    required this.tipeDiskon,
    required this.konflikDiskon,
    this.tanggalSelesai,
  });

  String get labelDiskon {
    if (tipeDiskon == 'persen') {
      return '${nilaiDiskon.toInt()}%';
    } else {
      return 'Rp ${formatCurrency(nilaiDiskon.toInt())}';
    }
  }

  factory ActiveStoreWidePromoModel.fromJson(Map<String, dynamic> json) {
    return ActiveStoreWidePromoModel(
      idPromo: json['id_promo'] is int
          ? json['id_promo']
          : int.tryParse(json['id_promo']?.toString() ?? '0') ?? 0,
      namaDiskon: json['nama_diskon']?.toString() ?? 'Diskon Toko',
      nilaiDiskon:
          double.tryParse(json['nilai_diskon']?.toString() ?? '0') ?? 0.0,
      tipeDiskon: json['tipe_diskon']?.toString() ?? 'persen',
      konflikDiskon: json['konflik_diskon']?.toString() ?? 'replace',
      tanggalSelesai: json['tanggal_selesai']?.toString(),
    );
  }
}

/// Rincian diskon aktif yang sedang mengikat suatu produk.
class CurrentDiscountInfo {
  final int idPromo;
  final String namaDiskon;
  final double nilaiDiskon;
  final String tipeDiskon;
  final String labelDiskon;
  final String? tanggalSelesai;

  CurrentDiscountInfo({
    required this.idPromo,
    required this.namaDiskon,
    required this.nilaiDiskon,
    required this.tipeDiskon,
    required this.labelDiskon,
    this.tanggalSelesai,
  });

  factory CurrentDiscountInfo.fromJson(Map<String, dynamic> json) {
    return CurrentDiscountInfo(
      idPromo: json['id_promo'] is int
          ? json['id_promo']
          : int.tryParse(json['id_promo']?.toString() ?? '0') ?? 0,
      namaDiskon: json['nama_diskon']?.toString() ?? '',
      nilaiDiskon:
          double.tryParse(json['nilai_diskon']?.toString() ?? '0') ?? 0.0,
      tipeDiskon: json['tipe_diskon']?.toString() ?? 'persen',
      labelDiskon: json['label_diskon']?.toString() ?? '',
      tanggalSelesai: json['tanggal_selesai']?.toString(),
    );
  }
}

/// Produk milik mitra beserta indikator isolasi/penguncian diskon (`is_locked`).
class AvailableProductModel {
  final int idProduk;
  final String namaProduk;
  final String kategori;
  final int hargaNormal;
  final String? foto;
  final bool isLocked;
  final bool canBeDiscounted;
  final CurrentDiscountInfo? currentDiscount;

  AvailableProductModel({
    required this.idProduk,
    required this.namaProduk,
    required this.kategori,
    required this.hargaNormal,
    this.foto,
    required this.isLocked,
    required this.canBeDiscounted,
    this.currentDiscount,
  });

  factory AvailableProductModel.fromJson(Map<String, dynamic> json) {
    CurrentDiscountInfo? curDisc;
    if (json['current_discount'] != null && json['current_discount'] is Map) {
      curDisc = CurrentDiscountInfo.fromJson(
          Map<String, dynamic>.from(json['current_discount'] as Map));
    }

    return AvailableProductModel(
      idProduk: json['id_produk'] is int
          ? json['id_produk']
          : int.tryParse(json['id_produk']?.toString() ?? '0') ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      hargaNormal: json['harga_normal'] is int
          ? json['harga_normal']
          : int.tryParse(json['harga_normal']?.toString() ?? '0') ?? 0,
      foto: json['foto']?.toString(),
      isLocked: json['is_locked'] == true,
      canBeDiscounted: json['can_be_discounted'] == true,
      currentDiscount: curDisc,
    );
  }
}

/// Response lengkap dari `GET /api/mitra/diskon/available-products`.
class AvailableProductsResponse {
  final bool hasActiveStoreWidePromo;
  final ActiveStoreWidePromoModel? activeStoreWidePromo;
  final List<String> categories;
  final List<AvailableProductModel> products;

  AvailableProductsResponse({
    required this.hasActiveStoreWidePromo,
    this.activeStoreWidePromo,
    this.categories = const [],
    required this.products,
  });

  factory AvailableProductsResponse.fromJson(Map<String, dynamic> json) {
    ActiveStoreWidePromoModel? storeWide;
    if (json['active_store_wide_promo'] != null &&
        json['active_store_wide_promo'] is Map) {
      storeWide = ActiveStoreWidePromoModel.fromJson(
          Map<String, dynamic>.from(json['active_store_wide_promo'] as Map));
    }

    List<String> cats = [];
    if (json['categories'] is List) {
      cats = (json['categories'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    List<AvailableProductModel> prods = [];
    if (json['data'] is List) {
      for (var item in json['data'] as List) {
        if (item is Map) {
          prods.add(AvailableProductModel.fromJson(
              Map<String, dynamic>.from(item)));
        }
      }
    }

    // Jika categories dari response API kosong, ambil kategori unik dari produk
    if (cats.isEmpty) {
      final Set<String> uniqueCats = {};
      for (var p in prods) {
        if (p.kategori.isNotEmpty) uniqueCats.add(p.kategori);
      }
      cats = uniqueCats.toList();
    }

    return AvailableProductsResponse(
      hasActiveStoreWidePromo: json['has_active_store_wide_promo'] == true,
      activeStoreWidePromo: storeWide,
      categories: cats,
      products: prods,
    );
  }
}
