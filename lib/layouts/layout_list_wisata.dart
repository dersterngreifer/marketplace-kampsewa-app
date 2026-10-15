import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/layouts/layout_detail_wisata.dart';
import 'package:project_camp_sewa/models/article_model.dart';
import 'package:project_camp_sewa/services/api_article.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:shimmer/shimmer.dart';

class LayoutListWisata extends StatefulWidget {
  const LayoutListWisata({super.key});

  @override
  State<LayoutListWisata> createState() => _LayoutListWisataState();
}

class _LayoutListWisataState extends State<LayoutListWisata> {
  static const Color _green = Color(0xFF2C4E40);
  static const Color _dark = Color(0xFF2F2828);

  final ApiArticle _apiArticle = Get.isRegistered<ApiArticle>()
      ? Get.find<ApiArticle>()
      : Get.put(ApiArticle());

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // State data & filter
  final List<ArticleModel> _listWisata = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  String _selectedSort = 'terbaru';
  String _selectedFilterWaktu = 'semua';
  String? _selectedLokasi;

  final List<Map<String, String>> _sortOptions = [
    {'value': 'terbaru', 'label': 'Terbaru'},
    {'value': 'terpopuler', 'label': 'Terpopuler'},
    {'value': 'terlama', 'label': 'Terlama'},
    {'value': 'a_z', 'label': 'A - Z'},
    {'value': 'z_a', 'label': 'Z - A'},
  ];

  final List<Map<String, String>> _waktuOptions = [
    {'value': 'semua', 'label': 'Semua Waktu'},
    {'value': 'hari_ini', 'label': 'Hari Ini'},
    {'value': 'minggu_ini', 'label': 'Minggu Ini'},
    {'value': 'bulan_ini', 'label': 'Bulan Ini'},
    {'value': 'tahun_ini', 'label': 'Tahun Ini'},
  ];

