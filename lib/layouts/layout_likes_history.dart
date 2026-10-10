import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/services/api_likes_history.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class LayoutLikesHistory extends StatefulWidget {
  const LayoutLikesHistory({Key? key}) : super(key: key);

  @override
  State<LayoutLikesHistory> createState() => _LayoutLikesHistoryState();
}

class _LayoutLikesHistoryState extends State<LayoutLikesHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiLikesHistory apiController = Get.put(ApiLikesHistory());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Aktivitas Saya",
          style: AppColors.fontStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2C4E40), // Active green
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2C4E40),
          labelStyle: AppColors.fontStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: AppColors.fontStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: "Disukai"),
            Tab(text: "Riwayat Ulasan"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLikesTab(),
          _buildFeedbacksTab(),
        ],
      ),
    );
  }

  Widget _buildLikesTab() {
    return Obx(() {
      if (apiController.isLoadingLikes.value) {
        return _buildLikesShimmer();
      }
      if (apiController.likesList.isEmpty) {
        return _buildPlaceholder(
          icon: Icons.favorite_border,
          title: "Belum Ada Data",
          message: "Produk yang Anda sukai akan muncul di sini.",
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await apiController.fetchLikes(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: apiController.likesList.length,
          itemBuilder: (context, index) {
            final item = apiController.likesList[index];
            return _buildProductCard(
              title: item['nama_product'] ?? item['nama_produk'] ?? '-',
              imageUrl: item['gambar_product'] ?? item['gambar_produk'] ?? item['foto_depan'] ?? item['foto_produk'],
              price: item['harga']?.toString() ?? item['harga_sewa']?.toString() ?? '0',
              rating: item['rating_rata_rata']?.toString() ?? item['rating']?.toString() ?? '0',
              onTap: () {
                Get.to(() => const LayoutDetailProduct(), arguments: {
                  'idToko': 0,
                  'idProduk': item['id_product'] ?? item['id_produk'] ?? item['id'],
                });
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildFeedbacksTab() {
    return Obx(() {
      if (apiController.isLoadingFeedbacks.value) {
        return _buildFeedbackShimmer();
      }
      if (apiController.feedbackList.isEmpty) {
        return _buildPlaceholder(
          icon: Icons.comment_outlined,
          title: "Belum Ada Ulasan",
          message: "Riwayat komentar dan rating Anda akan muncul di sini.",
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await apiController.fetchFeedbacks(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: apiController.feedbackList.length,
          itemBuilder: (context, index) {
            final item = apiController.feedbackList[index];
            return _buildFeedbackCard(
              productName: item['nama_product'] ?? item['nama_produk'] ?? '-',
              imageUrl: item['gambar_product'] ?? item['gambar_produk'] ?? item['foto_depan'] ?? item['foto_produk'],
              comment: item['komentar'] ?? item['ulasan'] ?? '',
              rating: int.tryParse(item['rating_diberikan']?.toString() ?? item['rating']?.toString() ?? '0') ?? 0,
              date: item['tanggal_ulasan'] ?? item['created_at'] ?? '',
              onTap: () {
                Get.to(() => const LayoutDetailProduct(), arguments: {
                  'idToko': 0,
                  'idProduk': item['id_product'] ?? item['id_produk'] ?? item['id'],
                });
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildProductCard({
    required String title,
    String? imageUrl,
    required String price,
    required String rating,
    required VoidCallback onTap,
  }) {
    String finalUrl = imageUrl != null && imageUrl.isNotEmpty ? resolveFullUrl(imageUrl, ApiEndpoints.authendpoints.getImageProduk) : 'https://via.placeholder.com/150';
    
    String displayPrice = price;
    try {
      String cleanPrice = price;
      if (cleanPrice.contains('.')) {
        cleanPrice = cleanPrice.split('.')[0];
      }
      cleanPrice = cleanPrice.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPrice.isNotEmpty) {
        int parsedPrice = int.parse(cleanPrice);
        displayPrice = 'Rp ' + NumberFormat.decimalPattern('id').format(parsedPrice);
      }
    } catch (e) {
      if (!displayPrice.contains('Rp')) {
        displayPrice = 'Rp $displayPrice';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                finalUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.image)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppColors.fontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayPrice,
                    style: AppColors.fontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF407BFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard({
    required String productName,
    String? imageUrl,
    required String comment,
    required int rating,
    required String date,
    required VoidCallback onTap,
  }) {
    String finalUrl = imageUrl != null && imageUrl.isNotEmpty ? resolveFullUrl(imageUrl, ApiEndpoints.authendpoints.getImageProduk) : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    finalUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppColors.fontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment,
              style: AppColors.fontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: AppColors.fontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder({required IconData icon, required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppColors.fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppColors.fontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikesShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 14,
                        width: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 14,
                        width: 50,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 14,
                            width: 150,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 14,
                            width: 80,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 14,
                  width: 200,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 12,
                  width: 100,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
