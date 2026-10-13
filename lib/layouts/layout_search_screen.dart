import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog2.dart';
import 'package:project_camp_sewa/components/card/rekomendasi_cari_card.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/services/api_riwayat_cari.dart';
import 'package:project_camp_sewa/services/controller_dashboard.dart';
import 'package:project_camp_sewa/services/controller_search.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class LayoutSearchScreen extends StatefulWidget {
  const LayoutSearchScreen({super.key});

  @override
  State<LayoutSearchScreen> createState() => _LayoutSearchScreenState();
}

class _LayoutSearchScreenState extends State<LayoutSearchScreen> {
  DashboardController pageController = Get.put(DashboardController());
  TextEditingController searchController = TextEditingController();
  TeksSearchController textSearchController = Get.put(TeksSearchController());
  ApiRiwayatCari apiRiwayatCari = Get.put(ApiRiwayatCari());
  ApiProduk apiProduk = Get.put(ApiProduk());

  bool showAllSearchHistory = false;
  final FocusNode searchFocusNode = FocusNode();

  Timer? _debounce;
  final RxString _searchQuery = "".obs;

  // ── Konstanta layout grid produk ──
  // Dipakai untuk menghitung tinggi kartu secara dinamis agar tidak overflow.
  static const double _gridHorizontalPadding = 20.0;
  static const double _gridCrossSpacing = 14.0;
  static const double _gridMainSpacing = 14.0;
  // Tinggi area informasi di bawah foto (nama 2 baris + toko + rating + harga + padding)
  static const double _infoSectionHeight = 150.0;

