import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/bottomsheet/bottom_sheet_produk.dart';
import 'package:project_camp_sewa/components/card/produk_card.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/layouts/layout_keranjang.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/services/controller_search.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';

class LayoutProduct extends StatefulWidget {
  const LayoutProduct({super.key});

  @override
  State<LayoutProduct> createState() => _LayoutProductState();
}

class _LayoutProductState extends State<LayoutProduct> {
  static const Color _green = Color(0xFF2C4E40);
  static const Color _dark = Color(0xFF2F2828);
  static const Color _grey = Color(0xFF8E8E8E);

  ApiProduk apiProduk = Get.put(ApiProduk());
  TeksSearchController textSearchController = Get.put(TeksSearchController());
  TextEditingController searchController = TextEditingController();

  String filterKategoriLabel = 'Semua';
  String filterKategoriParam = '';
  String sortMode = 'rekomendasi'; // rekomendasi, terbaru, termurah, termahal

  static const Map<String, String> _sortLabels = {
    'rekomendasi': 'Rekomendasi',
    'terbaru': 'Terbaru',
    'termurah': 'Termurah',
    'termahal': 'Termahal',
  };

  static const Map<String, IconData> _sortIcons = {
    'rekomendasi': Icons.auto_awesome_rounded,
    'terbaru': Icons.new_releases_rounded,
    'termurah': Icons.trending_down_rounded,
    'termahal': Icons.trending_up_rounded,
  };

  // Separate loading state for this page's product list
  final RxBool _isLoading = true.obs;

  Timer? _debounce;
  Worker? _searchWorker;

  // ── Data fetching ──────────────────────────────────────────────

  void _fetchData() async {
    _isLoading.value = true;
    await apiProduk.getProduk(
      context,
      textSearchController.searchTeks.value.isEmpty
          ? null
          : textSearchController.searchTeks.value,
      filterKategoriParam.isEmpty ? null : filterKategoriParam,
    );
    _applySorting();
    _isLoading.value = false;
  }

  void _applySorting() {
    final sortedList = apiProduk.listProduk.toList();
    if (sortMode == 'termurah') {
      sortedList.sort((a, b) => a.harga.compareTo(b.harga));
    } else if (sortMode == 'termahal') {
      sortedList.sort((a, b) => b.harga.compareTo(a.harga));
    } else if (sortMode == 'terbaru') {
      sortedList.sort((a, b) => b.idProduk.compareTo(a.idProduk));
    }
    apiProduk.listProduk.assignAll(sortedList);
  }

