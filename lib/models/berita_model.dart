import 'package:project_camp_sewa/constants/api_endpoint.dart';

class BeritaModel {
  final int id;
  final String judul;
  final String image;
  final String source;
  final String link;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.image,
    required this.source,
    required this.link,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      judul: json['judul']?.toString() ?? '',
      image: getImageUrl(json['image']),
      source: json['source']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }
}
