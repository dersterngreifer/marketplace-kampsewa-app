import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/card/riwayat_card.dart';
import 'package:project_camp_sewa/models/riwayat_model.dart';
import 'package:project_camp_sewa/services/api_riwayat.dart';

class LayoutRiwayat extends StatefulWidget {
  final String status;
  const LayoutRiwayat({super.key, required this.status});

  @override
  State<LayoutRiwayat> createState() => _LayoutRiwayatState();
}

class _LayoutRiwayatState extends State<LayoutRiwayat> {
  final ApiRiwayat _apiRiwayat = Get.put(ApiRiwayat(), tag: UniqueKey().toString());

  @override
  void initState() {
    super.initState();
    _apiRiwayat.fetchRiwayat(status: widget.status);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_apiRiwayat.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2C4E40)));
      }

      final listRiwayat = _apiRiwayat.riwayatList;

      if (_apiRiwayat.errorMessage.value.isNotEmpty) {
        return Container(
          color: const Color(0xFFFFFFFF),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _apiRiwayat.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
      }

    if (listRiwayat.isEmpty) {
      return Container(
        color: const Color(0xFFFFFFFF),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F2828).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 64,
                  color: Color(0xFF2F2828),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Belum ada pesanan",
                style: AppColors.fontStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F2828),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Pesanan kamu akan muncul di sini",
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFFAFAFA),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: ListView.separated(
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              RiwayatModel list = listRiwayat[index];
              return RiwayatCard(data: list);
            },
            separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
            itemCount: listRiwayat.length),
      ),
    );
    });
  }
}
