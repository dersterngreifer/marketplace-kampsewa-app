import 'package:project_camp_sewa/constants/api_endpoint.dart';

class ArticleModel {
  final int id;
  final String tipe; // 'wisata' or 'berita'
  final String judul;
  final String slug;
  final String gambar;
  final String deskripsiSingkat;
  final String konten;
  final String? lokasi;
  final String? sumberUrl;
  final String? sumberNama;
  final int viewsCount;
  final String tanggalUpload;
  final String waktuUpload;
  final String waktuLalu;
  final String createdAt;
  final String? updatedAt;
  final ArticleAuthor? author;

  ArticleModel({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.slug,
    required this.gambar,
    required this.deskripsiSingkat,
    required this.konten,
    this.lokasi,
    this.sumberUrl,
    this.sumberNama,
    required this.viewsCount,
    required this.tanggalUpload,
    required this.waktuUpload,
    required this.waktuLalu,
    required this.createdAt,
    this.updatedAt,
    this.author,
  });

  bool get isWisata => tipe.toLowerCase() == 'wisata';

  /// Mendapatkan URL gambar yang fleksibel dan dinormalisasi
  /// (mendukung URL web luar, path storage backend, dan nama file di assets).
  String get imageUrl {
    if (isWisata) {
      return getFotoWisataUrl(gambar);
    }
    return getFotoBeritaUrl(gambar);
  }

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString()) ?? 0;
    }

    int parsedViews = 0;
    if (json['views_count'] is int) {
      parsedViews = json['views_count'];
    } else if (json['views_count'] != null) {
      parsedViews = int.tryParse(json['views_count'].toString()) ?? 0;
    }

    ArticleAuthor? parsedAuthor;
    if (json['author'] is Map<String, dynamic>) {
      parsedAuthor = ArticleAuthor.fromJson(json['author']);
    } else if (json['author'] is Map) {
      parsedAuthor = ArticleAuthor.fromJson(Map<String, dynamic>.from(json['author']));
    }

    return ArticleModel(
      id: parsedId,
      tipe: json['tipe']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      gambar: json['gambar']?.toString() ?? '',
      deskripsiSingkat: json['deskripsi_singkat']?.toString() ?? '',
      konten: json['konten']?.toString() ?? '',
      lokasi: json['lokasi']?.toString(),
      sumberUrl: json['sumber_url']?.toString(),
      sumberNama: json['sumber_nama']?.toString(),
      viewsCount: parsedViews,
      tanggalUpload: json['tanggal_upload']?.toString() ?? '',
      waktuUpload: json['waktu_upload']?.toString() ?? '',
      waktuLalu: json['waktu_lalu']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
      author: parsedAuthor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipe': tipe,
      'judul': judul,
      'slug': slug,
      'gambar': gambar,
      'deskripsi_singkat': deskripsiSingkat,
      'konten': konten,
      'lokasi': lokasi,
      'sumber_url': sumberUrl,
      'sumber_nama': sumberNama,
      'views_count': viewsCount,
      'tanggal_upload': tanggalUpload,
      'waktu_upload': waktuUpload,
      'waktu_lalu': waktuLalu,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'author': author?.toJson(),
    };
  }
}

class ArticleAuthor {
  final int? id;
  final String name;
  final String email;
  final String foto;

  ArticleAuthor({
    this.id,
    required this.name,
    required this.email,
    required this.foto,
  });

  factory ArticleAuthor.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString());
    }

    return ArticleAuthor(
      id: parsedId,
      name: json['name']?.toString() ?? json['nama']?.toString() ?? 'Admin KampSewa',
      email: json['email']?.toString() ?? '',
      foto: json['foto_profile']?.toString() ?? json['foto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'foto': foto,
    };
  }
}
