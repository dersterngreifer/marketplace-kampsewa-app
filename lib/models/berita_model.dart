import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/article_model.dart';

class BeritaModel {
  final int id;
  final String judul;
  final String image;
  final String source;
  final String link;
  final ArticleModel? article;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.image,
    required this.source,
    required this.link,
    this.article,
  });

  factory BeritaModel.fromArticle(ArticleModel a) {
    return BeritaModel(
      id: a.id,
      judul: a.judul,
      image: a.imageUrl,
      source: (a.sumberNama != null && a.sumberNama!.isNotEmpty)
          ? a.sumberNama!
          : (a.author?.name ?? 'KampSewa'),
      link: a.sumberUrl ?? '',
      article: a,
    );
  }

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? json['gambar']?.toString() ?? '';
    return BeritaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      judul: json['judul']?.toString() ?? '',
      image: getFotoBeritaUrl(rawImage),
      source: json['source']?.toString() ?? json['sumber_nama']?.toString() ?? '',
      link: json['link']?.toString() ?? json['sumber_url']?.toString() ?? '',
    );
  }
}
