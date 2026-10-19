import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? title;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.title,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final ScrollController _thumbScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.isEmpty ? 0 : widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    
    // Auto-scroll thumbnails to active image after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToThumbnail(_currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbScrollController.dispose();
    super.dispose();
  }

  void _scrollToThumbnail(int index) {
    if (!_thumbScrollController.hasClients) return;
    final targetOffset = (index * 64.0) - (MediaQuery.of(context).size.width / 2) + 32.0;
    _thumbScrollController.animateTo(
      targetOffset.clamp(0.0, _thumbScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalImages = widget.images.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main PageView with InteractiveViewer for zoom and slide
          if (widget.images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: totalImages,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _scrollToThumbnail(index);
              },
              itemBuilder: (context, index) {
                final imageUrl = widget.images[index];
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.5,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image_rounded,
                            size: 64,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Gagal memuat gambar",
                            style: AppColors.fontStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Text(
                "Tidak ada gambar",
                style: AppColors.fontStyle(color: Colors.white),
              ),
            ),

          // Previous / Next button overlays (for quick tapping)
          if (totalImages > 1) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentIndex < totalImages - 1)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],

          // Top Bar (Back button, Title, Image Counter Pill)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    onPressed: () => Get.back(),
                    tooltip: "Tutup",
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title ?? "Foto Ulasan",
                      style: AppColors.fontStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (totalImages > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        "${_currentIndex + 1} / $totalImages",
                        style: AppColors.fontStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Bar (Thumbnails strip for multi-image review)
          if (totalImages > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                  top: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SizedBox(
                  height: 56,
                  child: ListView.separated(
                    controller: _thumbScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: totalImages,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = index == _currentIndex;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.mainColor : Colors.white24,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              widget.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.broken_image, size: 20, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
