import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/card/produk_card.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:shimmer/shimmer.dart';

class LayoutUserProducts extends StatefulWidget {
  const LayoutUserProducts({super.key});

  @override
  State<LayoutUserProducts> createState() => _LayoutUserProductsState();
}

class _LayoutUserProductsState extends State<LayoutUserProducts> {
  final ApiProduk apiProduk = Get.put(ApiProduk());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiProduk.getUserProducts(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildWarningCard(),
              Expanded(
                child: _buildProductGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C4E40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          Text(
            "Produk Saya",
            style: AppColors.fontStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2F2828),
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance the back button
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEEBA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF856404).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF856404),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Informasi Visibilitas Produk",
                  style: AppColors.fontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Produk Anda hanya dapat dilihat di sini. Anda tidak bisa mencari atau memunculkan produk Anda sendiri di toko, namun produk Anda tetap bisa dicari dan dilihat oleh orang lain.",
                  style: AppColors.fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF856404),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 340,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (apiProduk.isLoadingUserProducts.value) {
        return _buildShimmerLoading();
      }

      final listProduk = apiProduk.listUserProduk;
      if (listProduk.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                "Anda belum memiliki produk.",
                style: AppColors.fontStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 24),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 340,
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
        ),
        itemCount: listProduk.length,
        itemBuilder: (context, index) {
          final ProdukModel p = listProduk[index];
          return ProdukCard(
            images: p.images,
            namaProduk: p.namaProduk,
            harga: p.harga.toString(),
            rating: p.rating.toString(),
            stok: p.stok,
            jumlahReview: p.jumlahReview,
            isFavorite: p.isFavorite,
            badgeLabel: "Milik Anda", // Disable sewa button and show badge
            namaToko: p.namaToko,
            fotoToko: p.fotoToko,
            ratingToko: p.ratingToko,
            aksi: () {
              // Ensure idToko matches current user so LayoutDetailProduct recognizes it as own product
              final currentUserId =
                  Get.find<ApiDataUser>().dataUser.value?.id ?? p.idUser;
              Get.to(const LayoutDetailProduct(), arguments: {
                'idToko': currentUserId,
                'idProduk': p.idProduk,
                'namaProduk': p.namaProduk,
                'fotoProduk': p.image,
                'namaToko': p.namaToko,
                'fotoToko': p.fotoToko,
                'ratingToko': p.ratingToko,
              });
            },
            aksiKeranjang: () {
              Get.snackbar(
                "Informasi",
                "Ini adalah produk Anda sendiri.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF2C4E40),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
          );
        },
      );
    });
  }
}
