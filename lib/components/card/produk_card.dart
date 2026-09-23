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
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF8E8E8E);

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 6),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gambar 1:1 ratio ──
          AspectRatio(
            aspectRatio: 1.0,
            child: _buildImageSection(),
          ),
          // ── Info: area yang bisa di-tap untuk navigasi ──
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _pressController.forward(),
              onTapUp: (_) {
                _pressController.reverse();
                widget.aksi();
              },
              onTapCancel: () => _pressController.reverse(),
              child: ScaleTransition(
                scale: _scaleAnim,
                child: _buildInfoSection(),
              ),
            ),
          ),
        ],
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
        // ── Slider / Single Image ──
        displayImages.isEmpty
            ? _placeholder()
            : GestureDetector(
                onTap: widget.aksi,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: displayImages.length,
                  onPageChanged: (i) =>
                      setState(() => _currentImageIndex = i),
                  itemBuilder: (_, i) =>
                      _buildSingleImage(displayImages[i]),
                ),
              ),

        // ── Overlay Habis ──
        if (habis)
          Container(
            color: Colors.black.withValues(alpha: 0.45),
            alignment: Alignment.center,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Habis Disewa',
                style: AppColors.fontStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),

        // ── Badge Kiri Atas ──
        if (!habis && (widget.badgeLabel != null || widget.stok <= 5))
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: widget.badgeLabel == 'Milik Anda'
                    ? const Color(0xFF407BFF) // Biru
                    : widget.badgeLabel != null 
                        ? const Color(0xFF2C4E40) // Hijau gelap (mainColor) untuk kategori
                        : const Color(0xFFED6723), // Orange untuk sisa stok
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.badgeLabel ?? 'Sisa ${widget.stok}',
                style: AppColors.fontStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // ── Tombol Favorit ──
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.aksiFavorite,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 15,
                color: widget.isFavorite
                    ? const Color(0xFFEE2737)
                    : const Color(0xFF2F2828),
              ),
            ),
          ),
        ),

        // ── Dot Indicators ──
        if (hasMultiple)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: displayImages.asMap().entries.map((e) {
                    final active = _currentImageIndex == e.key;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      width: active ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF0F2F1),
        child: const Icon(Icons.image_rounded,
            color: Color(0xFFBDBDBD), size: 36),
      );

  Widget _buildSingleImage(String imagePath) {
    if (imagePath.isEmpty) return _placeholder();
    final url =
        resolveFullUrl(imagePath, ApiEndpoints.authendpoints.getImageProduk);
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder(),
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _buildInfoSection() {
    final bisaDitambah = widget.stok > 0 && widget.badgeLabel != 'Milik Anda';
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama produk
          Text(
            widget.namaProduk,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppColors.fontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),

          // Rating + Ulasan
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 14, color: Color(0xFFFFC107)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${formatRating(widget.rating)}  ·  ${widget.jumlahReview} ulasan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Nama Toko
          if (widget.namaToko != null)
            Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 18,
                    height: 18,
                    color: Colors.grey.shade200,
                    child: widget.fotoToko != null
                        ? Image.network(
                            widget.fotoToko!.startsWith('http')
                                ? widget.fotoToko!
                                : '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getFotoProfile}${widget.fotoToko!}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.store, size: 10),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _grey,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10),

          // Harga
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: 'Rp ${formatCurrency(widget.harga)}',
              style: AppColors.fontStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: _dark,
              ),
              children: [
                TextSpan(
                  text: ' /hari',
                  style: AppColors.fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tombol Sewa
          SizedBox(
            width: double.infinity,
            child: Material(
              color: bisaDitambah
                  ? const Color(0xFF2C4E40)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: bisaDitambah ? widget.aksiKeranjang : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sewa',
                        style: AppColors.fontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: bisaDitambah ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 16,
                        color: bisaDitambah ? Colors.white : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

