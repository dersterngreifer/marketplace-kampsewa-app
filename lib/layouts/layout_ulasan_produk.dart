import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class LayoutUlasanProduk extends StatelessWidget {
  final String namaProduk;

  const LayoutUlasanProduk({super.key, required this.namaProduk});

  @override
  Widget build(BuildContext context) {
    // Data dummy 15 ulasan untuk halaman ulasan lengkap
    final dummyReviews = List.generate(
      15,
      (index) => {
        'user': 'User ${index + 1}',
        'rating': 5 - (index % 2),
        'date': '${15 - index} Sep 2023',
        'comment':
            'Barangnya sangat bagus, pengiriman cepat dan seller ramah. Bakal langganan terus di sini!',
        'photos': [
          'https://picsum.photos/200/200?random=${index * 2}',
          'https://picsum.photos/200/200?random=${index * 2 + 1}',
        ],
      },
    );

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyReviews.length,
        separatorBuilder: (_, __) => const Divider(height: 32, thickness: 1),
        itemBuilder: (context, index) {
          final review = dummyReviews[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person,
                        size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['user'] as String,
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
                              color: starIndex < (review['rating'] as int)
                                  ? const Color(0xFFFFC107)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    review['date'] as String,
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
                review['comment'] as String,
                style: AppColors.fontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF2F2828),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: (review['photos'] as List<String>)
                    .map(
                      (photo) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
