import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class LoadingDialog {
  /// Track status tampil agar loading dialog tidak pernah menutup dialog lain
  /// (mis. NetworkErrorDialog) yang berada di atasnya.
  static bool isShowing = false;

  void showLoadingDialog() {
    if (isShowing) return;
    if (Get.isDialogOpen != true) {
      isShowing = true;
      Get.dialog(
        PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              child: Container(
                width: 180,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SpinKitDoubleBounce(
                      color: Color(0xFF2C4E40),
                      size: 45,
                    ),
                    const SizedBox(height: 24),
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        "Harap Tunggu...",
                        style: AppColors.fontStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F2828),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.4),
      ).then((_) => isShowing = false);
    }
  }

  void hideLoadingDialog() {
    if (!isShowing) return;
    isShowing = false;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}

