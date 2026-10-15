import 'package:flutter/material.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BeritaCard extends StatelessWidget {
  final String image;
  final String title;
  final String source;
  final String url;
  final String? date;
  final VoidCallback? onTap;

  const BeritaCard({
    super.key,
    required this.image,
    required this.title,
    required this.source,
    required this.url,
    this.date,
    this.onTap,
  });

  Future<void> _open() async {
    if (url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildImage() {
    Widget fallback() => Container(
          color: const Color(0xFFF0F2F1),
          child: const Icon(Icons.newspaper_rounded,
              color: Color(0xFFBDBDBD), size: 30),
        );

    final resolved = getFotoBeritaUrl(image);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return fallback();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ?? _open,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: _buildImage(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 92,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2F2828),
                            height: 1.3,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C4E40)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.newspaper_rounded,
                                      size: 12, color: Color(0xFF2C4E40)),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 100),
                                    child: Text(
                                      source.isNotEmpty ? source : 'Berita',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppColors.fontStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2C4E40),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (date != null && date!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  date!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppColors.fontStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8E8E8E),
                                  ),
                                ),
                              ),
                            ] else
                              const Spacer(),
                            const Icon(Icons.arrow_outward_rounded,
                                size: 18, color: Color(0xFF8E8E8E)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
