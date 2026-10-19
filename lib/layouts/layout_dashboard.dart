import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/bottomsheet/bottom_sheet_produk.dart';
import 'package:project_camp_sewa/components/card/berita_dash_card.dart';
import 'package:project_camp_sewa/components/card/produk_terlaris_card.dart';
import 'package:project_camp_sewa/components/card/wisata_dash_card.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/layouts/layout_keranjang.dart';
import 'package:project_camp_sewa/layouts/layout_public_store_profile.dart';
import 'package:project_camp_sewa/layouts/layout_search_screen.dart';
import 'package:project_camp_sewa/layouts/layout_detail_berita.dart';
import 'package:project_camp_sewa/layouts/layout_detail_wisata.dart';
import 'package:project_camp_sewa/layouts/layout_list_berita.dart';
import 'package:project_camp_sewa/layouts/layout_list_wisata.dart';
import 'package:project_camp_sewa/models/article_model.dart';
import 'package:project_camp_sewa/models/iklan_model.dart';
import 'package:project_camp_sewa/services/api_article.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/services/api_iklan.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/services/controller_dashboard.dart';
import 'package:project_camp_sewa/services/controller_keranjang.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class LayoutDashboard extends StatefulWidget {
  const LayoutDashboard({super.key});

  @override
  State<LayoutDashboard> createState() => _LayoutDashboardState();
}

class _LayoutDashboardState extends State<LayoutDashboard> {
  static const Color _green = Color(0xFF2C4E40);
  static const Color _greenDark = Color(0xFF1E352B);
  static const Color _dark = Color(0xFF2F2828);
  static const Color _yellow = Color(0xFFFFC107);

  DashboardController pageController = Get.put(DashboardController());
  ApiDataUser apiDataUser = Get.put(ApiDataUser());
  ApiIklan apiIklan = Get.put(ApiIklan());
  ApiProduk apiProduk = Get.put(ApiProduk());
  KeranjangController keranjangController = Get.put(KeranjangController());
  ApiArticle apiArticle = Get.put(ApiArticle());

  String selectedCategoryLabel = 'Semua';