  @override
  void initState() {
    super.initState();
    // Panggil API untuk riwayat pencarian & rekomendasi
    apiRiwayatCari.showRiwayatCari(context);
    apiProduk.getProdukRekomendasiPencarian(context);

    // Listener untuk pencarian realtime
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        // Panggil API pencarian produk secara realtime
        apiProduk.getProduk(context, query, null);
      }
    });
  }

  void _performSearch(String value) {
    if (value.isNotEmpty) {
      textSearchController.searchTeks.value = value;
      apiProduk.getProduk(context, value, null);
      apiRiwayatCari.insertRiwayatCari(context, value);

      // Jika disubmit, pindah ke halaman Produk (index 1) untuk lihat hasil lengkap
      pageController.setPageIndex(1);
      Get.back();
    }
  }

  void _goToDetail(ProdukModel produk) {
    // Arahkan ke detail produk
    Get.to(() => const LayoutDetailProduct(), arguments: {
      'idToko': produk.idUser,
      'idProduk': produk.idProduk,
      'namaProduk': produk.namaProduk,
      'fotoProduk': produk.image,
      'namaToko': produk.namaToko,
      'fotoToko': produk.fotoToko,
      'ratingToko': produk.ratingToko,
    });
  }

  void _showDialogHapusSemua() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          contentPadding: EdgeInsets.zero,
          content: CustomAlertDialog2(
            title: "Hapus Semua Riwayat?",
            teks:
                "Apakah Anda yakin ingin menghapus seluruh riwayat pencarian? Tindakan ini tidak dapat dibatalkan.",
            confirmLabel: "Hapus Semua",
            cancelLabel: "Batal",
            hapus: () async {
              await apiRiwayatCari.deleteRiwayatCari(context, null);
              setState(() {
                showAllSearchHistory = false;
              });
            },
          ),
        );
      },
    );
  }

  void _showDialogHapusSingle(String text) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          contentPadding: EdgeInsets.zero,
          content: CustomAlertDialog2(
            title: "Hapus Riwayat?",
            teks: 'Hapus "$text" dari riwayat pencarian Anda?',
            confirmLabel: "Hapus",
            cancelLabel: "Batal",
            hapus: () async {
              await apiRiwayatCari.deleteRiwayatCari(context, text);
            },
          ),
        );
      },
    );
  }

  /// Grid delegate dinamis: tinggi kartu = lebar kartu (foto 1:1) + tinggi info.
  /// Dengan cara ini tidak akan overflow baik di layar kecil maupun besar.
  SliverGridDelegate _buildProductGridDelegate(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const columns = 2;
    final cardWidth = (screenWidth -
            (_gridHorizontalPadding * 2) -
            (_gridCrossSpacing * (columns - 1))) /
        columns;
    final cardHeight = cardWidth + _infoSectionHeight;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisExtent: cardHeight,
      crossAxisSpacing: _gridCrossSpacing,
      mainAxisSpacing: _gridMainSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft light background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildHeaderTexts(),
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                // Jika sedang mencari (realtime), tampilkan list hasil pencarian
                if (_searchQuery.value.isNotEmpty) {
                  return _buildRealtimeResults();
                }

                // Jika kosong, tampilkan riwayat & rekomendasi
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchHistory(),
                      _buildRecommendations(),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Text(
            "Pencarian",
            style: AppColors.fontStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2F2828),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 42), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHeaderTexts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Temukan Peralatan",
            style: AppColors.fontStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2F2828),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Cari peralatan bertualang yang Anda butuhkan.",
            style: AppColors.fontStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF646363),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.mainColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                MdiIcons.magnify,
                size: 26,
                color: AppColors.mainColor,
              ),
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: _performSearch,
                style: AppColors.fontStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F2828),
                ),
                decoration: InputDecoration(
                  hintText: "Ketik nama perlengkapan...",
                  hintStyle: AppColors.fontStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBDBDBD),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: searchController,
              builder: (context, child) {
                return searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF646363),
                          ),
                        ),
                        onPressed: () {
                          searchController.clear();
                          apiProduk.listProduk.clear();
                        },
                      )
                    : const SizedBox();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeResults() {
    return Obx(() {
      final results = apiProduk.listProduk;

      if (results.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "Sedang mencari atau tidak ditemukan",
                  style: AppColors.fontStyle(
                      color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          _gridHorizontalPadding,
          8,
          _gridHorizontalPadding,
          24,
        ),
        physics: const BouncingScrollPhysics(),
        gridDelegate: _buildProductGridDelegate(context),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final p = results[index];
          return RekomendasiCariCard(
            images: p.images.isNotEmpty
                ? p.images
                : (p.image.isNotEmpty ? [p.image] : const []),
            namaProduk: p.namaProduk,
            namaToko: p.namaToko,
            fotoToko: p.fotoToko,
            ratingToko: p.ratingToko,
            rating: p.rating,
            harga: p.harga.toString(),
            stok: p.stok,
            jumlahReview: p.jumlahReview,
            aksi: () => _goToDetail(p),
          );
        },
      );
    });
  }

  Widget _buildSearchHistory() {
    return Obx(() {
      final history = apiRiwayatCari.riwayatCari;
      if (history.isEmpty) return const SizedBox.shrink();

      final displayCount = showAllSearchHistory
          ? history.length
          : (history.length > 4 ? 4 : history.length);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pencarian Terakhir",
                  style: AppColors.fontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F2828),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (history.length > 4) ...[
                      InkWell(
                        onTap: () {
                          setState(() {
                            showAllSearchHistory = !showAllSearchHistory;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Text(
                            showAllSearchHistory ? "Tutup" : "Lihat Semua",
                            style: AppColors.fontStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mainColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    InkWell(
                      onTap: _showDialogHapusSemua,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Color(0xFFEE2737),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Hapus Semua",
                              style: AppColors.fontStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFEE2737),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(displayCount, (index) {
                final text = history[index];
                return InkWell(
                  onTap: () {
                    searchController.text = text;
                    _performSearch(text);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 40,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: AppColors.mainColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppColors.fontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2F2828),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => _showDialogHapusSingle(text),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (showAllSearchHistory)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _showDialogHapusSemua,
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: Color(0xFFEE2737)),
                    label: Text(
                      "Hapus Semua Riwayat",
                      style: AppColors.fontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEE2737),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFEE2737).withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 22,
                color: AppColors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                "Mungkin Anda Suka",
                style: AppColors.fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2F2828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            List<ProdukModel> listProduk = apiProduk.listProdukRekomendasi;
            if (listProduk.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada rekomendasi",
                        style: AppColors.fontStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            }
            return GridView.builder(
              gridDelegate: _buildProductGridDelegate(context),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: listProduk.length,
              itemBuilder: (context, index) {
                ProdukModel list = listProduk[index];
                return RekomendasiCariCard(
                  images: list.images.isNotEmpty
                      ? list.images
                      : (list.image.isNotEmpty ? [list.image] : const []),
                  namaProduk: list.namaProduk,
                  namaToko: list.namaToko,
                  fotoToko: list.fotoToko,
                  ratingToko: list.ratingToko,
                  rating: list.rating,
                  harga: list.harga.toString(),
                  stok: list.stok,
                  jumlahReview: list.jumlahReview,
                  aksi: () => _goToDetail(list),
                );
              },
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