  void _filterProduk(String label, String param) {
    setState(() {
      filterKategoriLabel = label;
      filterKategoriParam = param;
    });
    _fetchData();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      textSearchController.searchTeks.value = query;
      _fetchData();
    });
  }

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    searchController.text = textSearchController.searchTeks.value;

    _searchWorker = ever(textSearchController.searchTeks, (value) {
      if (searchController.text != value) searchController.text = value;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiProduk.getListKategori();
    });
    _fetchData();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchWorker?.dispose();
    searchController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // ── 1+2. HEADER + SEARCH BAR (satu panel hijau, sudut bawah rounded) ──
            _buildTopPanel(),

            // ── 3. CATEGORY CHIPS ──
            _buildCategoryChips(),

            // ── 4. RESULTS HEADER + 5. PRODUCT GRID (scrollable) ──
            Expanded(
              child: RefreshIndicator(
                color: _green,
                backgroundColor: Colors.white,
                displacement: 30,
                strokeWidth: 3,
                onRefresh: () async {
                  _fetchData();
                  try {
                    final apiDataUser = Get.put(ApiDataUser());
                    await apiDataUser.getDataUser(context);
                  } catch (_) {}
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  slivers: [
                    SliverToBoxAdapter(child: _buildResultsHeader()),
                    _buildProductGrid(),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1+2. TOP PANEL (header + search, satu kesatuan) ─────────────

  Widget _buildTopPanel() {
    return Container(
      decoration: BoxDecoration(
        color: _green,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Produk",
                  style: AppColors.fontStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  "Peralatan Camping Terlengkap",
                  style: AppColors.fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Get.to(const LayoutKeranjang()),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.shopping_cart_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR (below header, above chips) ───────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _dark,
                ),
                decoration: InputDecoration(
                  hintText: "Cari peralatan camping...",
                  hintStyle: AppColors.fontStyle(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: searchController,
              builder: (context, child) {
                return searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 20, color: Color(0xFFBDBDBD)),
                        onPressed: () {
                          searchController.clear();
                          textSearchController.searchTeks.value = '';
                          _fetchData();
                        },
                      )
                    : const SizedBox(width: 16);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. CATEGORY CHIPS (below search bar, above grid) ──────────────

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

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 56,
        child: Obx(() {
          final List<String> categories = ['Semua', ...apiProduk.listKategori];
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = filterKategoriLabel == cat;
              return GestureDetector(
                onTap: () => _filterProduk(cat, cat == 'Semua' ? '' : cat),
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
                        size: 15,
                        color:
                            isSelected ? Colors.white : const Color(0xFF8E8E8E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : _dark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // ── 4. RESULTS HEADER (count + tombol Urutkan yang jelas terlihat) ──

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filterKategoriLabel == 'Semua'
                      ? 'Semua Produk'
                      : filterKategoriLabel,
                  style: AppColors.fontStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                Obx(() {
                  final count = apiProduk.listProduk.length;
                  return Text(
                    "$count produk tersedia",
                    style: AppColors.fontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBDBDBD),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildSortChip(),
        ],
      ),
    );
  }

  /// Chip "Urutkan" — dibuat kontras (tint hijau + border) supaya
  /// tidak tenggelam di atas background halaman yang terang, dan
  /// menampilkan mode sort yang sedang aktif.
  Widget _buildSortChip() {
    return GestureDetector(
      onTap: _showSortBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _green.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert_rounded, size: 16, color: _green),
            const SizedBox(width: 6),
            Text(
              _sortLabels[sortMode] ?? 'Urutkan',
              style: AppColors.fontStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _green,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: _green),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Urutkan Berdasarkan",
                      style: AppColors.fontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Color(0xFF8E8E8E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ..._sortLabels.entries
                  .map((e) => _buildSortOption(e.value, e.key)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = sortMode == value;
    return InkWell(
      onTap: () {
        setState(() {
          sortMode = value;
        });
        _applySorting();
        Get.back();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _green.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? _green : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _sortIcons[value] ?? Icons.sort_rounded,
                size: 17,
                color: isSelected ? Colors.white : const Color(0xFF8E8E8E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? _green : _dark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: _green, size: 20),
          ],
        ),
      ),
    );
  }

  // ── 5. PRODUCT GRID ───────────────────────────────────────────────

  Widget _buildProductGrid() {
    return Obx(() {
      // Show shimmer while loading
      if (_isLoading.value) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 340,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, __) => _ShimmerCard(),
              childCount: 6,
            ),
          ),
        );
      }

      final List<ProdukModel> filteredList = filterKategoriParam.isEmpty
          ? apiProduk.listProduk
          : apiProduk.listProduk.where((p) => p.kategori == filterKategoriParam).toList();
      final listProduk = filteredList;

      // Empty state — only shown after loading completes
      if (listProduk.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 44,
                      color: _green.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Produk tidak ditemukan",
                    style: AppColors.fontStyle(
                      color: _dark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Coba kata kunci atau kategori lain",
                    style: AppColors.fontStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      textSearchController.searchTeks.value = '';
                      _filterProduk('Semua', '');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _green.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Reset Filter",
                        style: AppColors.fontStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Product grid
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 340,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final ProdukModel p = listProduk[index];
              final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
              final isOwner =
                  (currentUserId != null && p.idUser == currentUserId);
              return ProdukCard(
                badgeLabel: isOwner ? "Milik Anda" : p.kategori,
                images: p.images,
                namaProduk: p.namaProduk,
                namaToko: p.namaToko,
                fotoToko: p.fotoToko,
                ratingToko: p.ratingToko,
                harga: p.harga.toString(),
                rating: p.rating.toString(),
                stok: p.stok,
                jumlahReview: p.jumlahReview,
                isFavorite: p.isFavorite,
                aksi: () {
                  Get.to(const LayoutDetailProduct(), arguments: {
                    'idToko': p.idUser,
                    'idProduk': p.idProduk,
                    'namaProduk': p.namaProduk,
                    'fotoProduk': p.image,
                    'namaToko': p.namaToko,
                  });
                },
                aksiKeranjang: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
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
            childCount: listProduk.length,
          ),
        ),
      );
    });
  }
}

// ── Shimmer card placeholder ────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.9).animate(
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
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
