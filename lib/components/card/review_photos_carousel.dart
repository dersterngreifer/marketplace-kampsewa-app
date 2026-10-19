import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/components/dialog/fullscreen_image_viewer.dart';

class ReviewPhotosCarousel extends StatelessWidget {
  final List<String> photos;
  final String reviewerName;

  const ReviewPhotosCarousel({
    super.key,
    required this.photos,
    required this.reviewerName,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    // Jika hanya 1 foto
    if (photos.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => FullscreenImageViewer(
                images: photos,
                initialIndex: 0,
                title: "Foto Ulasan - $reviewerName",
              ),
              transition: Transition.fadeIn,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.network(
                  photos[0],
                  height: 96,
                  width: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 96,
                    width: 96,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Jika lebih dari 1 foto (banyak foto hingga 10 foto)
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 13,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                "${photos.length} Foto ulasan (ketuk untuk memperbesar)",
                style: AppColors.fontStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, photoIndex) {
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => FullscreenImageViewer(
                        images: photos,
                        initialIndex: photoIndex,
                        title: "Foto Ulasan - $reviewerName",
                      ),
                      transition: Transition.fadeIn,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.network(
                          photos[photoIndex],
                          height: 92,
                          width: 92,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 92,
                            width: 92,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${photoIndex + 1}/${photos.length}",
                              style: AppColors.fontStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