  final List<String> _popularLokasi = [
    'Semua',
    'Bromo',
    'Malang',
    'Batu',
    'Semeru',
    'Yogyakarta',
    'Bali',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          !_isLoadingMore &&
          _currentPage < _lastPage) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchData(reset: true);
    });
  }

  Future<void> _fetchData({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    final result = await _apiArticle.fetchWisataList(
      page: _currentPage,
      perPage: 10,
      sortBy: _selectedSort,
      filterWaktu: _selectedFilterWaktu,
      lokasi: (_selectedLokasi != null && _selectedLokasi != 'Semua')
          ? _selectedLokasi
          : null,
      search: _searchController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final List<ArticleModel> items = result['data'] ?? [];
      final pagination = result['pagination'] ?? {};

      setState(() {
        if (reset) {
          _listWisata.clear();
        }
        _listWisata.addAll(items);
        _currentPage = pagination['current_page'] ?? _currentPage;
        _lastPage = pagination['last_page'] ?? 1;
        _totalItems = pagination['total'] ?? _listWisata.length;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_currentPage >= _lastPage || _isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    await _fetchData(reset: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _dark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rekomendasi Wisata",
              style: AppColors.fontStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
            if (!_isLoading && _totalItems > 0)
              Text(
                "$_totalItems destinasi wisata alam & camping",
                style: AppColors.fontStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: RefreshIndicator(
              color: _green,
              onRefresh: () => _fetchData(reset: true),
              child: _buildListContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _fetchData(reset: true),
              style: AppColors.fontStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
              decoration: InputDecoration(
                hintText: "Cari destinasi wisata atau lokasi...",
                hintStyle: AppColors.fontStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF8E8E8E), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel_rounded,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _fetchData(reset: true);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Filter Chips (Urutan & Waktu & Lokasi)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Tombol Dialog Filter Urutan
                _buildFilterButton(
                  label: _sortOptions.firstWhere(
                    (s) => s['value'] == _selectedSort,
                    orElse: () => {'label': 'Urutkan'},
                  )['label']!,
                  icon: Icons.sort_rounded,
                  isActive: _selectedSort != 'terbaru',
                  onTap: _showSortBottomSheet,
                ),
                const SizedBox(width: 8),

                // Tombol Dialog Filter Waktu
                _buildFilterButton(
                  label: _waktuOptions.firstWhere(
                    (w) => w['value'] == _selectedFilterWaktu,
                    orElse: () => {'label': 'Waktu'},
                  )['label']!,
                  icon: Icons.date_range_rounded,
                  isActive: _selectedFilterWaktu != 'semua',
                  onTap: _showFilterWaktuBottomSheet,
                ),
                const SizedBox(width: 8),

                // Lokasi Chips Cepat
                ..._popularLokasi.map((lokasi) {
                  final isSelected = (_selectedLokasi == lokasi) ||
                      (_selectedLokasi == null && lokasi == 'Semua');
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(lokasi),
                      selected: isSelected,
                      selectedColor: _green,
                      backgroundColor: const Color(0xFFF2F4F3),
                      labelStyle: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : _dark,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? _green
                              : Colors.transparent,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedLokasi =
                              (lokasi == 'Semua') ? null : lokasi;
                        });
                        _fetchData(reset: true);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? _green.withValues(alpha: 0.1) : const Color(0xFFF2F4F3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? _green : Colors.grey.shade300,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? _green : _dark),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppColors.fontStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? _green : _dark,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: isActive ? _green : Colors.grey),
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
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Urutkan Rekomendasi Wisata",
                    style: AppColors.fontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._sortOptions.map((opt) {
                  final isSelected = _selectedSort == opt['value'];
                  return ListTile(
                    title: Text(
                      opt['label']!,
                      style: AppColors.fontStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? _green : _dark,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: _green)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _selectedSort = opt['value']!);
                      _fetchData(reset: true);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterWaktuBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Filter Rentang Waktu Rilis",
                    style: AppColors.fontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._waktuOptions.map((opt) {
                  final isSelected = _selectedFilterWaktu == opt['value'];
                  return ListTile(
                    title: Text(
                      opt['label']!,
                      style: AppColors.fontStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? _green : _dark,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: _green)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _selectedFilterWaktu = opt['value']!);
                      _fetchData(reset: true);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_listWisata.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.travel_explore_rounded,
                    size: 38, color: _green),
              ),
              const SizedBox(height: 16),
              Text(
                "Tidak ada wisata ditemukan",
                style: AppColors.fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Coba ubah kata kunci pencarian atau sesuaikan pilihan filter waktu dan lokasi Anda.",
                textAlign: TextAlign.center,
                style: AppColors.fontStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedSort = 'terbaru';
                    _selectedFilterWaktu = 'semua';
                    _selectedLokasi = null;
                  });
                  _fetchData(reset: true);
                },
                icon: const Icon(Icons.refresh_rounded, color: _green),
                label: Text(
                  "Reset Filter",
                  style: AppColors.fontStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      itemCount: _listWisata.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index >= _listWisata.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_green),
                ),
              ),
            ),
          );
        }

        final item = _listWisata[index];
        return _buildWisataCardItem(item);
      },
    );
  }

  Widget _buildWisataCardItem(ArticleModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Get.to(() => LayoutDetailWisata(initialArticle: item));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Cover Besar
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImage(item.gambar),
                      // Gradient overlay bawah
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Lokasi Chip di kiri atas
                      if (item.lokasi != null && item.lokasi!.trim().isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 12, color: Color(0xFFEE2737)),
                                const SizedBox(width: 3),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                                  ),
                                  child: Text(
                                    item.lokasi!.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppColors.fontStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _dark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Views count di kanan bawah
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility_outlined,
                                  size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                "${item.viewsCount}",
                                style: AppColors.fontStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
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
              ),

              // Detail Teks
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppColors.fontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.deskripsiSingkat,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF666666),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: _green.withValues(alpha: 0.15),
                          backgroundImage: (item.author?.foto != null &&
                                  item.author!.foto.isNotEmpty)
                              ? NetworkImage(getImageUrl(item.author!.foto))
                              : null,
                          child: (item.author?.foto == null ||
                                  item.author!.foto.isEmpty)
                              ? const Icon(Icons.person,
                                  size: 12, color: _green)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.author?.name ?? "Admin KampSewa",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppColors.fontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        ),
                        Text(
                          item.waktuLalu.isNotEmpty
                              ? item.waktuLalu
                              : item.tanggalUpload,
                          style: AppColors.fontStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8E8E8E),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: Color(0xFFBDBDBD)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String image) {
    final resolved = getFotoWisataUrl(image);

    Widget fallback() => Container(
          color: const Color(0xFF1E352B),
          child: const Center(
            child: Icon(Icons.landscape_rounded,
                color: Colors.white24, size: 40),
          ),
        );

    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return fallback();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) {
          return Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          );
        },
      ),
    );
  }
}
