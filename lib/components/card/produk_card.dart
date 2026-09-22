import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class ProdukCard extends StatefulWidget {
  final List<String> images;
  final String namaProduk;
  final String? namaToko;
  final String? fotoToko;
  final double? ratingToko;
  final String harga;
  final String rating;
  final int stok;
  final int jumlahReview;
  final bool isFavorite;
  final Function() aksi;
  final Function() aksiKeranjang;
  final Function()? aksiFavorite;
  final String? badgeLabel;

  const ProdukCard({
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
    this.isFavorite = false,
    required this.aksi,
    required this.aksiKeranjang,
    this.aksiFavorite,
    this.badgeLabel,
  });

  @override
  State<ProdukCard> createState() => _ProdukCardState();
}

class _ProdukCardState extends State<ProdukCard>
    with SingleTickerProviderStateMixin {
  static const Color _dark = Color(0xFF2F2828);
  static const Color _grey = Color(0xFF8E8E8E);
  static const Color _lightGrey = Color(0xFFF4F4F4);

  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
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
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.aksi();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(aspectRatio: 1, child: _buildImageSection()),
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final habis = widget.stok <= 0;
    final List<String> displayImages = widget.images.length == 1
        ? [widget.images[0], widget.images[0], widget.images[0]]
        : widget.images;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: displayImages.isEmpty ? 1 : displayImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (displayImages.isEmpty) return _placeholder();
              return _buildSingleImage(displayImages[index]);
            },
          ),
          if (habis)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Habis Disewa",
                  style: AppColors.fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          if (!habis && (widget.badgeLabel != null || widget.stok <= 5))
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.badgeLabel != null 
                      ? const Color(0xFF407BFF) // Biru untuk "Milik Anda"
                      : const Color(0xFFED6723), // Orange untuk "Sisa Stok"
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.badgeLabel ?? "Sisa ${widget.stok}",
                  style: AppColors.fontStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: widget.aksiFavorite,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: widget.isFavorite
                      ? const Color(0xFFEE2737)
                      : const Color(0xFF2F2828),
                ),
              ),
            ),
          ),
          if (displayImages.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: displayImages.asMap().entries.map((entry) {
                        return Container(
                          width: _currentImageIndex == entry.key ? 7 : 5,
                          height: _currentImageIndex == entry.key ? 7 : 5,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == entry.key
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF0F2F1),
        child:
            const Icon(Icons.image_rounded, color: Color(0xFFBDBDBD), size: 40),
      );

  Widget _buildSingleImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return Image.network(
      imagePath.startsWith('http')
          ? imagePath
          : ApiEndpoints.baseUrl +
              ApiEndpoints.authendpoints.getImageProduk +
              imagePath,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder();
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _buildInfoSection() {
    final bisaDitambah = widget.stok > 0 && widget.badgeLabel != "Milik Anda";
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.namaProduk,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppColors.fontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 14, color: Color(0xFFFFC107)),
              const SizedBox(width: 4),
              Text(
                "${formatRating(widget.rating)} â€¢ ${widget.jumlahReview} Ulasan",
                style: AppColors.fontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _grey,
                ),
              ),
            ],
          ),
                    const SizedBox(height: 8),
          if (widget.namaToko != null)
            Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 16,
                    height: 16,
                    color: Colors.grey.shade300,
                    child: widget.fotoToko != null 
                      ? Image.network(
                          widget.fotoToko!.startsWith('http') 
                            ? widget.fotoToko! 
                            : '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getFotoProfile}${widget.fotoToko!}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 10),
                        )
                      : const Icon(Icons.store, size: 10, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.namaToko!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppColors.fontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _grey,
                    ),
                  ),
                ),
                if (widget.ratingToko != null && widget.ratingToko! > 0)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFED6723)),
                      const SizedBox(width: 2),
                      Text(
                        widget.ratingToko!.toStringAsFixed(1),
                        style: AppColors.fontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Rp ${formatCurrency(widget.harga)}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppColors.fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Material(
                color: bisaDitambah ? const Color(0xFF2C4E40) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: bisaDitambah ? widget.aksiKeranjang : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sewa",
                          style: AppColors.fontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 14,
                            color: bisaDitambah ? const Color(0xFF2C4E40) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}





