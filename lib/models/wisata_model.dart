import 'package:project_camp_sewa/constants/api_endpoint.dart';

class WisataModel{
   final String image;
  final String deskripsi;
  final String wisata;
  final String lokasi;
  final String source;

  WisataModel({
    required this.image,
    required this.deskripsi,
    required this.wisata,
    required this.lokasi,
    required this.source,
  });

  factory WisataModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? '';
    return WisataModel(
      image: rawImage.startsWith('assets/')
          ? rawImage
          : getImageUrl(rawImage),
      deskripsi: json['deskripsi']?.toString() ?? '',
      wisata: json['wisata']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }

}