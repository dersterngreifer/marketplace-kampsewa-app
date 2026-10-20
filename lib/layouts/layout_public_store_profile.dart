import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/layouts/layout_chat_room.dart'
    as project_camp_sewa_chat;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/models/store_model.dart';
import 'package:project_camp_sewa/models/user.dart';
import 'package:project_camp_sewa/services/api_store.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/services/api_follow.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:shimmer/shimmer.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/layouts/layout_informasi_toko.dart';
import 'package:project_camp_sewa/components/card/produk_card.dart';
import 'package:project_camp_sewa/components/bottomsheet/bottom_sheet_produk.dart';
import 'package:project_camp_sewa/components/bottomsheet/bottom_sheet_share_toko.dart';
import 'package:project_camp_sewa/layouts/layout_follow_list.dart';

class PublicStoreController extends GetxController {
  final int idUser;
  PublicStoreController(this.idUser);

  final ApiStore _apiStore = Get.put(ApiStore());
  final ApiFollow _apiFollow = Get.put(ApiFollow());

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

  // ── Follow stats ──────────────────────────────────────────────────────────
  var totalFollowers = 0.obs;
  var totalFollowing = 0.obs;

  /// True jika user yang sedang login sudah mem-follow profil ini.
  var isFollowedByMe = false.obs;

  /// True saat sedang memproses request follow/unfollow (mencegah double tap).
  var isFollowLoading = false.obs;

  /// True jika user ini memiliki toko (mitra).
  var isToko = true.obs;

  // ── Share & kepemilikan profil ────────────────────────────────────────────
  /// Email pemilik toko, dipakai untuk URL share profil.
  var storeEmail = ''.obs;

  /// True kalau profil toko yang dibuka adalah milik user yang sedang login.
  /// Mengganti tombol "Ikuti" menjadi "Edit Profile".
  final isOwner = false.obs;
  Worker? _ownerWorker;

  // ── Products + filter ─────────────────────────────────────────────────────
  var products = <ProdukModel>[].obs;
  var categories = <String>[].obs;
  var selectedCategory = ''.obs;
  /// Diskon produk aktif milik toko (dari GET /api/diskon/toko/{id}).
  var diskonList = <DiskonTokoModel>[].obs;
  var selectedSort = 'latest'.obs;
  var isPromoFilterOnly = false.obs;

  /// Controller & index untuk PageView carousel kartu diskon toko
  final PageController promoPageController = PageController();
  var promoCarouselIndex = 0.obs;

  // Gunakan rawSearchQuery untuk trigger Debounce
  var rawSearchQuery = ''.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _syncOwnership();

    // Data user bisa termuat setelah halaman ini dibuka, jadi ownership
    // perlu ikut diperbarui setiap kali dataUser berubah.
    if (Get.isRegistered<ApiDataUser>()) {
      _ownerWorker = ever<User?>(
        Get.find<ApiDataUser>().dataUser,
        (_) => _syncOwnership(),
      );
    }

    fetchStoreProfile();

