import 'package:project_camp_sewa/constants/api_endpoint.dart';

class User {
  int? id;
  String? name;
  String? email;
  String? image;
  String? nomorTelephone;
  String? tanggalLahir;
  String? namaStore;
  bool? isToko;
  int? type;
  String? nomorIdentitas;
  String? fotoIdentitas;
  bool? isVerified;
  String? deskripsiToko;
  String? bannerToko;
  String? fotoToko;
  String? background;
  String? jenisKelamin;

  double? _ratingToko;
  int? _totalUlasanToko;
  int? _totalFollowers;
  int? _totalFollowing;
  int? _totalNewFollowers;

  double get ratingToko => _ratingToko ?? 0.0;
  set ratingToko(double? val) => _ratingToko = val;

  int get totalUlasanToko => _totalUlasanToko ?? 0;
  set totalUlasanToko(int? val) => _totalUlasanToko = val;

  /// Jumlah akun yang mem-follow user ini.
  int get totalFollowers => _totalFollowers ?? 0;
  set totalFollowers(int? val) => _totalFollowers = val;

  /// Jumlah akun yang di-follow oleh user ini.
  int get totalFollowing => _totalFollowing ?? 0;
  set totalFollowing(int? val) => _totalFollowing = val;

  /// Jumlah follower baru dalam 24 jam terakhir.
  int get totalNewFollowers => _totalNewFollowers ?? 0;
  set totalNewFollowers(int? val) => _totalNewFollowers = val;

  User({
    this.id,
    this.name,
    this.email,
    this.image,
    this.nomorTelephone,
    this.tanggalLahir,
    this.namaStore,
    this.isToko,
    this.type,
    this.nomorIdentitas,
    this.fotoIdentitas,
    this.isVerified,
    this.deskripsiToko,
    this.bannerToko,
    this.fotoToko,
    this.background,
    this.jenisKelamin,
    double? ratingToko = 0.0,
    int? totalUlasanToko = 0,
    int? totalFollowers = 0,
    int? totalFollowing = 0,
    int? totalNewFollowers = 0,
  })  : _ratingToko = ratingToko ?? 0.0,
        _totalUlasanToko = totalUlasanToko ?? 0,
        _totalFollowers = totalFollowers ?? 0,
        _totalFollowing = totalFollowing ?? 0,
        _totalNewFollowers = totalNewFollowers ?? 0;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      image: getImageUrl(json['foto']?.toString()),
      nomorTelephone: json['nomor_telephone']?.toString(),
      tanggalLahir: json['tanggal_lahir']?.toString(),
      namaStore: json['name_store']?.toString(),
      isToko: json['is_toko'] == true ||
          json['is_toko'] == 1 ||
          json['is_toko']?.toString() == '1' ||
          json['is_toko']?.toString() == 'true',
      type: json['type'] is int
          ? json['type'] as int
          : int.tryParse(json['type']?.toString() ?? ''),
      nomorIdentitas: json['nomor_identitas']?.toString(),
      fotoIdentitas: json['foto_identitas']?.toString(),
      isVerified: json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['is_verified']?.toString() == '1',
      deskripsiToko: json['deskripsi_toko']?.toString(),
      bannerToko: json['banner_toko']?.toString(),
      fotoToko: json['foto_toko']?.toString(),
      background: json['background']?.toString(),
      jenisKelamin: json['jenis_kelamin']?.toString(),
      ratingToko:
          double.tryParse(json['rating_toko']?.toString() ?? '0') ?? 0.0,
      totalUlasanToko:
          int.tryParse(json['total_ulasan_toko']?.toString() ?? '0') ?? 0,
      totalFollowers:
          int.tryParse(json['total_followers']?.toString() ?? '0') ?? 0,
      totalFollowing:
          int.tryParse(json['total_following']?.toString() ?? '0') ?? 0,
      totalNewFollowers:
          int.tryParse(json['total_new_followers']?.toString() ?? '0') ?? 0,
    );
  }
}
