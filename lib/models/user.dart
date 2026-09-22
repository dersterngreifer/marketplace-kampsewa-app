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
  String? background;
  String? jenisKelamin;
  double ratingToko;
  int totalUlasanToko;

  User(
      {this.id,
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
      this.background,
      this.jenisKelamin,
      this.ratingToko = 0.0,
      this.totalUlasanToko = 0});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      image: getImageUrl(json['foto']),
      nomorTelephone: json['nomor_telephone'],
      tanggalLahir: json['tanggal_lahir'],
      namaStore: json['name_store'],
      isToko: json['is_toko'],
      type: json['type'],
      nomorIdentitas: json['nomor_identitas'],
      fotoIdentitas: json['foto_identitas'],
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      deskripsiToko: json['deskripsi_toko'],
      bannerToko: json['banner_toko'],
      background: json['background'],
      jenisKelamin: json['jenis_kelamin'],
      ratingToko: double.tryParse(json['rating_toko']?.toString() ?? '0') ?? 0.0,
      totalUlasanToko: int.tryParse(json['total_ulasan_toko']?.toString() ?? '0') ?? 0,
    );
  }
}
