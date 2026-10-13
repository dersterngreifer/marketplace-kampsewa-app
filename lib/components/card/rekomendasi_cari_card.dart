import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class RekomendasiCariCard extends StatefulWidget {
  final List<String> images;
  final String namaProduk;
  final String? namaToko;
  final String? fotoToko;
  final double? ratingToko;
  final String harga;
  final String rating;
  final int stok;
  final int jumlahReview;
  final Function() aksi;

  const RekomendasiCariCard({
    super.key,
    required this.images,
    required this.namaProduk,
    this.namaToko,
    this.fotoToko,
    this.ratingToko,
    required this.harga,
    required this.rating,
    this.stok = 0,
    this.jumlahReview = 0,
    required this.aksi,
  });

  @override
  State<RekomendasiCariCard> createState() => _RekomendasiCariCardState();
}

class _RekomendasiCariCardState extends State<RekomendasiCariCard>
    with SingleTickerProviderStateMixin {
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF8E8E8E);
  static const Color _green = Color(0xFF2C4E40);
  static const Color _yellow = Color(0xFFFFC107);

  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  String formatCurrency(String numberString) {
    final number = (double.tryParse(numberString) ?? 0).round();
    return NumberFormat.decimalPattern('id').format(number);
  }

  String formatRating(String numberString) {
    final number = double.tryParse(numberString) ?? 0.0;
    return number.toStringAsFixed(1);
  }

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.aksi();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            // Shadow berlapis biar lebih elegan & jelas
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Area Foto / Carousel ──
                AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildImageSection(),
                ),

                // ── Area Informasi Produk ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Nama Produk ──
                        Text(
                          widget.namaProduk,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                            height: 1.25,
                            letterSpacing: -0.1,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Info Toko ──
                        if (widget.namaToko != null &&
                            widget.namaToko!.isNotEmpty)
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 0.8,
                                  ),
                                ),
                                child: ClipOval(
                                  child: widget.fotoToko != null &&
                                          widget.fotoToko!.isNotEmpty &&
                                          getFotoTokoUrl(widget.fotoToko)
                                              .isNotEmpty
                                      ? Image.network(
                                          getFotoTokoUrl(widget.fotoToko),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                            Icons.store_rounded,
                                            size: 10,
                                            color: _grey,
                                          ),
                                        )
                                      : const Icon(Icons.store_rounded,
                                          size: 10, color: _grey),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  widget.namaToko!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppColors.fontStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _grey,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 6),

                        // ── Rating & Ulasan (dibuat lebih jelas) ──
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: _yellow.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: _yellow,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    formatRating(widget.rating),
                                    style: AppColors.fontStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _dark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "${widget.jumlahReview} ulasan",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppColors.fontStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: _grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ── Garis pemisah halus ──
                        Container(
                          height: 1,
                          color: Colors.grey.shade100,
                          margin: const EdgeInsets.only(bottom: 8),
                        ),

                        // ── Harga Sewa (lebih menonjol) ──
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: 'Rp${formatCurrency(widget.harga)}',
                            style: AppColors.fontStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: _green,
                              letterSpacing: -0.2,
                            ),
                            children: [
                              TextSpan(
                                text: ' /hari',
                                style: AppColors.fontStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: _grey,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildImageSection() {
    final habis = widget.stok <= 0;
    final List<String> displayImages =
        widget.images.where((e) => e.isNotEmpty).toList();
    final bool hasMultiple = displayImages.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Carousel / Single Image ──
        displayImages.isEmpty
            ? _placeholder()
            : PageView.builder(
                controller: _pageController,
                itemCount: displayImages.length,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                itemBuilder: (_, i) => _buildSingleImage(displayImages[i]),
              ),

        // ── Dots Indicator Carousel ──
        if (hasMultiple)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                displayImages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: _currentImageIndex == i ? 16 : 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ── Overlay Habis ──
        if (habis)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Habis Disewa',
                style: AppColors.fontStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),

        // ── Badge Sisa Stok ──
        if (!habis && widget.stok <= 5)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFED6723),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFED6723).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Sisa ${widget.stok}',
                style: AppColors.fontStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSingleImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    final fullUrl =
        resolveFullUrl(url, ApiEndpoints.authendpoints.getImageProduk);
    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: Icon(
          Icons.image_rounded,
          color: Color(0xFFBDBDBD),
          size: 36,
        ),
      ),
    );
  }
}
