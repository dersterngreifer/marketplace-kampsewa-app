import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/article_model.dart';

class WisataModel {
  final int id;
  final String image;
  final String deskripsi;
  final String wisata;
  final String lokasi;
  final String source;
  final ArticleModel? article;

  WisataModel({
    this.id = 0,
    required this.image,
    required this.deskripsi,
    required this.wisata,
    required this.lokasi,
    required this.source,
    this.article,
  });

  factory WisataModel.fromArticle(ArticleModel a) {
    return WisataModel(
      id: a.id,
      image: a.imageUrl,
      deskripsi: a.deskripsiSingkat,
      wisata: a.judul,
      lokasi: a.lokasi ?? 'Indonesia',
      source: a.sumberUrl ?? '',
      article: a,
    );
  }

  factory WisataModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? json['gambar']?.toString() ?? '';
    final int parsedId = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    return WisataModel(
      id: parsedId,
      image: rawImage.startsWith('assets/')
          ? rawImage
          : getFotoWisataUrl(rawImage),
      deskripsi: json['deskripsi']?.toString() ?? json['deskripsi_singkat']?.toString() ?? '',
      wisata: json['wisata']?.toString() ?? json['judul']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      source: json['source']?.toString() ?? json['sumber_url']?.toString() ?? '',
    );
  }
}