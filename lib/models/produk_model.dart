import 'dart:convert';
import 'package:project_camp_sewa/constants/api_endpoint.dart';

class ProdukModel {
  final int idProduk;
  final int idUser;
  final String namaToko;
  final String? fotoToko;
  final double ratingToko;
  final String namaProduk;
  final String kategori;
  final String image;
  final List<String> images;
  final String rating;
  final int harga;
  final int hargaAsli;
  final bool isDiskon;
  final int persentaseDiskon;
  final int potonganHarga;
  final String? namaPromo;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final int stok;
  final int jumlahReview;
  final bool isFavorite;
  int totalLikes;
  bool isLiked;

  ProdukModel({
    required this.idProduk,
    required this.idUser,
    required this.namaToko,
    this.fotoToko,
    this.ratingToko = 0.0,
    required this.namaProduk,
    this.kategori = 'Lainnya',
    required this.image,
    required this.images,
    required this.rating,
    required this.harga,
    this.hargaAsli = 0,
    this.isDiskon = false,
    this.persentaseDiskon = 0,
    this.potonganHarga = 0,
    this.namaPromo,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.stok = 0,
    this.jumlahReview = 0,
    this.isFavorite = false,
    this.totalLikes = 0,
    this.isLiked = false,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['foto_depan']?.toString() ?? '';
    if (rawImage.startsWith('[') && rawImage.endsWith(']')) {
      rawImage = rawImage.replaceAll(RegExp(r'[\[\]\"]'), '').split(',').first;
    }

    List<String> parsedImages = [];

    // Jika backend memberikan field 'images' berupa array (solusi baru)
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

    // Kita selalu mem-parsing fallback field untuk berjaga-jaga jika 'images'
    // dari backend ternyata tidak lengkap (misal hanya berisi 4 foto tanpa foto_array)
    List<String> fallbackImages = [];
    fallbackImages.add(getImageUrl(rawImage));

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
        var parsedArr = arr.map<String>((e) {
          if (e is Map) return e['url']?.toString() ?? '';
          return e.toString().trim();
        }).where((url) {
          return url.toString().isNotEmpty &&
              url.toString() != 'null' &&
              url.toString() != 'Belum di isi';
        }).toList();
        fallbackImages.addAll(parsedArr);
      }
    }

    // Gabungkan array dari backend (images) dengan fallback jika ada yang tertinggal
    for (var img in fallbackImages) {
      bool exists = false;
      String filename = img.split('/').last;
      for (var existing in parsedImages) {
        if (existing.split('/').last == filename) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        parsedImages.add(img);
      }
    }

    // Hapus duplikat di parsedImages dengan cara yang sama (mencocokkan nama file)
    List<String> finalImages = [];
    for (var img in parsedImages) {
      String filename = img.split('/').last;
      if (!finalImages.any((e) => e.split('/').last == filename)) {
        finalImages.add(img);
      }
    }
    parsedImages = finalImages;

    return ProdukModel(
      idProduk: json['id_produk'] is int
          ? json['id_produk']
          : int.tryParse(json['id_produk']?.toString() ?? '0') ?? 0,
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.tryParse(json['id_user']?.toString() ?? '0') ?? 0,
      namaToko: json['nama_toko']?.toString() ?? 'Toko Tidak Dikenal',
      fotoToko: json['foto_toko']?.toString(),
      ratingToko:
          double.tryParse(json['rating_toko']?.toString() ?? '0') ?? 0.0,
      namaProduk: json['nama_produk']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'Lainnya',
      image: getImageUrl(rawImage),
      images: parsedImages,
      rating: json['rata_rating']?.toString() ?? '0.0',
      harga: () {
        final int rawHarga = (json['harga'] is int
                ? json['harga']
                : int.tryParse(json['harga']?.toString() ?? '')) ??
            (json['harga_sewa'] is int
                ? json['harga_sewa']
                : int.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0);
        return rawHarga;
      }(),
      hargaAsli: () {
        final int rawHarga = (json['harga'] is int
                ? json['harga']
                : int.tryParse(json['harga']?.toString() ?? '')) ??
            (json['harga_sewa'] is int
                ? json['harga_sewa']
                : int.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0);
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
      stok: json['stok'] is int
          ? json['stok']
          : int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      jumlahReview: json['jumlah_review'] is int
          ? json['jumlah_review']
          : int.tryParse(json['jumlah_review']?.toString() ?? '0') ?? 0,
      isFavorite: json['is_favorite'] == true ||
          json['is_favorite'] == 1 ||
          json['is_favorite'] == '1',
      totalLikes: json['total_likes'] is int
          ? json['total_likes']
          : int.tryParse(json['total_likes']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] == true ||
          json['is_liked'] == 1 ||
          json['is_liked'] == '1',
    );
  }
}
