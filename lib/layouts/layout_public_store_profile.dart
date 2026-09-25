import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/models/store_model.dart';
import 'package:project_camp_sewa/services/api_store.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:shimmer/shimmer.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/components/card/produk_card.dart';
import 'package:project_camp_sewa/components/bottomsheet/bottom_sheet_produk.dart';

class PublicStoreController extends GetxController {
  final int idUser;
  PublicStoreController(this.idUser);

  final ApiStore _apiStore = Get.put(ApiStore());

  // Controller untuk Text Field agar bisa di-clear
  final TextEditingController searchController = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────────────
  var isLoading = true.obs;
  var isLoadingProducts = false.obs;
  var errorMessage = Rx<String?>(null);

  // ── Store profile data ────────────────────────────────────────────────────
  var storeName = ''.obs;
  var storeDesc = ''.obs;
  var storeBanner = Rx<String?>(null);
  var storeLogo = Rx<String?>(null);
  var rating = 0.0.obs;
  var totalReviews = 0.obs;
  var totalProducts = 0.obs;
  var totalTransactions = 0.obs;
  var joinDate = ''.obs;
  var location = ''.obs;

  // ── Products + filter ─────────────────────────────────────────────────────
  var products = <ProdukModel>[].obs;
  var categories = <String>['Semua'].obs;
  var selectedCategory = 'Semua'.obs;

  // Gunakan rawSearchQuery untuk trigger Debounce
  var rawSearchQuery = ''.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStoreProfile();

    // FIX BUG: Gunakan Debounce dari GetX untuk mencegah spam API saat mengetik
    debounce(rawSearchQuery, (String query) {
      searchQuery.value = query;
      fetchStoreProducts();
    }, time: const Duration(milliseconds: 600));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchStoreProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _apiStore.getStoreProfile(idUser);

    if (result.store != null) {
      final StoreModel store = result.store!;
      storeName.value = store.namaStore;
      storeDesc.value = store.deskripsiToko;
      storeBanner.value = store.bannerToko;
      storeLogo.value = store.fotoToko;
      rating.value = store.ratingToko;
      totalReviews.value = store.totalUlasan;
      totalProducts.value = store.totalProdukAktif;
      totalTransactions.value = store.totalTransaksiSelesai;
      joinDate.value = store.formattedJoinDate;
      location.value = store.alamat?.displayLocation ?? '';

      await fetchStoreProducts();
    } else {
      errorMessage.value = result.errorMessage;
    }

    isLoading.value = false;
  }

  Future<void> fetchStoreProducts() async {
    isLoadingProducts.value = true;

    final result = await _apiStore.getStoreProducts(
      idUser,
      kategori:
          selectedCategory.value == 'Semua' ? null : selectedCategory.value,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
    );

    products.assignAll(result.products);

    if (selectedCategory.value == 'Semua' && searchQuery.value.isEmpty) {
      final Set<String> cats = {'Semua'};
      for (final p in result.products) {
        if (p.kategori.isNotEmpty) cats.add(p.kategori);
      }
      categories.assignAll(cats.toList());
    }

    isLoadingProducts.value = false;
  }

  void filterByCategory(String cat) {
    if (selectedCategory.value == cat) return;
    selectedCategory.value = cat;
    fetchStoreProducts();
  }

  void onSearch(String query) {
    // Hanya update raw query, biarkan debounce worker yang mengeksekusi fetch
    rawSearchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    rawSearchQuery.value = '';
  }

  void retry() => fetchStoreProfile();
}

class LayoutPublicStoreProfile extends StatelessWidget {
  final int idUser;
  final String? initialStoreName;
  final String? initialStoreLogo;

  const LayoutPublicStoreProfile({
    super.key,
    required this.idUser,
    this.initialStoreName,
    this.initialStoreLogo,
  });

