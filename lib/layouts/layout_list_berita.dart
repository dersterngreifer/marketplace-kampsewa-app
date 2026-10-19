import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/layouts/layout_detail_berita.dart';
import 'package:project_camp_sewa/models/article_model.dart';
import 'package:project_camp_sewa/services/api_article.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:shimmer/shimmer.dart';

class LayoutListBerita extends StatefulWidget {
  const LayoutListBerita({super.key});

  @override
  State<LayoutListBerita> createState() => _LayoutListBeritaState();
}

class _LayoutListBeritaState extends State<LayoutListBerita> {
  static const Color _green = Color(0xFF2C4E40);
  static const Color _dark = Color(0xFF2F2828);

  final ApiArticle _apiArticle = Get.isRegistered<ApiArticle>()
      ? Get.find<ApiArticle>()
      : Get.put(ApiArticle());

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // State data & filter
  final List<ArticleModel> _listBerita = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  String _selectedSort = 'terbaru';
  String _selectedFilterWaktu = 'semua';

  final List<Map<String, String>> _sortOptions = [
    {'value': 'terbaru', 'label': 'Terbaru'},
    {'value': 'terpopuler', 'label': 'Terpopuler'},
    {'value': 'terlama', 'label': 'Terlama'},
    {'value': 'a_z', 'label': 'A - Z'},
    {'value': 'z_a', 'label': 'Z - A'},
  ];

  final List<Map<String, String>> _waktuOptions = [
    {'value': 'semua', 'label': 'Semua'},
    {'value': 'hari_ini', 'label': 'Hari Ini'},
    {'value': 'minggu_ini', 'label': 'Minggu Ini'},
    {'value': 'bulan_ini', 'label': 'Bulan Ini'},
    {'value': 'tahun_ini', 'label': 'Tahun Ini'},
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

    final result = await _apiArticle.fetchBeritaList(
      page: _currentPage,
      perPage: 10,
      sortBy: _selectedSort,
      filterWaktu: _selectedFilterWaktu,
      search: _searchController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final List<ArticleModel> items = result['data'] ?? [];
      final pagination = result['pagination'] ?? {};

      setState(() {
        if (reset) {
          _listBerita.clear();
        }
        _listBerita.addAll(items);
        _currentPage = pagination['current_page'] ?? _currentPage;
        _lastPage = pagination['last_page'] ?? 1;
        _totalItems = pagination['total'] ?? _listBerita.length;
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
              "Berita Terkini",
              style: AppColors.fontStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
            if (!_isLoading && _totalItems > 0)
              Text(
                "$_totalItems artikel berita & tips outdoor",
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
                hintText: "Cari judul berita atau topik informasi...",
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

          // Horizontal Filter Chips (Urutan & Waktu)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Tombol Dialog Urutan
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

                // Quick Chips Filter Waktu
                ..._waktuOptions.map((opt) {
                  final isSelected = _selectedFilterWaktu == opt['value'];
                  return _buildFilterChipItem(
                    label: opt['label']!,
                    icon: _getWaktuIcon(opt['value']!),
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedFilterWaktu = opt['value']!);
                      _fetchData(reset: true);
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWaktuIcon(String value) {
    switch (value.toLowerCase()) {
      case 'semua':
        return Icons.newspaper_rounded;
      case 'hari_ini':
        return Icons.today_rounded;
      case 'minggu_ini':
        return Icons.date_range_rounded;
      case 'bulan_ini':
        return Icons.calendar_month_rounded;
      case 'tahun_ini':
        return Icons.calendar_today_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  IconData _getSortIcon(String sort) {
    switch (sort.toLowerCase()) {
      case 'terbaru':
        return Icons.auto_awesome_rounded;
      case 'terpopuler':
        return Icons.trending_up_rounded;
      case 'terlama':
        return Icons.history_rounded;
      case 'a_z':
      case 'z_a':
        return Icons.sort_by_alpha_rounded;
      default:
        return Icons.sort_rounded;
    }
  }

  Widget _buildFilterChipItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? _green : const Color(0xFFF2F4F3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _green : Colors.grey.shade300,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF555555),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppColors.fontStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : _dark,
                ),
              ),
            ],
          ),
        ),
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
                    "Urutkan Berita Terkini",
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
                    leading: Icon(
                      _getSortIcon(opt['value']!),
                      color: isSelected ? _green : Colors.grey.shade600,
                      size: 20,
                    ),
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

  Widget _buildListContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_listBerita.isEmpty) {
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
                child: const Icon(Icons.feed_rounded,
                    size: 38, color: _green),
              ),
              const SizedBox(height: 16),
              Text(
                "Tidak ada berita ditemukan",
                style: AppColors.fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Coba gunakan kata kunci lain atau sesuaikan filter urutan dan waktu.",
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
      itemCount: _listBerita.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= _listBerita.length) {
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

        final item = _listBerita[index];
        return _buildBeritaCardItem(item);
      },
    );
  }

  Widget _buildBeritaCardItem(ArticleModel item) {
    final sourceName = (item.sumberNama != null &&
            item.sumberNama!.trim().isNotEmpty)
        ? item.sumberNama!.trim()
        : "Berita";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Get.to(() => LayoutDetailBerita(initialArticle: item));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: _buildImage(item.gambar),
                  ),
                ),
                const SizedBox(width: 14),

                // Konten Ringkas Berita
                Expanded(
                  child: SizedBox(
                    height: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                            height: 1.3,
                          ),
                        ),
                        // Badge Sumber & Tanggal & Views
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.newspaper_rounded,
                                      size: 11, color: _green),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 80),
                                    child: Text(
                                      sourceName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppColors.fontStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.waktuLalu.isNotEmpty
                                    ? item.waktuLalu
                                    : item.tanggalUpload,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppColors.fontStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF8E8E8E),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.visibility_outlined,
                                    size: 11, color: Color(0xFF8E8E8E)),
                                const SizedBox(width: 3),
                                Text(
                                  "${item.viewsCount}",
                                  style: AppColors.fontStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8E8E8E),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildImage(String image) {
    final resolved = getFotoBeritaUrl(image);

    Widget fallback() => Container(
          color: const Color(0xFFF0F2F1),
          child: const Center(
            child: Icon(Icons.newspaper_rounded,
                color: Color(0xFFBDBDBD), size: 28),
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
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) {
          return Container(
            height: 110,
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
