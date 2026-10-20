// ignore_for_file: unnecessary_getters_setters
class IklanModel {
  int? _id;
  String? _poster;
  String? _judul;
  String? _subJudul;
  String? _deskripsi;
  String? _targetType;
  int? _idToko;
  String? _namaToko;
  int? _idProduk;
  String? _badgePromo;
  bool _hasActiveDiscount = false;

  IklanModel({
    int id = 0,
    String poster = '',
    String judul = '',
    String subJudul = '',
    String deskripsi = '',
    String targetType = 'store',
    int? idToko,
    String? namaToko,
    int? idProduk,
    String? badgePromo,
    bool hasActiveDiscount = false,
  })  : _id = id,
        _poster = poster,
        _judul = judul,
        _subJudul = subJudul,
        _deskripsi = deskripsi,
        _targetType = targetType,
        _idToko = idToko,
        _namaToko = namaToko,
        _idProduk = idProduk,
        _badgePromo = badgePromo,
        _hasActiveDiscount = hasActiveDiscount;

  int get id => _id ?? 0;
  set id(int? value) => _id = value ?? 0;

  String get poster => _poster ?? '';
  set poster(String? value) => _poster = value ?? '';

  String get judul => _judul ?? '';
  set judul(String? value) => _judul = value ?? '';

  /// Tagline singkat di bawah judul banner (opsional, bisa kosong).
  String get subJudul => _subJudul ?? '';
  set subJudul(String? value) => _subJudul = value ?? '';

  String get deskripsi => _deskripsi ?? '';
  set deskripsi(String? value) => _deskripsi = value ?? '';

  String get targetType => _targetType ?? 'store';
  set targetType(String? value) => _targetType = value ?? 'store';

  /// True jika banner mengarah ke satu produk. Menerima 'product' (API) dan
  /// 'produk' (penamaan di form web) agar tidak bergantung pada satu ejaan.
  bool get isProductTarget {
    final t = targetType.toLowerCase();
    return (t == 'product' || t == 'produk') &&
        _idProduk != null &&
        _idProduk! > 0;
  }

  int? get idToko => _idToko;
  set idToko(int? value) => _idToko = value;

  String? get namaToko => _namaToko;
  set namaToko(String? value) => _namaToko = value;

  int? get idProduk => _idProduk;
  set idProduk(int? value) => _idProduk = value;

  String? get badgePromo => _badgePromo;
  set badgePromo(String? value) => _badgePromo = value;

  bool get hasActiveDiscount => _hasActiveDiscount;
  set hasActiveDiscount(bool value) => _hasActiveDiscount = value;

  factory IklanModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return IklanModel();
    return IklanModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ??
                  json['id_iklan']?.toString() ??
                  '0') ??
              0),
      poster: json['poster']?.toString() ??
          json['image']?.toString() ??
          json['gambar']?.toString() ??
          '',
      judul: json['judul']?.toString() ??
          json['title']?.toString() ??
          json['name']?.toString() ??
          '',
      subJudul: json['sub_judul']?.toString() ??
          json['subtitle']?.toString() ??
          '',
      deskripsi: json['deskripsi']?.toString() ??
          json['keterangan']?.toString() ??
          json['description']?.toString() ??
          json['subtitle']?.toString() ??
          '',
      targetType: json['target_type']?.toString() ?? 'store',
      idToko: json['id_toko'] is int
          ? json['id_toko']
          : int.tryParse(json['id_toko']?.toString() ??
              json['id_user']?.toString() ??
              ''),
      namaToko: json['nama_toko']?.toString() ?? json['store_name']?.toString(),
      idProduk: json['id_produk'] is int
          ? json['id_produk']
          : int.tryParse(json['id_produk']?.toString() ?? ''),
      badgePromo: json['badge_promo']?.toString(),
      hasActiveDiscount: json['has_active_discount'] == true ||
          json['has_active_discount'] == 1 ||
          json['has_active_discount'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poster': poster,
      'judul': judul,
      'sub_judul': subJudul,
      'deskripsi': deskripsi,
      'target_type': targetType,
      'id_toko': idToko,
      'nama_toko': namaToko,
      'id_produk': idProduk,
      'badge_promo': badgePromo,
      'has_active_discount': hasActiveDiscount,
    };
  }
}
