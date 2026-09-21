import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class LoadingDialog {
  void showLoadingDialog() {
    if (Get.isDialogOpen != true) {
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SpinKitDoubleBounce(
                    color: Color(0xFF2C4E40),
                    size: 50,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Harap Tunggu...",
                    style: AppColors.fontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F2828),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.4),
      );
    }
  }

  void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
