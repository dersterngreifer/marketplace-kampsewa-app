import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/components/card/item_variant.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/constants/database_helper.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/layouts/layout_ulasan_produk.dart';

class LayoutDetailProduct extends StatefulWidget {
  const LayoutDetailProduct({super.key});

  @override
  State<LayoutDetailProduct> createState() => _LayoutDetailProductState();
}

class _LayoutDetailProductState extends State<LayoutDetailProduct> {
  final ApiProduk apiProduk = Get.put(ApiProduk());
  // PageController dikelola secara lokal di _buildSliverAppBar
  // agar tidak stale saat imageList berubah panjang
  
  int currentIndex = 0;
  int quantity = 1;
  String? selectedWarna;
  String? selectedUkuran;
  String? harga;
  String? stok;
  
  int? idToko;
  int? idProduk;
  String? namaProduk;
  String? namaToko;
  String? fotoToko;
  double? ratingToko;
  String? fotoProduk;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    idToko = arguments['idToko'];
    idProduk = arguments['idProduk'];
    namaProduk = arguments['namaProduk'];
    fotoProduk = arguments['fotoProduk'];
    namaToko = arguments['namaToko'];
    fotoToko = arguments['fotoToko'];
    ratingToko = arguments['ratingToko'];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (idProduk != null) {
        // Fetch product info
        await apiProduk.getDetailProduk(context, idProduk.toString());
        if (!mounted) return;
        // Fetch product variants (colors & sizes)
        await apiProduk.getProdukBottomSheet(context, null, null, idProduk.toString());
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  String formatCurrency(String numberString) {
    if (numberString.isEmpty) return '0';
    final number = int.tryParse(numberString) ?? 0;
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  }

  String formatRating(String numberString) {
    final number = double.tryParse(numberString) ?? 0.0;
    return number.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isLoading ? _buildShimmerBody() : _buildBody(),
      bottomNavigationBar: isLoading ? _buildShimmerBottomBar() : _buildBottomBar(),
    );
  }

