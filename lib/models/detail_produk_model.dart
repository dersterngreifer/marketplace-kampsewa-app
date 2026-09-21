import 'package:project_camp_sewa/constants/api_endpoint.dart';

class DetailProdukModel {
  int idProduk;
  String namaProduk;
  String deskripsiProduk;
  String fotoDepan;
  String fotoBelakang;
  String fotoKiri;
  String fotoKanan;
  int hargaSewa;
  String rating;
  int totalUlasan;
  int idUser;
  String fotoUser;
  String namaUser;

  DetailProdukModel({
    required this.idProduk,
    required this.namaProduk,
    required this.deskripsiProduk,
    required this.fotoDepan,
    required this.fotoBelakang,
    required this.fotoKiri,
    required this.fotoKanan,
    required this.hargaSewa,
    required this.rating,
    required this.totalUlasan,
    required this.idUser,
    required this.fotoUser,
    required this.namaUser,
  });

  factory DetailProdukModel.fromJson(Map<String, dynamic> json) {
    return DetailProdukModel(
      idProduk: json['id_produk'] is int ? json['id_produk'] : int.tryParse(json['id_produk']?.toString() ?? '0') ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? '',
      deskripsiProduk: json['deskripsi_produk']?.toString() ?? '',
      fotoDepan: getImageUrl(json['foto_depan']),
      fotoBelakang: getImageUrl(json['foto_belakang']),
      fotoKiri: getImageUrl(json['foto_kiri']),
      fotoKanan: getImageUrl(json['foto_kanan']),
      hargaSewa: json['harga_sewa'] is int ? json['harga_sewa'] : int.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0,
      rating: json['rating']?.toString() ?? '0.0',
      totalUlasan: json['total_ulasan'] is int ? json['total_ulasan'] : int.tryParse(json['total_ulasan']?.toString() ?? '0') ?? 0,
      idUser: json['id_user'] is int ? json['id_user'] : int.tryParse(json['id_user']?.toString() ?? '0') ?? 0,
      fotoUser: getImageUrl(json['foto_user']),
      namaUser: json['nama_user']?.toString() ?? '',
    );
  }
}