  @override
  Widget build(BuildContext context) {
    final PublicStoreController controller =
        Get.put(PublicStoreController(idUser), tag: idUser.toString());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          if (controller.errorMessage.value != null) {
            return _buildErrorState(controller);
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(controller),
              SliverToBoxAdapter(
                child: _buildStoreProfileInfo(controller),
              ),
              // Search & Filter Category dibuat STICKY
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyFilterDelegate(
                  controller: controller,
                  // Search bar lebih tinggi & lega + jarak ke kategori lebih proporsional
                  maxExtentHeight: 132,
                  minExtentHeight: 132,
                ),
              ),
              _buildProductGrid(controller, context),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        }),
      ),
    );
  }

  // ── 1. Banner Header ──────────────────────────────────────────────────────
  Widget _buildSliverAppBar(PublicStoreController controller) {
    final String? bannerUrl = controller.storeBanner.value != null &&
            controller.storeBanner.value!.isNotEmpty
        ? getBannerTokoUrl(controller.storeBanner.value)
        : null;

    return SliverAppBar(
      expandedHeight: 180.0,
      pinned: true,
      backgroundColor: AppColors.mainColor,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.share_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (bannerUrl != null)
              Image.network(bannerUrl, fit: BoxFit.cover)
            else
              Container(color: AppColors.mainColor),
            // Overlay gradient agar teks/icon back selalu terbaca
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Informasi Toko ─────────────────────────────────────────────────────
  Widget _buildStoreProfileInfo(PublicStoreController controller) {
    final String logoUrl = getFotoTokoUrl(controller.storeLogo.value);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                child: ClipOval(
                  child: logoUrl.isNotEmpty
                      ? Image.network(logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              _buildLogoPlaceholder(controller))
                      : _buildLogoPlaceholder(controller),
                ),
              ),
              const SizedBox(width: 16),
              // Nama & Lokasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.storeName.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (controller.location.value.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.grey.shade500, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              controller.location.value,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Tombol Follow (70%) & Kirim Pesan (30%)
          Row(
            children: [
              Expanded(
                flex: 7,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
                  label: const Text("Ikuti",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mainColor,
                    side: const BorderSide(color: AppColors.mainColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                  label: const Text("Pesan",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),

          if (controller.storeDesc.value.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              "Deskripsi Toko",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.storeDesc.value,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade700, height: 1.5),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () =>
                    _showFullStoreDescription(controller.storeDesc.value),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    "Selengkapnya",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainColor,
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          // Statistik Toko
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(controller.rating.value.toStringAsFixed(1),
                    "Rating", Icons.star_rounded, const Color(0xFFFFC107)),
                Container(height: 24, width: 1, color: Colors.grey.shade300),
                _buildStatItem(
                    controller.totalProducts.value.toString(),
                    "Produk",
                    Icons.inventory_2_rounded,
                    const Color(0xFF407BFF)),
                Container(height: 24, width: 1, color: Colors.grey.shade300),
                _buildStatItem(
                    controller.totalTransactions.value.toString(),
                    "Terjual",
                    Icons.shopping_bag_rounded,
                    const Color(0xFF10B981)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E))),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showFullStoreDescription(String description) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deskripsi Toko",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tutup",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoPlaceholder(PublicStoreController controller) {
    final name = controller.storeName.value;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.mainColor.withOpacity(0.1),
      child: Center(
        child: Text(initial,
            style: TextStyle(
                color: AppColors.mainColor,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── 3. Grid Produk ────────────────────────────────────────────────────────
  Widget _buildProductGrid(
      PublicStoreController controller, BuildContext context) {
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.mainColor)),
          ),
        );
      }

      if (controller.products.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(MdiIcons.packageVariantClosed,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    controller.searchQuery.value.isNotEmpty
                        ? 'Produk "${controller.searchQuery.value}" tidak ditemukan.'
                        : 'Etalase toko masih kosong.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 340, // Sesuaikan tinggi dengan ukuran komponen card
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              ProdukModel produk = controller.products[index];
              return ProdukCard(
                badgeLabel: produk.kategori,
                images: produk.images,
                namaProduk: produk.namaProduk,
                namaToko: produk.namaToko,
                fotoToko: produk.fotoToko,
                ratingToko: produk.ratingToko,
                harga: produk.harga.toString(),
                rating: produk.rating.toString(),
                stok: produk.stok,
                jumlahReview: produk.jumlahReview,
                isLiked: produk.isLiked,
                totalLikes: produk.totalLikes,
                aksiFavorite: () async {
                  final apiProduk = Get.find<ApiProduk>();
                  final res =
                      await apiProduk.toggleLike(produk.idProduk.toString());
                  if (res['success'] == true) {
                    produk.isLiked = res['is_liked'] ?? false;
                    produk.totalLikes = res['total_likes'] ?? 0;
                    controller.products.refresh();
                  }
                },
                aksi: () {
                  Get.to(() => const LayoutDetailProduct(), arguments: {
                    'idToko': produk.idUser,
                    'idProduk': produk.idProduk,
                    'namaProduk': produk.namaProduk,
                    'fotoProduk': produk.image,
                    'namaToko': produk.namaToko,
                    'fotoToko': produk.fotoToko,
                    'ratingToko': produk.ratingToko,
                  });
                },
                aksiKeranjang: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return BottomSheetProduk(
                        image: produk.image,
                        namaProduk: produk.namaProduk,
                        harga: produk.harga.toString(),
                        idProduk: produk.idProduk,
                        idToko: produk.idUser,
                        namaToko: produk.namaToko,
                      );
                    },
                  );
                },
              );
            },
            childCount: controller.products.length,
          ),
        ),
      );
    });
  }

  // ── Layout Error & Shimmer ──
  Widget _buildErrorState(PublicStoreController controller) {
    return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: AppColors.mainColor),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.storefront, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Gagal memuat toko", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          TextButton(
              onPressed: controller.retry, child: const Text("Coba Lagi"))
        ])));
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
                height: 200, width: double.infinity, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Row(
                children: [
                  Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 20, width: 150, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 14, width: 100, color: Colors.white),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── KELAS DELEGATE UNTUK STICKY HEADER (Search & Kategori) ─────────────────
// ─────────────────────────────────────────────────────────────────────────────
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final PublicStoreController controller;
  final double minExtentHeight;
  final double maxExtentHeight;

  _StickyFilterDelegate({
    required this.controller,
    required this.minExtentHeight,
    required this.maxExtentHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Menambahkan shadow ringan saat menempel di atas (sticky)
    final bool isPinned = shrinkOffset > 0;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          boxShadow: isPinned
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Search Bar ──
            // FIX: tinggi ditambah + prefixIcon diberi constraint & textAlignVertical
            // supaya icon dan placeholder benar-benar center, tidak "melenceng".
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() => TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearch,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 14, height: 1.2),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Cari di ${controller.storeName.value}...",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 22, color: Colors.grey.shade400),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 46, minHeight: 46),
                        // Tampilkan tombol [X] jika ada text pencarian
                        suffixIcon: controller.rawSearchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded,
                                    size: 18, color: Colors.grey.shade600),
                                splashRadius: 18,
                                onPressed: controller.clearSearch,
                              )
                            : null,
                        suffixIconConstraints:
                            const BoxConstraints(minWidth: 40, minHeight: 40),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    )),
              ),
            ),
            // ── Categories / Pills ──
            SizedBox(
              height: 40,
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      String cat = controller.categories[index];
                      bool isSelected =
                          controller.selectedCategory.value == cat;

                      return GestureDetector(
                        onTap: () => controller.filterByCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8, bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.mainColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.mainColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => maxExtentHeight;

  @override
  double get minExtent => minExtentHeight;

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return oldDelegate.controller != controller;
  }
}
