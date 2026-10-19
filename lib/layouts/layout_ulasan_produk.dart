import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/layouts/layout_public_store_profile.dart';
import 'package:project_camp_sewa/components/card/review_photos_carousel.dart';
import 'package:shimmer/shimmer.dart';

class LayoutUlasanProduk extends StatefulWidget {
  final String namaProduk;
  final String idProduk;

  const LayoutUlasanProduk({super.key, required this.namaProduk, required this.idProduk});

  @override
  State<LayoutUlasanProduk> createState() => _LayoutUlasanProdukState();
}

class _LayoutUlasanProdukState extends State<LayoutUlasanProduk> {
  String selectedFilter = 'Terbaru';
  final List<String> filterOptions = [
    'Terbaru',
    'Terlama',
    'Tertinggi',
    'Terendah'
  ];

  final ApiProduk apiProduk = Get.put(ApiProduk());
  List<dynamic> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final fetchedReviews = await apiProduk.getProductReviews(widget.idProduk);
    if (mounted) {
      setState(() {
        reviews = fetchedReviews;
        isLoading = false;
        applyFilter();
      });
    }
  }

  double _getRating(dynamic r) {
    if (r == null) return 0.0;
    if (r is num) return r.toDouble();
    return double.tryParse(r.toString()) ?? 0.0;
  }

  String _getDate(dynamic d) {
    return d?.toString() ?? '';
  }

  void applyFilter() {
    try {
      if (selectedFilter == 'Terbaru') {
        reviews.sort((a, b) => _getDate(b['tanggal_ulasan']).compareTo(_getDate(a['tanggal_ulasan'])));
      } else if (selectedFilter == 'Terlama') {
        reviews.sort((a, b) => _getDate(a['tanggal_ulasan']).compareTo(_getDate(b['tanggal_ulasan'])));
      } else if (selectedFilter == 'Tertinggi') {
        reviews.sort((a, b) => _getRating(b['rating']).compareTo(_getRating(a['rating'])));
      } else if (selectedFilter == 'Terendah') {
        reviews.sort((a, b) => _getRating(a['rating']).compareTo(_getRating(b['rating'])));
      }
    } catch (e) {
      debugPrint('Error applying filter: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2F2828), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Ulasan Pembeli",
          style: AppColors.fontStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F2828),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filterOptions[index];
                final isSelected = selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                      applyFilter();
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2C4E40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2C4E40)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF8E8E8E),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    separatorBuilder: (_, __) => const Divider(height: 32, thickness: 1),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 80,
                                        height: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 250,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : reviews.isEmpty
                    ? Center(
                        child: Text(
                          "Belum ada ulasan.",
                          style: AppColors.fontStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 32, thickness: 1),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          final idUser = review['id_user']?.toString();
                          final fotoUserRaw = review['foto_user']?.toString() ?? '';
                          final fotoUser = fotoUserRaw.isNotEmpty ? resolveFullUrl(fotoUserRaw, ApiEndpoints.authendpoints.getFotoProfile) : '';
                          final namaUser = review['nama_user']?.toString() ?? 'Pengguna';
                          final ulasanText = review['ulasan']?.toString() ?? '';
                          final ratingVal = review['rating'] != null ? double.tryParse(review['rating'].toString())?.toInt() ?? 0 : 0;
                          final dateVal = review['tanggal_ulasan']?.toString() ?? '';

                          final List<String> reviewPhotos = [];
                          if (review['fotos_ulasan'] != null && review['fotos_ulasan'] is List) {
                            for (var item in review['fotos_ulasan']) {
                              final str = item?.toString() ?? '';
                              if (str.isNotEmpty) {
                                reviewPhotos.add(resolveFullUrl(str, ApiEndpoints.baseUrl));
                              }
                            }
                          }
                          if (reviewPhotos.isEmpty && review['foto_ulasan'] != null) {
                            final str = review['foto_ulasan']?.toString() ?? '';
                            if (str.isNotEmpty) {
                              reviewPhotos.add(resolveFullUrl(str, ApiEndpoints.baseUrl));
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (idUser != null) {
                                        Get.to(() => LayoutPublicStoreProfile(idUser: int.parse(idUser)));
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.grey.shade300,
                                          backgroundImage: fotoUser.isNotEmpty ? NetworkImage(fotoUser) : null,
                                          child: fotoUser.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.white) : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              namaUser,
                                              style: AppColors.fontStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF2F2828),
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (starIndex) => Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: starIndex < ratingVal
                                                      ? const Color(0xFFFFC107)
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    dateVal,
                                    style: AppColors.fontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF8E8E8E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ulasanText,
                                style: AppColors.fontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF2F2828),
                                  height: 1.5,
                                ),
                              ),
                              if (reviewPhotos.isNotEmpty)
                                ReviewPhotosCarousel(
                                  photos: reviewPhotos,
                                  reviewerName: namaUser,
                                ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
