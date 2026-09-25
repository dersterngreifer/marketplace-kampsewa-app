import 'dart:convert';
import 'package:project_camp_sewa/constants/api_endpoint.dart';

class DetailProdukModel {
  int idProduk;
  String namaProduk;
  String deskripsiProduk;
  String fotoDepan;
  List<String> images;
  List<String> fotoArray;
  int hargaSewa;
  int stok;
  String rating;
  int totalUlasan;
  int idUser;
  String fotoUser;
  String namaUser;
  String namaToko;
  String? fotoToko;
  double ratingToko;
  int totalLikes;
  bool isLiked;

  DetailProdukModel({
    required this.idProduk,
    required this.namaProduk,
    required this.deskripsiProduk,
    required this.fotoDepan,
    required this.images,
    required this.fotoArray,
    required this.hargaSewa,
    required this.stok,
    required this.rating,
    required this.totalUlasan,
    required this.idUser,
    required this.fotoUser,
    required this.namaUser,
    required this.namaToko,
    this.fotoToko,
    this.ratingToko = 0.0,
    this.totalLikes = 0,
    this.isLiked = false,
  });

  factory DetailProdukModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFotoArray = [];
    if (json['foto_array'] != null) {
      var arr = json['foto_array'];
      if (arr is String) {
        try {
          arr = jsonDecode(arr);
        } catch (_) {
          if (arr.toString().contains(',') &&
              !arr.toString().trim().startsWith('[')) {
            arr = arr.toString().split(',').map((e) => e.trim()).toList();
          } else {
            arr = [arr.toString()];
          }
        }
      }
      if (arr is Map) {
        arr = arr.values.toList();
      }
      if (arr is List) {
        parsedFotoArray = arr.map<String>((e) {
          if (e is Map) return e['url']?.toString() ?? '';
          return e.toString().trim();
        }).where((url) {
          return url.toString().isNotEmpty &&
              url.toString() != 'null' &&
              url.toString() != 'Belum di isi';
        }).toList();
      }
    }

    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) {
        if (e is Map) return e['url']?.toString() ?? '';
        return e.toString();
      }).where((url) {
        return url.toString().isNotEmpty &&
            url.toString() != 'null' &&
            url.toString() != 'Belum di isi';
      }).toList();
    }

    String cleanPhoto(dynamic val) {
      if (val == null) return '';
      final str = val.toString();
      if (str == 'Belum di isi') return '';
      return str;
    }

    return DetailProdukModel(
      idProduk: json['id_produk'] is int
          ? json['id_produk']
          : int.tryParse(json['id_produk']?.toString() ?? '0') ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? '',
      deskripsiProduk: json['deskripsi_produk']?.toString() ?? '',
      fotoDepan:
          getImageUrl(cleanPhoto(json['foto_depan']), fallbackAvatar: false),
      images: parsedImages,
      fotoArray: parsedFotoArray,
      hargaSewa: json['harga_sewa'] is int
          ? json['harga_sewa']
          : int.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0,
      stok: json['stok'] is int
          ? json['stok']
          : int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      rating: json['rating']?.toString() ?? '0.0',
      totalUlasan: json['total_ulasan'] is int
          ? json['total_ulasan']
          : int.tryParse(json['total_ulasan']?.toString() ?? '0') ?? 0,
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.tryParse(json['id_user']?.toString() ?? '0') ?? 0,
      fotoUser: getImageUrl(json['foto_user']),
      namaUser: json['nama_user']?.toString() ?? '',
      namaToko: json['nama_toko']?.toString() ?? 'Toko Tidak Dikenal',
      fotoToko: json['foto_toko']?.toString(),
      ratingToko:
          double.tryParse(json['rating_toko']?.toString() ?? '0') ?? 0.0,
      totalLikes: json['total_likes'] is int
          ? json['total_likes']
          : int.tryParse(json['total_likes']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] == true ||
          json['is_liked'] == 1 ||
          json['is_liked'] == '1',
    );
  }
}
