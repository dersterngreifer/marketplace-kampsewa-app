import 'package:project_camp_sewa/constants/api_endpoint.dart';

class ProdukModel {
  final int idProduk;
  final int idUser;
  final String namaToko;
  final String namaProduk;
  final String image;
  final String rating;
  final int harga;
  final int stok;
  final int jumlahReview;
  final bool isFavorite;

  ProdukModel({
    required this.idProduk,
    required this.idUser,
    required this.namaToko,
    required this.namaProduk,
    required this.image,
    required this.rating,
    required this.harga,
    this.stok = 0,
    this.jumlahReview = 0,
    this.isFavorite = false,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      idProduk: json['id_produk'] is int ? json['id_produk'] : int.tryParse(json['id_produk']?.toString() ?? '0') ?? 0,
      idUser: json['id_user'] is int ? json['id_user'] : int.tryParse(json['id_user']?.toString() ?? '0') ?? 0,
      namaToko: json['nama_user']?.toString() ?? '',
      namaProduk: json['nama_produk']?.toString() ?? '',
      image: getImageUrl(json['foto_depan']),
      rating: json['rata_rating']?.toString() ?? '0.0',
      harga: json['harga_sewa'] is int ? json['harga_sewa'] : int.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0,
      stok: json['stok'] is int ? json['stok'] : int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      jumlahReview: json['jumlah_review'] is int ? json['jumlah_review'] : int.tryParse(json['jumlah_review']?.toString() ?? '0') ?? 0,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1 || json['is_favorite'] == '1',
    );
  }
}