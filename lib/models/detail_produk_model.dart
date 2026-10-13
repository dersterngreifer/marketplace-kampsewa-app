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
  int hargaAsli;
  bool isDiskon;
  int persentaseDiskon;
  int potonganHarga;
  String? namaPromo;
  String? tanggalMulai;
  String? tanggalSelesai;

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
    this.hargaAsli = 0,
    this.isDiskon = false,
    this.persentaseDiskon = 0,
    this.potonganHarga = 0,
    this.namaPromo,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  factory DetailProdukModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFotoArray = [];
    if (json['foto_array'] != null) {
      var arr = json['foto_array'];
      if (arr is String) {
        try {
          arr = jsonDecode(arr);
        } catch (_) {
          String strArr = arr.toString().trim();
          if (strArr.startsWith('[') && strArr.endsWith(']')) {
            strArr = strArr.substring(1, strArr.length - 1);
          }
          if (strArr.contains(',')) {
            arr = strArr.split(',').map((e) => e.replaceAll('"', '').replaceAll("'", "").trim()).toList();
          } else {
            arr = [strArr.replaceAll('"', '').replaceAll("'", "").trim()];
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
    if (json['images'] != null) {
      var arr = json['images'];
      if (arr is String) {
        try {
          arr = jsonDecode(arr);
        } catch (_) {
          String strArr = arr.toString().trim();
          if (strArr.startsWith('[') && strArr.endsWith(']')) {
            strArr = strArr.substring(1, strArr.length - 1);
          }
          if (strArr.contains(',')) {
            arr = strArr.split(',').map((e) => e.replaceAll('"', '').replaceAll("'", "").trim()).toList();
          } else {
            arr = [strArr.replaceAll('"', '').replaceAll("'", "").trim()];
          }
        }
      }
      if (arr is Map) {
        arr = arr.values.toList();
      }
      if (arr is List) {
        parsedImages = (arr).map((e) {
          if (e is Map) return e['url']?.toString() ?? '';
          return e.toString().trim();
        }).where((url) {
          return url.toString().isNotEmpty &&
              url.toString() != 'null' &&
              url.toString() != 'Belum di isi';
        }).toList();
      }
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
      hargaAsli: () {
        final int rawHarga = json['harga_sewa'] is int
            ? json['harga_sewa']
            : int.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0;
        int rawHargaAsli = json['harga_asli'] is int
            ? json['harga_asli']
            : (num.tryParse(json['harga_asli']?.toString() ?? '0')?.toInt() ?? 0);
        final bool isD = json['is_diskon'] == true ||
            json['is_diskon'] == 1 ||
            json['is_diskon'] == '1' ||
            json['is_diskon']?.toString().toLowerCase() == 'true';
        final int persentase = json['persentase_diskon'] is int
            ? json['persentase_diskon']
            : (num.tryParse(json['persentase_diskon']?.toString() ?? '0')?.toInt() ?? 0);
        final int potongan = json['potongan_harga'] is int
            ? json['potongan_harga']
            : (num.tryParse(json['potongan_harga']?.toString() ?? '0')?.toInt() ?? 0);

        if ((isD || persentase > 0 || potongan > 0) && rawHargaAsli <= rawHarga) {
          if (potongan > 0) {
            rawHargaAsli = rawHarga + potongan;
          } else if (persentase > 0 && persentase < 100) {
            rawHargaAsli = (rawHarga / (1 - (persentase / 100))).round();
          }
        }
        return rawHargaAsli;
      }(),
      isDiskon: json['is_diskon'] == true ||
          json['is_diskon'] == 1 ||
          json['is_diskon'] == '1' ||
          json['is_diskon']?.toString().toLowerCase() == 'true' ||
          ((json['persentase_diskon'] is num && json['persentase_diskon'] > 0) ||
              (num.tryParse(json['persentase_diskon']?.toString() ?? '0') ?? 0) > 0) ||
          ((json['potongan_harga'] is num && json['potongan_harga'] > 0) ||
              (num.tryParse(json['potongan_harga']?.toString() ?? '0') ?? 0) > 0),
      persentaseDiskon: json['persentase_diskon'] is int
          ? json['persentase_diskon']
          : (num.tryParse(json['persentase_diskon']?.toString() ?? '0')?.toInt() ?? 0),
      potonganHarga: json['potongan_harga'] is int
          ? json['potongan_harga']
          : (num.tryParse(json['potongan_harga']?.toString() ?? '0')?.toInt() ?? 0),
      namaPromo: json['nama_diskon']?.toString() ?? json['nama_promo']?.toString(),
      tanggalMulai: json['tanggal_mulai']?.toString(),
      tanggalSelesai: json['tanggal_selesai']?.toString(),
    );
  }
}
