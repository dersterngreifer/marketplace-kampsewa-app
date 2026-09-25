import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class ProdukTerlarisDashboard extends StatefulWidget {
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
  final bool isLiked;
  final int totalLikes;
  final Function() aksi;
  final Function() aksiKeranjang;
  final String? badgeLabel;
  final Function()? aksiFavorite;

  const ProdukTerlarisDashboard({
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
    this.isLiked = false,
    this.totalLikes = 0,
    required this.aksi,
    required this.aksiKeranjang,
    this.badgeLabel,
    this.aksiFavorite,
  });

  @override
  State<ProdukTerlarisDashboard> createState() =>
      _ProdukTerlarisDashboardState();
}

class _ProdukTerlarisDashboardState extends State<ProdukTerlarisDashboard>
    with SingleTickerProviderStateMixin {
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF8E8E8E);
  static const Color _green = Color(0xFF2C4E40);
  static const double _radius = 16;

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar 1:1 ratio ──
            AspectRatio(
              aspectRatio: 1.0,
              child: _buildImageSection(),
            ),
            // ── Info: area tap untuk navigasi ──
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
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (_, i) => _buildSingleImage(displayImages[i]),
                ),
              ),

        // ── Overlay Habis ──
        if (habis)
          Container(
            color: Colors.black.withValues(alpha: 0.45),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Stok Habis',
                style: AppColors.fontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFEE2737),
                ),
              ),
            ),
          ),

        // ── Badge Kiri Atas (diperbesar) ──
        if (!habis && (widget.badgeLabel != null || widget.stok <= 5))
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.badgeLabel == 'Milik Anda'
                    ? const Color(0xFF407BFF)
                    : widget.badgeLabel != null
                        ? _green
                        : const Color(0xFFED6723),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.badgeLabel ?? 'Sisa ${widget.stok}',
                style: AppColors.fontStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),

        // ── Badge Terlaris (diperbesar) ──
        if (!habis && widget.badgeLabel == null && widget.stok > 5)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 12, color: Color(0xFFFFC107)),
                  const SizedBox(width: 3),
                  Text(
                    'Terlaris',
                    style: AppColors.fontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Tombol Favorit (diperbesar)
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: widget.aksiFavorite,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 17,
                    color: widget.isLiked
                        ? const Color(0xFFEE2737)
                        : const Color(0xFF2F2828),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.totalLikes}',
                    style: AppColors.fontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F2828),
                    ),
                  ),
                ],
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
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
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF0F2F1),
        child:
            const Icon(Icons.image_rounded, color: Color(0xFFBDBDBD), size: 36),
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

  /// Chip rating ala marketplace: "★ 4.8"
  Widget _ratingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFA000)),
          const SizedBox(width: 3),
          Text(
            formatRating(widget.rating),
            style: AppColors.fontStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8A5A00),
            ),
          ),
        ],
      ),
    );
  }

  // Catatan:
  // - Padding & spacing dirapatkan supaya konten selalu muat di dalam
  //   Expanded walau GridView pakai mainAxisExtent tetap (mis. 340).
  // - Expanded kosong di tengah menyerap sisa ruang vertikal supaya blok
  //   harga + tombol selalu menempel rapi di bawah card, bukan menyisakan
  //   celah kosong di bawah tombol.
  Widget _buildInfoSection() {
    final bisaDitambah = widget.stok > 0 && widget.badgeLabel != 'Milik Anda';
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama produk
          Text(
            widget.namaProduk,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppColors.fontStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _dark,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 5),

          // Rating chip + jumlah ulasan
          Row(
            children: [
              _ratingChip(),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${widget.jumlahReview} ulasan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppColors.fontStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Nama Toko
          if (widget.namaToko != null)
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipOval(
                    child: widget.fotoToko != null &&
                            widget.fotoToko!.isNotEmpty &&
                            getFotoTokoUrl(widget.fotoToko).isNotEmpty
                        ? Image.network(
                            getFotoTokoUrl(widget.fotoToko),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.store_rounded,
                                  size: 9, color: Color(0xFF8E8E8E)),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.store_rounded,
                                size: 9, color: Color(0xFF8E8E8E)),
                          ),
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

          // Spacer fleksibel: mendorong blok harga + tombol ke bawah card
          const Expanded(child: SizedBox()),

          // Harga
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: 'Rp ${formatCurrency(widget.harga)}',
              style: AppColors.fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _dark,
              ),
              children: [
                TextSpan(
                  text: ' /hari',
                  style: AppColors.fontStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Tombol Sewa
          SizedBox(
            width: double.infinity,
            child: Material(
              color: bisaDitambah ? _green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: bisaDitambah ? widget.aksiKeranjang : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sewa',
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: bisaDitambah ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 14,
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