  final CarouselSliderController carouselController =
      CarouselSliderController();
  int currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiDataUser.getDataUser(context);
      apiIklan.getIklan(context);
      apiProduk.getListKategori();
      // getFeaturedProduk (rekomendasi endpoint) supaya produk selalu tampil di Home.
      apiProduk.getFeaturedProduk(context);
      // Load keranjang agar badge icon langsung terupdate
      keranjangController.loadKeranjang(context);
      // Ambil rekomendasi wisata dan berita terkini dinamis dari backend database
      apiArticle.fetchWisataDashboard(limit: 6);
      apiArticle.fetchBeritaDashboard(limit: 5);
    });
  }

  /// Filter kategori dilakukan lokal berdasarkan nama produk,
  /// karena getFeaturedProduk tidak menerima parameter kategori.
  List<dynamic> _applyCategoryFilter(Iterable<dynamic> source) {
    if (selectedCategoryLabel == 'Semua') return source.toList();
    return source.where((p) => p.kategori == selectedCategoryLabel).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8F7),
        body: SafeArea(
          child: RefreshIndicator(
            color: _green,
            backgroundColor: Colors.white,
            displacement: 30,
            strokeWidth: 3,
            onRefresh: () async {
              apiIklan.getIklan(context);
              apiProduk.getListKategori();
              apiArticle.fetchWisataDashboard(limit: 6);
              apiArticle.fetchBeritaDashboard(limit: 5);
              await apiDataUser.getDataUser(context);
              if (!context.mounted) return;
              await apiProduk.getFeaturedProduk(context);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildCategories(),
                  const SizedBox(height: 8),
                  _buildPromoBanner(),
                  const SizedBox(height: 18),
                  _buildFeaturedProducts(),
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    "Rekomendasi Wisata",
                    actionLabel: "Lihat Semua",
                    onAction: () => Get.to(() => const LayoutListWisata()),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 210,
                    child: Obx(() {
                      if (apiArticle.isLoadingWisataDashboard.value &&
                          apiArticle.listWisataDashboard.isEmpty) {
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (_, __) => Container(
                            width: 270,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const _ShimmerBox(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(22)),
                            ),
                          ),
                        );
                      }

                      final items = apiArticle.listWisataDashboard.isNotEmpty
                          ? apiArticle.listWisataDashboard
                          : <ArticleModel>[];

                      if (items.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.terrain_rounded,
                                      size: 38, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Belum ada rekomendasi wisata saat ini",
                                    style: AppColors.fontStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          ArticleModel list = items[index];
                          return WisataCard(
                            image: list.gambar,
                            title: list.judul,
                            deskripsi: list.deskripsiSingkat,
                            lokasi: list.lokasi ?? '',
                            url: list.sumberUrl ?? '',
                            onTap: () {
                              Get.to(() =>
                                  LayoutDetailWisata(initialArticle: list));
                            },
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 14),
                        itemCount: items.length,
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    "Berita Terkini",
                    actionLabel: "Lihat Semua",
                    onAction: () => Get.to(() => const LayoutListBerita()),
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    if (apiArticle.isLoadingBeritaDashboard.value &&
                        apiArticle.listBeritaDashboard.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                height: 92,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const _ShimmerBox(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final items = apiArticle.listBeritaDashboard.isNotEmpty
                        ? apiArticle.listBeritaDashboard
                        : <ArticleModel>[];

                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.newspaper_rounded,
                                  size: 38, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                "Belum ada berita terkini saat ini",
                                style: AppColors.fontStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 4),
                      clipBehavior: Clip.none,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        ArticleModel list = items[index];
                        return BeritaCard(
                          image: list.gambar,
                          title: list.judul,
                          source: (list.sumberNama != null &&
                                  list.sumberNama!.trim().isNotEmpty)
                              ? list.sumberNama!.trim()
                              : 'Berita',
                          url: list.sumberUrl ?? '',
                          date: list.waktuLalu.isNotEmpty
                              ? list.waktuLalu
                              : list.tanggalUpload,
                          onTap: () {
                            Get.to(() =>
                                LayoutDetailBerita(initialArticle: list));
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: items.length,
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Foto profil & Sapaan (satu paket tombol menuju Profile)
          Expanded(
            child: InkWell(
              onTap: () {
                if (Get.isRegistered<DashboardController>()) {
                  Get.find<DashboardController>().setPageIndex(4);
                } else {
                  pageController.setPageIndex(4);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Foto profil
                    Obx(() {
                      final user = apiDataUser.dataUser.value;
                      final imageUrl = user?.image ?? '';
                      final name = user?.name ?? '---';
                      return Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _green.withValues(alpha: 0.35), width: 2),
                        ),
                        child:
                            ClipOval(child: _buildProfileImage(imageUrl, name)),
                      );
                    }),
                    const SizedBox(width: 12),

                    // Sapaan
                    Expanded(
                      child: Obx(() {
                        final user = apiDataUser.dataUser.value;
                        final name = user?.name ?? '---';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selamat datang kembali 👋",
                              style: AppColors.fontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8E8E8E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: AppColors.fontStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _dark,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Ikon keranjang + badge jumlah
          Obx(() {
            final itemCount = keranjangController.items.length;
            return InkWell(
              onTap: () => Get.to(() => const LayoutKeranjang()),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: _dark, size: 23),
                    if (itemCount > 0)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          constraints:
                              const BoxConstraints(minWidth: 18, minHeight: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEE2737),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            itemCount > 9 ? "9+" : "$itemCount",
                            style: AppColors.fontStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl, String name) {
    String getInitials(String str) {
      if (str.trim().isEmpty) return "US";
      List<String> words = str.trim().split(RegExp(r'\s+'));
      String initials = "";
      for (var i = 0; i < words.length && i < 3; i++) {
        if (words[i].isNotEmpty) {
          initials += words[i][0].toUpperCase();
        }
      }
      return initials.isNotEmpty ? initials : "US";
    }

    Widget fallbackAvatar() {
      return Container(
        width: 42,
        height: 42,
        color: _green,
        alignment: Alignment.center,
        child: Text(
          getInitials(name),
          style: AppColors.fontStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (imageUrl.isEmpty) return fallbackAvatar();

    final fullUrl =
        resolveFullUrl(imageUrl, ApiEndpoints.authendpoints.getFotoProfile);

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      width: 42,
      height: 42,
      errorBuilder: (_, __, ___) => fallbackAvatar(),
    );
  }

  // ── Search Bar ──────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => Get.to(const LayoutSearchScreen()),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: _green, size: 22),
              const SizedBox(width: 12),
              Text(
                "Cari alat camping...",
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Chips ──────────────────────────────────────

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'semua':
        return Icons.apps_rounded;
      case 'tenda':
        return Icons.holiday_village_rounded;
      case 'pakaian':
        return Icons.checkroom_rounded;
      case 'tas & sepatu':
        return Icons.backpack_rounded;
      case 'peralatan':
        return Icons.construction_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 56,
      child: Obx(() {
        final List<String> categories = ['Semua', ...apiProduk.listKategori];
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = cat == selectedCategoryLabel;
            return GestureDetector(
              onTap: () => setState(() => selectedCategoryLabel = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? _green : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? _green.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: isSelected ? 10 : 4,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(cat),
                      size: 16,
                      color:
                          isSelected ? Colors.white : const Color(0xFF8E8E8E),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      cat,
                      style: AppColors.fontStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ── Promo Banner Carousel ───────────────────────────────

  Widget _buildPromoBanner() {
    return Obx(() {
      final iklanList = apiIklan.listIklan;
      if (iklanList.isEmpty) {
        return _buildEmptyIklanState();
      }

      final int bannerCount = iklanList.length;

      final double screenWidth = MediaQuery.of(context).size.width;
      // Lebar kartu banner dengan margin horizontal 16 di setiap sisi (total 32)
      final double bannerWidth = (screenWidth - 32).clamp(280.0, 600.0);
      final double bannerImgHeight = bannerWidth * 9 / 16;
      // Foto 16:9 + gap 8 + info card rapat (Expanded dengan judul, sub judul, deskripsi)
      final double carouselHeight = bannerImgHeight + 152;

      return Column(
        children: [
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              height: carouselHeight,
              scrollPhysics: const ClampingScrollPhysics(),
              autoPlay: bannerCount > 1,
              autoPlayInterval: const Duration(seconds: 4),
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() => currentBannerIndex = index);
              },
            ),
            items: List.generate(bannerCount, (index) {
              return _buildApiBannerItem(iklanList[index]);
            }),
          ),
          if (bannerCount > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerCount, (i) {
                final active = currentBannerIndex == i;
                return GestureDetector(
                  onTap: () => carouselController.animateToPage(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: active ? 22 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: active ? _green : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      );
    });
  }

  // ── CTA Button ──────────────────────────────────────────

  Widget _buildCtaButton({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => pageController.setPageIndex(1),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
        decoration: BoxDecoration(
          color: _yellow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _yellow.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Checkout Sekarang",
              style: AppColors.fontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward_rounded, size: 14, color: _dark),
          ],
        ),
      ),
    );
  }

  /// Popup modal bottom sheet untuk menampilkan poster 16:9 dan deskripsi lengkap promo
  void _showPromoDetailBottomSheet({
    required String title,
    required String poster,
    required String description,
    VoidCallback? onCheckout,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle drag bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header modal
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.campaign_rounded,
                              size: 18, color: _green),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Detail Promo & Diskon",
                          style: AppColors.fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: Colors.grey.shade600,
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, thickness: 1),
              // Isi konten detail promo
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster full 16:9
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _buildIklanImage(poster),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Judul Promo (Lebih besar & hitam pekat)
                      Text(
                        title,
                        style: AppColors.fontStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tag Promo
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_offer_rounded,
                                size: 14, color: _green),
                            const SizedBox(width: 6),
                            Text(
                              "Promo Terbatas KampSewa",
                              style: AppColors.fontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Heading Deskripsi
                      Text(
                        "Deskripsi Promo",
                        style: AppColors.fontStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Deskripsi Lengkap (Hitam pekat)
                      Text(
                        description.isNotEmpty
                            ? description
                            : "Dapatkan penawaran promo dan diskon sewa alat camping terbaik dengan harga terjangkau di KampSewa. Pesan sekarang sebelum periode promo berakhir!",
                        style: AppColors.fontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E1E1E),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tombol Checkout Sekarang di bagian bawah modal
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (onCheckout != null) {
                        onCheckout();
                      } else {
                        pageController.setPageIndex(1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Checkout Sekarang",
                          style: AppColors.fontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Banner dari API iklan — foto & info dipisah jadi dua container terpisah
  Widget _buildApiBannerItem(IklanModel iklan) {
    final descText = iklan.deskripsi.trim().isNotEmpty
        ? iklan.deskripsi.trim()
        : "Dapatkan penawaran promo dan diskon sewa alat camping terbaik dengan harga terjangkau di KampSewa.";

    void navigateToPromoTarget() {
      if (iklan.isProductTarget) {
        Get.to(
          () => const LayoutDetailProduct(),
          arguments: {
            if (iklan.idToko != null && iklan.idToko! > 0)
              'idToko': iklan.idToko,
            'idProduk': iklan.idProduk,
          },
        );
      } else if (iklan.idToko != null && iklan.idToko! > 0) {
        Get.to(() => LayoutPublicStoreProfile(idUser: iklan.idToko!));
      } else {
        pageController.setPageIndex(1);
      }
    }

    void openPromoDetail() {
      _showPromoDetailBottomSheet(
        title: iklan.judul,
        poster: iklan.poster,
        description: descText,
        onCheckout: navigateToPromoTarget,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── FOTO PROMO — container sendiri ──
          GestureDetector(
            onTap: openPromoDetail,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildIklanImage(iklan.poster),
                      if (iklan.badgePromo != null &&
                          iklan.badgePromo!.trim().isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _yellow,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_offer_rounded,
                                  size: 13,
                                  color: _dark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  iklan.badgePromo!.trim(),
                                  style: AppColors.fontStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: _dark,
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
          ),

          const SizedBox(height: 8),

          // ── INFO PROMO — container terpisah ──
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE9EDE9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. JUDUL PROMO
                      Text(
                        iklan.judul,
                        style: AppColors.fontStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 2. SUB JUDUL (tagline)
                      if (iklan.subJudul.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          iklan.subJudul.trim(),
                          style: AppColors.fontStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _green,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // 3. DESKRIPSI
                      if (descText.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          descText,
                          style: AppColors.fontStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF616161),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),

                  // AKSI PROMO
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: openPromoDetail,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Selengkapnya",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppColors.fontStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: _green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: _green,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildCtaButton(onTap: navigateToPromoTarget),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIklanImage(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) {
      return _buildIklanPlaceholder();
    }

    // Jika berupa asset lokal bawaan aplikasi Flutter
    if (trimmed.startsWith('assets/images/') ||
        trimmed.startsWith('assets/bg/') ||
        trimmed.startsWith('assets/wisata/')) {
      return Image.asset(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildIklanPlaceholder(),
      );
    }

    // Resolusi URL foto baik http/https maupun path server lokal
    final fullUrl = getFotoIklanUrl(trimmed);
    if (fullUrl.isEmpty) {
      return _buildIklanPlaceholder();
    }

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _buildIklanPlaceholder(loading: true);
      },
      errorBuilder: (_, __, ___) => _buildIklanPlaceholder(),
    );
  }

  Widget _buildIklanPlaceholder({bool loading = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_green, _greenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              )
            : Icon(
                Icons.campaign_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.25),
              ),
      ),
    );
  }

  /// Desain kartu kosong jika belum ada promo iklan yang aktif
  Widget _buildEmptyIklanState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EDE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_outlined,
              size: 32,
              color: _green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Belum Ada Promo Aktif",
            style: AppColors.fontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Nantikan penawaran promo dan diskon sewa alat camping terbaik dari mitra KampSewa berikutnya.",
            textAlign: TextAlign.center,
            style: AppColors.fontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured Products ───────────────────────────────────

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Produk Pilihan",
          actionLabel: "Lihat Semua",
          onAction: () => pageController.setPageIndex(1),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (apiProduk.isLoadingHome.value) {
            return _buildProductShimmer();
          }

          final listProduk = _applyCategoryFilter(apiProduk.listProdukHome);

          if (listProduk.isEmpty) {
            return _buildEmptyProduct();
          }

          return GridView.builder(
            padding:
                const EdgeInsets.only(left: 6, right: 6, bottom: 20, top: 4),
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: _buildProductGridDelegate(context),
            itemCount: listProduk.length,
            itemBuilder: (context, index) {
              final p = listProduk[index];
              final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
              final isOwner =
                  (currentUserId != null && p.idUser == currentUserId);

              return ProdukTerlarisDashboard(
                isOwner: isOwner,
                badgeLabel: p.isDiskon && p.persentaseDiskon > 0
                    ? "Diskon ${p.persentaseDiskon}%"
                    : (isOwner ? "Milik Anda" : p.kategori),
                images: p.images,
                namaProduk: p.namaProduk,
                namaToko: p.namaToko,
                fotoToko: p.fotoToko,
                ratingToko: p.ratingToko,
                harga: p.harga.toString(),
                rating: p.rating.toString(),
                stok: p.stok,
                jumlahReview: p.jumlahReview,
                isLiked: p.isLiked,
                totalLikes: p.totalLikes,
                isDiskon: p.isDiskon,
                hargaAsli: p.hargaAsli,
                persentaseDiskon: p.persentaseDiskon,
                aksiFavorite: () async {
                  final res = await apiProduk.toggleLike(p.idProduk.toString());
                  if (res['success'] == true) {
                    p.isLiked = res['is_liked'] ?? false;
                    p.totalLikes = res['total_likes'] ?? 0;
                    apiProduk.listProdukHome.refresh();
                    apiProduk.listProdukRekomendasi.refresh();
                  } else {
                    if (!context.mounted) return;
                    CustomSnackBar.show(context,
                        sukses: false, title: "Gagal", teks: res['message']);
                  }
                },
                aksi: () {
                  Get.to(() => const LayoutDetailProduct(), arguments: {
                    'idToko': p.idUser,
                    'idProduk': p.idProduk,
                    'namaProduk': p.namaProduk,
                    'fotoProduk': p.image,
                    'namaToko': p.namaToko,
                    'fotoToko': p.fotoToko,
                  });
                },
                aksiKeranjang: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return BottomSheetProduk(
                        image: p.image,
                        namaProduk: p.namaProduk,
                        harga: p.harga.toString(),
                        idProduk: p.idProduk,
                        idToko: p.idUser,
                        namaToko: p.namaToko,
                      );
                    },
                  );
                },
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyProduct() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 40, color: _green),
            ),
            const SizedBox(height: 14),
            Text(
              "Belum ada produk tersedia",
              style: AppColors.fontStyle(
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Coba pilih kategori lain",
              style: AppColors.fontStyle(
                color: const Color(0xFF8E8E8E),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const double _productGridInfoHeight = 154.0;
  static const double _productGridHorizontalPadding = 6.0;
  static const double _productGridCrossSpacing = 8.0;

  /// Grid delegate dinamis: tinggi kartu = lebar kartu (foto 1:1) + tinggi info.
  /// Mencegah gap berlebih pada layar kecil dan overflow pada layar besar.
  SliverGridDelegate _buildProductGridDelegate(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const columns = 2;
    final cardWidth = (screenWidth -
            (_productGridHorizontalPadding * 2) -
            (_productGridCrossSpacing * (columns - 1))) /
        columns;
    final cardHeight = cardWidth + _productGridInfoHeight;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisExtent: cardHeight,
      crossAxisSpacing: _productGridCrossSpacing,
      mainAxisSpacing: 10,
    );
  }

  /// Skeleton shimmer untuk grid produk saat loading
  Widget _buildProductShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 20, top: 4),
      clipBehavior: Clip.none,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: _buildProductGridDelegate(context),
      itemCount: 4,
      itemBuilder: (context, index) =>
          _ShimmerBox(borderRadius: BorderRadius.circular(20)),
    );
  }

  // ── Helpers ─────────────────────────────────────────────

  Widget _buildSectionHeader(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _yellow,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppColors.fontStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      actionLabel,
                      style: AppColors.fontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: _green),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final BorderRadius borderRadius;
  const _ShimmerBox({required this.borderRadius});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          color: Color.lerp(
            Colors.grey.shade200,
            Colors.grey.shade100,
            _anim.value,
          ),
        ),
      ),
    );
  }
}
