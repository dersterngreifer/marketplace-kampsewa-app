import 'package:flutter/material.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class WisataCard extends StatelessWidget {
  final String image;
  final String title;
  final String deskripsi;
  final String lokasi;
  final String url;

  const WisataCard({
    super.key,
    required this.image,
    required this.title,
    required this.deskripsi,
    required this.lokasi,
    required this.url,
  });

  Future<void> _open() async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildImage() {
    Widget fallback() => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2C4E40), Color(0xFF1E352B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),

            // Gradient gelap di bawah agar teks terbaca
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.55, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.82),
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Chip lokasi (kiri atas)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Color(0xFFEE2737)),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          lokasi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2F2828),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Judul + deskripsi
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppColors.fontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppColors.fontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            // Ripple + tap
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: _open),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