  Widget _buildShimmerBody() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
            // Content placeholder
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 60, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                      const SizedBox(width: 12),
                      Container(width: 80, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(width: 250, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 16),
                  Container(width: double.infinity, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 24),
                  Container(width: 80, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(4, (index) => Container(
                      width: 60, height: 40, 
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))
                    )),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 100, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      Container(width: 120, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(width: double.infinity, height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBottomBar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 140, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    try {
      return CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildProductInfo(),
          ),
        ],
      );
    } catch (e, stack) {
      debugPrint('Error building detail produk: $e\n$stack');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Terjadi kesalahan menampilkan produk.\n$e',
              textAlign: TextAlign.center,
              style: AppColors.fontStyle(fontSize: 13, color: Colors.red)),
        ),
      );
    }
  }

  Widget _buildSliverAppBar() {
    const double thumbStripHeight = 76.0;
    final double imgHeight = MediaQuery.of(context).size.width;

    return SliverAppBar(
      expandedHeight: imgHeight + thumbStripHeight,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2F2828), size: 20),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Obx(() {
          List<String> imageList = apiProduk.imageDetailProduk
              .where((u) => u.isNotEmpty)
              .toList();
          if (imageList.isEmpty && fotoProduk != null) {
            imageList = [fotoProduk!];
          }
          if (imageList.isEmpty) {
            return Container(
              color: const Color(0xFFF0F2F1),
              child: const Center(
                child: Icon(Icons.image_not_supported,
                    size: 50, color: Colors.grey),
              ),
            );
          }

          final pageCtrl = PageController(initialPage: currentIndex);

          return Column(
            children: [
              // ── Gambar Utama ──
              SizedBox(
                height: imgHeight,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageCtrl,
                      itemCount: imageList.length,
                      onPageChanged: (i) => setState(() => currentIndex = i),
                      itemBuilder: (_, i) {
                        final fullUrl = resolveFullUrl(
                            imageList[i],
                            ApiEndpoints.authendpoints.getImageProduk);
                        return Image.network(
                          fullUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : Container(
                                      color: const Color(0xFFF0F2F1),
                                      child: const Center(
                                        child: Icon(Icons.image_rounded,
                                            color: Color(0xFFBDBDBD),
                                            size: 48),
                                      ),
                                    ),
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF0F2F1),
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded,
                                  color: Color(0xFFBDBDBD), size: 48),
                            ),
                          ),
                        );
                      },
                    ),
                    // Counter badge "2 / 4"
                    if (imageList.length > 1)
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${imageList.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Thumbnail Strip ──
              Container(
                height: thumbStripHeight,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: imageList.length > 1
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageList.length,
                        itemBuilder: (_, i) {
                          final isActive = currentIndex == i;
                          final fullUrl = resolveFullUrl(
                              imageList[i],
                              ApiEndpoints.authendpoints.getImageProduk);
                          return GestureDetector(
                            onTap: () {
                              setState(() => currentIndex = i);
                              pageCtrl.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.mainColor
                                      : Colors.grey.shade300,
                                  width: isActive ? 2.5 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  fullUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF0F2F1),
                                    child: const Icon(Icons.image_rounded,
                                        size: 20,
                                        color: Color(0xFFBDBDBD)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating and Reviews Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF57C00), size: 18),
                      const SizedBox(width: 4),
                      Obx(() {
                        final list = apiProduk.detailProduk.value;
                        return Text(
                          list != null ? formatRating(list.rating) : "0.0",
                          style: AppColors.fontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF57C00),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  final list = apiProduk.detailProduk.value;
                  return Text(
                    "${list != null ? list.totalUlasan : 0} Ulasan",
                    style: AppColors.fontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF757575),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            
            // Product Name
            Obx(() {
              final list = apiProduk.detailProduk.value;
              return Text(
                list?.namaProduk ?? namaProduk ?? 'Memuat...',
                style: AppColors.fontStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2F2828),
                ),
              );
            }),
            const SizedBox(height: 12),

            // Store Info Container
            if (namaToko != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: fotoToko != null 
                          ? Image.network(
                              fotoToko!.startsWith('http') 
                                ? fotoToko! 
                                : '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getFotoProfile}${fotoToko!}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.store, color: Colors.grey),
                            )
                          : const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaToko!,
                            style: AppColors.fontStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2F2828),
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (ratingToko != null && ratingToko! > 0)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFED6723)),
                                const SizedBox(width: 4),
                                Text(
                                  ratingToko!.toStringAsFixed(1),
                                  style: AppColors.fontStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF616161),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              "Belum ada rating",
                              style: AppColors.fontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Description
            Obx(() {
              final list = apiProduk.detailProduk.value;
              return Text(
                list?.deskripsiProduk ?? 'Tidak ada deskripsi.',
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF616161),
                  height: 1.5,
                ),
              );
            }),
            const SizedBox(height: 24),
            
            // Variants
            Text(
              "Warna",
              style: AppColors.fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F2828),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: Obx(() {
                List<String> listWarna = apiProduk.colors;
                if (listWarna.isEmpty) return const Text("Tidak ada varian warna");
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final color = listWarna[index];
                    return ItemVariant(
                      item: color,
                      selected: selectedWarna == color,
                      aksi: () {
                        apiProduk.updateAllUniqueSizes(color: color);
                        setState(() {
                          selectedWarna = color;
                          selectedUkuran = null; // reset ukuran saat warna berubah
                          harga = null;
                          stok = null;
                          quantity = 1;
                        });
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: listWarna.length,
                );
              }),
            ),
            const SizedBox(height: 20),
            
            Text(
              "Ukuran",
              style: AppColors.fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F2828),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: Obx(() {
                List<String> listUkuran = apiProduk.uniqueSizes;
                if (listUkuran.isEmpty) return const Text("Pilih warna terlebih dahulu");
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final size = listUkuran[index];
                    return ItemVariant(
                      item: size,
                      selected: selectedUkuran == size,
                      aksi: () {
                        setState(() {
                          selectedUkuran = size;
                          quantity = 1;
                        });
                        if (selectedWarna != null && selectedUkuran != null) {
                          var result = apiProduk.getStockAndPrice(
                              selectedWarna!, selectedUkuran!);
                          if (result != null) {
                            setState(() {
                              harga = result['harga'].toString();
                              stok = result['stok'].toString();
                            });
                          }
                        }
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: listUkuran.length,
                );
              }),
            ),
            const SizedBox(height: 30),

            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Jumlah Sewa",
                  style: AppColors.fontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2828),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.remove, size: 20, color: Color(0xFF757575)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          quantity.toString(),
                          style: AppColors.fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2F2828),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          int maxStok = stok != null ? (int.tryParse(stok!) ?? 1) : 1;
                          if (selectedUkuran == null) {
                            CustomSnackBar.show(context, sukses: false,
                                title: "Pilih Varian",
                                teks: "Harap pilih varian untuk mengecek stok maksimal",);
                            return;
                          }
                          if (quantity < maxStok) {
                            setState(() {
                              quantity++;
                            });
                          } else {
                            CustomSnackBar.show(context, sukses: false,
                                title: "Batas Maksimal",
                                teks: "Jumlah tidak boleh melebihi sisa stok ($maxStok)",);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.add, size: 20, color: AppColors.mainColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Input Ulasan Form (Hanya untuk non-owner)
            Obx(() {
              final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
              final isOwner = (currentUserId != null && idToko == currentUserId);
              
              if (isOwner) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Berikan Ulasan Anda",
                      style: AppColors.fontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F2828),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0), // Orange muda
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)), // Orange border
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFF57C00), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Anda sebagai pemilik produk ini tidak bisa memberikan rating dan ulasan.",
                              style: AppColors.fontStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              }
              
              return Column(
                children: [
                  _buildReviewForm(),
                  const SizedBox(height: 40),
                ],
              );
            }),

            // Ulasan List
            _buildUlasanList(),
            const SizedBox(height: 40),

            // Terms & Conditions (Static for now, but formatted nicely)
            _buildSyaratKetentuan(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Berikan Ulasan Anda",
          style: AppColors.fontStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F2828),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Rating:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_border_rounded,
                        color: Color(0xFFBDBDBD),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tulis ulasan Anda di sini...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.mainColor),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      CustomSnackBar.show(context, sukses: true, title: "Info", teks: "Fitur upload foto segera hadir");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 16, color: Color(0xFF616161)),
                          const SizedBox(width: 6),
                          Text(
                            "Tambah Foto",
                            style: AppColors.fontStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF616161),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      CustomSnackBar.show(context, sukses: true, title: "Berhasil", teks: "Ulasan berhasil dikirim!");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Kirim",
                        style: AppColors.fontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUlasanList() {
    final dummyReviews = List.generate(10, (index) => {
      'user': 'Pembeli ${index + 1}',
      'rating': 5,
      'date': '12 Sep 2023',
      'comment': 'Barang sangat bagus dan berkualitas. Cocok untuk camping keluarga.',
      'photos': [
        'https://picsum.photos/200/200?random=$index',
      ],
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ulasan Pembeli",
              style: AppColors.fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F2828),
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => LayoutUlasanProduk(namaProduk: namaProduk ?? 'Produk'));
              },
              child: Text(
                "Lihat Semua",
                style: AppColors.fontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 3, // Tampilkan 3 saja di preview detail
          separatorBuilder: (_, __) => const Divider(height: 32, thickness: 1),
          itemBuilder: (context, index) {
            final review = dummyReviews[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review['user'] as String,
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F2828),
                        ),
                      ),
                    ),
                    Text(
                      review['date'] as String,
                      style: AppColors.fontStyle(
                        fontSize: 11,
                        color: const Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (starIndex) => Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: starIndex < (review['rating'] as int)
                          ? const Color(0xFFFFC107)
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'] as String,
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    color: const Color(0xFF2F2828),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: (review['photos'] as List<String>).map((photo) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(photo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Get.to(() => LayoutUlasanProduk(namaProduk: namaProduk ?? 'Produk'));
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Lihat Semua Ulasan",
              style: AppColors.fontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2F2828),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyaratKetentuan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(MdiIcons.shieldCheckOutline, color: AppColors.mainColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Syarat dan Ketentuan",
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F2828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "1. Menjaminkan Kartu identitas saat pengambilan (KTP, KTM, Kartu Pelajar).\n2. Kerusakan, kehilangan, dan keterlambatan akan dikenakan denda.\n3. Keterlambatan maksimal 2 jam setelah masa sewa habis.",
            style: AppColors.fontStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF616161),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
    final isOwner = (currentUserId != null && idToko == currentUserId);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stok != null)
                    Text(
                      "Sisa Stok: $stok",
                      style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF57C00),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp",
                        style: AppColors.fontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C4E40),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Obx(() {
                        final list = apiProduk.detailProduk.value;
                        final baseHarga = int.tryParse(harga ?? (list != null ? list.hargaSewa.toString() : "0")) ?? 0;
                        final displayHarga = (baseHarga * quantity).toString();
                        return Text(
                          formatCurrency(displayHarga),
                          style: AppColors.fontStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2C4E40),
                          ),
                        );
                      }),
                      Text(
                        "/hari",
                        style: AppColors.fontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isOwner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Milik Anda",
                      style: AppColors.fontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: () async {
                if (selectedWarna != null && selectedUkuran != null) {
                  Map<String, dynamic> newRow = {
                    'id_toko': idToko,
                    'id_produk': idProduk,
                    'nama_toko': namaToko,
                    'foto_produk': fotoProduk,
                    'nama_produk': namaProduk,
                    'variant_warna': selectedWarna,
                    'variant_ukuran': selectedUkuran,
                    'harga': harga,
                    'qty': quantity,
                    'selected': 0
                  };
                  await DatabaseHelper.instance.insertKeranjang(newRow, context);
                } else {
                  CustomSnackBar.show(context, sukses: false,
                      title: "Varian Belum Dipilih",
                      teks: "Harap pilih Warna dan Ukuran terlebih dahulu",);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F2828),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Keranjang",
                      style: AppColors.fontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