    // FIX BUG: Gunakan Debounce dari GetX untuk mencegah spam API saat mengetik
    debounce(rawSearchQuery, (String query) {
      searchQuery.value = query;
      fetchStoreProducts();
    }, time: const Duration(milliseconds: 600));
  }

  @override
  void onClose() {
    _ownerWorker?.dispose();
    searchController.dispose();
    promoPageController.dispose();
    super.onClose();
  }

  void _syncOwnership() {
    final int? currentUserId = Get.isRegistered<ApiDataUser>()
        ? Get.find<ApiDataUser>().dataUser.value?.id
        : null;
    isOwner.value = currentUserId != null && currentUserId == idUser;
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
      storeEmail.value = store.email ?? '';

      // Follow stats dari response
      totalFollowers.value = store.totalFollowers;
      totalFollowing.value = store.totalFollowing;
      isFollowedByMe.value = store.isFollowedByMe;
      isToko.value = store.isToko;

      if (isToko.value) {
        await Future.wait([
          fetchStoreProducts(),
          fetchDiskonToko(),
        ]);
      } else {
        // Jika bukan toko, tidak usah fetch produk. Kosongkan list.
        products.clear();
        diskonList.clear();
        isLoadingProducts.value = false;
      }
    } else {
      errorMessage.value = result.errorMessage;
    }

    isLoading.value = false;
  }

  Future<void> fetchDiskonToko() async {
    diskonList.assignAll(await _apiStore.getDiskonToko(idUser));
  }

  Future<void> fetchStoreProducts() async {
    isLoadingProducts.value = true;

    final result = await _apiStore.getStoreProducts(
      idUser,
      kategori:
          selectedCategory.value.isEmpty || selectedCategory.value == 'Semua'
              ? null
              : selectedCategory.value,
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
      sort: selectedSort.value,
      isPromo: isPromoFilterOnly.value ? true : null,
    );

    products.assignAll(result.products);

    if ((selectedCategory.value.isEmpty || selectedCategory.value == 'Semua') &&
        searchQuery.value.isEmpty) {
      final Set<String> cats = {};
      for (final p in result.products) {
        if (p.kategori.isNotEmpty && p.kategori.toLowerCase() != 'semua') {
          cats.add(p.kategori);
        }
      }
      categories.assignAll(cats.toList());
    }

    isLoadingProducts.value = false;
  }

  void filterByCategory(String cat) {
    if (selectedCategory.value == cat) {
      // Klik lagi untuk membatalkan filter kategori (kembali menampilkan semua produk)
      selectedCategory.value = '';
    } else {
      selectedCategory.value = cat;
    }
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

  void setSort(String sort) {
    if (selectedSort.value == sort) return;
    selectedSort.value = sort;
    fetchStoreProducts();
  }

  void togglePromoFilter() {
    isPromoFilterOnly.value = !isPromoFilterOnly.value;
    fetchStoreProducts();
  }

  void retry() => fetchStoreProfile();

  // ── Aksi: Follow / Unfollow ───────────────────────────────────────────────

  /// Toggle follow/unfollow profil ini.
  /// Menggunakan optimistic UI — stat & state diubah langsung, di-rollback jika gagal.
  Future<void> toggleFollow() async {
    if (isFollowLoading.value) return;
    isFollowLoading.value = true;

    final bool willFollow = !isFollowedByMe.value;

    // Optimistic update
    isFollowedByMe.value = willFollow;
    totalFollowers.value =
        willFollow ? totalFollowers.value + 1 : totalFollowers.value - 1;

    final result = willFollow
        ? await _apiFollow.followUser(idUser)
        : await _apiFollow.unfollowUser(idUser);

    if (!result.success) {
      // Rollback
      isFollowedByMe.value = !willFollow;
      totalFollowers.value =
          willFollow ? totalFollowers.value - 1 : totalFollowers.value + 1;
      Get.snackbar(
        'Gagal',
        result.errorMessage ?? 'Terjadi kesalahan.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }

    isFollowLoading.value = false;
  }

  // ── Navigasi List Followers / Following ───────────────────────────────────

  void openFollowers() {
    Get.to(() => LayoutFollowList(
          idUser: idUser,
          type: FollowListType.followers,
        ));
  }

  void openFollowing() {
    Get.to(() => LayoutFollowList(
          idUser: idUser,
          type: FollowListType.following,
        ));
  }

  // ── Aksi: Share & Edit Profil ─────────────────────────────────────────────

  /// URL profil toko yang dibagikan:
  /// `https://abbmamarketplacekampsewa.com/{emailUser}`
  String get shareUrl => getShareProfileTokoUrl(
        storeEmail.value.isNotEmpty ? storeEmail.value : storeName.value,
      );

  /// Buka bottom sheet khusus share profil toko.
  void shareProfile() {
    BottomSheetShareToko.show(
      namaToko: storeName.value,
      emailPemilik: storeEmail.value,
      logoUrl: storeLogo.value,
    );
  }

  /// Tombol "Ikuti" berubah jadi "Edit Profile" bila profil ini milik sendiri.
  /// Profil dimuat ulang setelah selesai mengedit supaya data yang tampil baru.
  Future<void> goToEditProfile() async {
    await Get.to(() => const LayoutInformasiToko());
    await fetchStoreProfile();
  }
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
                child: _buildStoreProfileInfo(controller, context),
              ),
              // Search & Filter Category dibuat STICKY
              if (controller.isToko.value)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterDelegate(
                    controller: controller,
                    // Tinggi turun drastis: cuma search row + kategori pills
                    maxExtentHeight: 116,
                    minExtentHeight: 116,
                    onOpenFilter: _showFilterBottomSheet,
                  ),
                ),
              if (controller.isToko.value)
                _buildProductGrid(controller, context)
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 32, bottom: 80, left: 20, right: 20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.person_search_rounded,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "Belum ada produk yang disewakan.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (controller.isToko.value)
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
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          tooltip: 'Bagikan Profil Toko',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.share_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => controller.shareProfile(),
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
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
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
  Widget _buildStoreProfileInfo(
      PublicStoreController controller, BuildContext context) {
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
          // Tombol aksi: Ikuti/Mengikuti/Edit Profile (70%) & Kirim Pesan (30%)
          Obx(() {
            final bool isOwner = controller.isOwner.value;
            final bool isFollowed = controller.isFollowedByMe.value;
            final bool isLoading = controller.isFollowLoading.value;

            return Row(
              children: [
                Expanded(
                  flex: 7,
                  child: isOwner
                      ? ElevatedButton.icon(
                          onPressed: controller.goToEditProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 42),
                          ),
                          icon: const Icon(MdiIcons.storeEditOutline, size: 17),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        )
                      // ── Tombol Ikuti / Mengikuti ──────────────────────────
                      : isFollowed
                          ? OutlinedButton.icon(
                              onPressed:
                                  isLoading ? null : controller.toggleFollow,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.mainColor,
                                side: const BorderSide(
                                    color: AppColors.mainColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 42),
                              ),
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.mainColor),
                                    )
                                  : const Icon(Icons.check_rounded, size: 17),
                              label: const Text(
                                'Mengikuti',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed:
                                  isLoading ? null : controller.toggleFollow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mainColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.mainColor.withValues(alpha: 0.6),
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 42),
                              ),
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 17,
                                    ),
                              label: const Text(
                                'Ikuti',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => project_camp_sewa_chat.LayoutChatRoom(
                            targetUserId: controller.idUser,
                            chatData: {
                              'name': controller.storeName.value,
                              'avatar': controller.storeLogo.value,
                              'isToko': true,
                            },
                          ));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mainColor,
                      side: const BorderSide(color: AppColors.mainColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 42),
                    ),
                    icon:
                        const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                    label: const Text('Pesan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            );
          }),

          if (controller.storeDesc.value.isNotEmpty) ...[
            const SizedBox(height: 20),
            Obx(() => Text(
                  controller.isToko.value ? "Deskripsi Toko" : "Informasi",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                )),
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
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
          Obx(() => controller.isToko.value
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                          controller.rating.value.toStringAsFixed(1),
                          "Rating",
                          Icons.star_rounded,
                          const Color(0xFFFFC107)),
                      Container(
                          height: 24, width: 1, color: Colors.grey.shade300),
                      _buildStatItem(
                          controller.totalProducts.value.toString(),
                          "Produk",
                          Icons.inventory_2_rounded,
                          const Color(0xFF407BFF)),
                      Container(
                          height: 24, width: 1, color: Colors.grey.shade300),
                      _buildStatItem(
                          controller.totalTransactions.value.toString(),
                          "Terjual",
                          Icons.shopping_bag_rounded,
                          const Color(0xFF10B981)),
                    ],
                  ),
                )
              : const SizedBox()),

          const SizedBox(height: 12),
          // Statistik Followers & Following (clickable)
          Obx(() => Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: controller.openFollowers,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.people_alt_rounded,
                                  size: 16,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.totalFollowers.value
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1E1E1E),
                                      ),
                                    ),
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: controller.openFollowing,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_circle_rounded,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.totalFollowing.value
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1E1E1E),
                                      ),
                                    ),
                                    Text(
                                      'Following',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          _buildActivePromoBanner(controller, context),
        ],
      ),
    );
  }

  Widget _buildActivePromoBanner(
      PublicStoreController controller, BuildContext context) {
    return Obx(() {
      if (controller.diskonList.isEmpty) return const SizedBox.shrink();

      final int totalPromo = controller.diskonList.length;

      return Container(
        margin: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar: "PROMO TOKO (N)" + Tombol "Lihat Semua Diskon"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C4E40).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer_rounded,
                          size: 13, color: Color(0xFF2C4E40)),
                      const SizedBox(width: 5),
                      Text(
                        'PROMO TOKO ($totalPromo)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C4E40),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showSemuaDiskonBottomSheet(context, controller),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Semua Diskon',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C4E40),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: Color(0xFF2C4E40)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Card Promo: Single Card atau Swipe Carousel jika lebih dari 1
            if (totalPromo == 1)
              _buildSinglePromoCard(
                controller.diskonList.first,
                controller,
              )
            else ...[
              SizedBox(
                height: 136,
                child: PageView.builder(
                  controller: controller.promoPageController,
                  itemCount: totalPromo,
                  onPageChanged: (index) {
                    controller.promoCarouselIndex.value = index;
                  },
                  itemBuilder: (_, index) {
                    final promo = controller.diskonList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildSinglePromoCard(
                        promo,
                        controller,
                        pageIndex: index,
                        totalPages: totalPromo,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Dot Indicator Active Carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPromo, (index) {
                  final isActive =
                      controller.promoCarouselIndex.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF2C4E40)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSinglePromoCard(
    DiskonTokoModel promo,
    PublicStoreController controller, {
    int? pageIndex,
    int? totalPages,
  }) {
    final discountLabel = promo.labelDiskon;
    final cakupanLabel =
        promo.isSemuaProduk ? 'Semua Produk Toko' : 'Produk Tertentu';
    final headline = promo.namaDiskon.isNotEmpty
        ? 'Toko ini sedang mengadakan promo ${promo.namaDiskon}!'
        : 'Toko ini sedang mengadakan promo diskon $discountLabel!';
    final periodeStr = _formatPeriodePromo(
      promo.tanggalMulai,
      promo.tanggalSelesai,
    );

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C4E40), Color(0xFF1E352B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C4E40).withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer_rounded,
                        size: 11, color: Color(0xFF2F2828)),
                    SizedBox(width: 4),
                    Text(
                      'PROMO TOKO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2F2828),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Diskon $discountLabel • $cakupanLabel',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (pageIndex != null && totalPages != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${pageIndex + 1}/$totalPages',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Headline Promo
          Text(
            headline,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Footer: Periode & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        periodeStr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  controller.isPromoFilterOnly.value = true;
                  controller.selectedSort.value = 'discount_desc';
                  controller.fetchStoreProducts();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Produk',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2F2828),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 12, color: Color(0xFF2F2828)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSemuaDiskonBottomSheet(
      BuildContext context, PublicStoreController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.75,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
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
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C4E40)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_offer_rounded,
                          color: Color(0xFF2C4E40),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Semua Promo Diskon Toko',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${controller.diskonList.length} promo diskon aktif dapat digunakan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // List of discounts
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.diskonList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final promo = controller.diskonList[index];
                      final periodeStr = _formatPeriodePromo(
                        promo.tanggalMulai,
                        promo.tanggalSelesai,
                      );
                      final cakupanLabel = promo.isSemuaProduk
                          ? 'Semua Produk Toko'
                          : 'Produk Tertentu';

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                const Color(0xFF2C4E40).withValues(alpha: 0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC107),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    promo.labelDiskon,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2F2828),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C4E40)
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    cakupanLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C4E40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              promo.namaDiskon.isNotEmpty
                                  ? promo.namaDiskon
                                  : 'Promo Diskon ${promo.labelDiskon}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          periodeStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(bottomSheetContext);
                                    controller.isPromoFilterOnly.value = true;
                                    controller.selectedSort.value =
                                        'discount_desc';
                                    controller.fetchStoreProducts();
                                    Get.snackbar(
                                      'Promo Diterapkan',
                                      'Menampilkan produk dengan promo "${promo.namaDiskon.isNotEmpty ? promo.namaDiskon : promo.labelDiskon}"',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor:
                                          const Color(0xFF2C4E40),
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                      margin: const EdgeInsets.all(12),
                                      borderRadius: 8,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF2C4E40),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Lihat Produk'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  // ── Bottom Sheet: Semua Filter (Promo + Sort) ────────────────────────────
  void _showFilterBottomSheet(
      BuildContext context, PublicStoreController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
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
                        const SizedBox(height: 16),

                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.mainColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: AppColors.mainColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Filter & Urutkan",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const Spacer(),
                            // Reset button
                            Obx(() {
                              final hasFilter =
                                  controller.isPromoFilterOnly.value ||
                                      controller.selectedSort.value != 'latest';
                              if (!hasFilter) return const SizedBox.shrink();
                              return TextButton(
                                onPressed: () {
                                  controller.isPromoFilterOnly.value = false;
                                  controller.selectedSort.value = 'latest';
                                  controller.fetchStoreProducts();
                                  setStateModal(() {});
                                },
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  "Reset",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Promo Toggle
                        Obx(() {
                          final isPromo = controller.isPromoFilterOnly.value;
                          return GestureDetector(
                            onTap: () {
                              controller.togglePromoFilter();
                              setStateModal(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isPromo
                                    ? const Color(0xFFE53935)
                                        .withValues(alpha: 0.08)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isPromo
                                      ? const Color(0xFFE53935)
                                      : Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer_rounded,
                                    size: 20,
                                    color: isPromo
                                        ? const Color(0xFFE53935)
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Hanya Produk Promo",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isPromo
                                                ? const Color(0xFFE53935)
                                                : const Color(0xFF1E1E1E),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Tampilkan produk yang sedang diskon",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: isPromo,
                                    activeThumbColor: const Color(0xFFE53935),
                                    onChanged: (_) {
                                      controller.togglePromoFilter();
                                      setStateModal(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // Sort Label
                        const Text(
                          "Urutkan Berdasarkan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Sort Options
                        Obx(() {
                          final currentSort = controller.selectedSort.value;
                          final sortOptions = [
                            {
                              'id': 'latest',
                              'label': 'Terbaru',
                              'subtitle': 'Produk terbaru ditambahkan',
                              'icon': Icons.access_time_rounded
                            },
                            {
                              'id': 'discount_desc',
                              'label': 'Diskon Terbesar',
                              'subtitle': 'Diskon tertinggi lebih dulu',
                              'icon': Icons.trending_down_rounded
                            },
                            {
                              'id': 'discount_asc',
                              'label': 'Diskon Terkecil',
                              'subtitle': 'Diskon terendah lebih dulu',
                              'icon': Icons.trending_up_rounded
                            },
                            {
                              'id': 'price_asc',
                              'label': 'Harga Termurah',
                              'subtitle': 'Harga terendah lebih dulu',
                              'icon': Icons.arrow_downward_rounded
                            },
                            {
                              'id': 'price_desc',
                              'label': 'Harga Tertinggi',
                              'subtitle': 'Harga tertinggi lebih dulu',
                              'icon': Icons.arrow_upward_rounded
                            },
                          ];

                          return Column(
                            children: sortOptions.map((opt) {
                              final isSelected = currentSort == opt['id'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    controller.setSort(opt['id'] as String);
                                    setStateModal(() {});
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.mainColor
                                              .withValues(alpha: 0.08)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.mainColor
                                            : Colors.grey.shade200,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.mainColor
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                          child: Icon(
                                            opt['icon'] as IconData,
                                            size: 15,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                opt['label'] as String,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? AppColors.mainColor
                                                      : const Color(0xFF1E1E1E),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                opt['subtitle'] as String,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 22,
                                            color: AppColors.mainColor,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),

                        const SizedBox(height: 12),

                        // Apply button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Terapkan Filter",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLogoPlaceholder(PublicStoreController controller) {
    final name = controller.storeName.value;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.mainColor.withValues(alpha: 0.1),
      child: Center(
        child: Text(initial,
            style: const TextStyle(
                color: AppColors.mainColor,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  static const double _productGridInfoHeight = 154.0;
  static const double _productGridHorizontalPadding = 16.0;
  static const double _productGridCrossSpacing = 12.0;

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
      mainAxisSpacing: 12,
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
          gridDelegate: _buildProductGridDelegate(context),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              ProdukModel produk = controller.products[index];
              final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
              final isOwner =
                  (currentUserId != null && produk.idUser == currentUserId);
              return ProdukCard(
                isOwner: isOwner,
                badgeLabel: produk.isDiskon && produk.persentaseDiskon > 0
                    ? "Diskon ${produk.persentaseDiskon}%"
                    : (isOwner ? "Milik Anda" : produk.kategori),
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
                isDiskon: produk.isDiskon,
                hargaAsli: produk.hargaAsli,
                persentaseDiskon: produk.persentaseDiskon,
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
                    isScrollControlled: true,
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

/// Mengubah "2026-10-20 03:33:42" menjadi "20 Okt 2026".
/// Mengembalikan teks asli jika gagal di-parse.
String _formatTanggalPromo(String raw) {
  try {
    final dt = DateTime.parse(raw.trim().replaceFirst(' ', 'T'));
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return raw;
  }
}

/// Menghasilkan rentang tanggal diskon yang mudah dibaca pengguna.
/// Contoh: "1 Sep 2026 - 20 Sep 2026" atau "Hingga 20 Sep 2026".
String _formatPeriodePromo(String? mulai, String? selesai) {
  final hasMulai = mulai != null && mulai.trim().isNotEmpty;
  final hasSelesai = selesai != null && selesai.trim().isNotEmpty;

  if (hasMulai && hasSelesai) {
    final strMulai = _formatTanggalPromo(mulai);
    final strSelesai = _formatTanggalPromo(selesai);
    if (strMulai.isNotEmpty && strSelesai.isNotEmpty) {
      return '$strMulai - $strSelesai';
    }
  }
  if (hasSelesai) {
    final strSelesai = _formatTanggalPromo(selesai);
    if (strSelesai.isNotEmpty) return 'Hingga $strSelesai';
  }
  if (hasMulai) {
    final strMulai = _formatTanggalPromo(mulai);
    if (strMulai.isNotEmpty) return 'Mulai $strMulai';
  }
  return 'Periode Terbatas';
}

// ─────────────────────────────────────────────────────────────────────────────
// ── KELAS DELEGATE UNTUK STICKY HEADER (Search + Filter + Kategori) ────────
// ─────────────────────────────────────────────────────────────────────────────
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final PublicStoreController controller;
  final double minExtentHeight;
  final double maxExtentHeight;
  final void Function(BuildContext, PublicStoreController) onOpenFilter;

  _StickyFilterDelegate({
    required this.controller,
    required this.minExtentHeight,
    required this.maxExtentHeight,
    required this.onOpenFilter,
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
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Search Bar + Filter Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  // Search box
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
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
                              hintText:
                                  "Cari di ${controller.storeName.value}...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13.5,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 42, minHeight: 42),
                              suffixIcon:
                                  controller.rawSearchQuery.value.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 17,
                                            color: Colors.grey.shade600,
                                          ),
                                          splashRadius: 18,
                                          onPressed: controller.clearSearch,
                                        )
                                      : null,
                              suffixIconConstraints: const BoxConstraints(
                                  minWidth: 40, minHeight: 40),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ── Filter Button (single button) ──
                  Obx(() {
                    final hasActiveFilter =
                        controller.isPromoFilterOnly.value ||
                            controller.selectedSort.value != 'latest';

                    return GestureDetector(
                      onTap: () => onOpenFilter(context, controller),
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.mainColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            // Dot indikator ada filter aktif
                            if (hasActiveFilter)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC107),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
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
            ),

            // ── Categories / Pills (tanpa tab Semua) ──
            Obx(() {
              if (controller.categories.isEmpty) {
                return const SizedBox(height: 4);
              }
              return SizedBox(
                height: 38,
                child: ListView.builder(
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
                ),
              );
            }),
            const SizedBox(height: 8),
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
