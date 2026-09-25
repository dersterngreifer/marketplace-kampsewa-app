import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class NetworkErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isServerError;

  const NetworkErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.isServerError = false,
  });

  static bool isShowing = false;

  static void show({required String title, required String message, bool isServerError = false}) {
    if (isShowing) return;
    isShowing = true;
    Get.dialog(
      NetworkErrorDialog(title: title, message: message, isServerError: isServerError),
      barrierDismissible: false,
      useSafeArea: true,
    ).then((_) => isShowing = false);
  }

  static void hide() {
    if (isShowing) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animation or Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: isServerError 
                    ? Colors.red.withValues(alpha: 0.1) 
                    : AppColors.mainColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isServerError 
                  ? const Icon(Icons.dns_rounded, color: Colors.red, size: 40)
                  : SpinKitPulse(
                      color: AppColors.mainColor,
                      size: 50,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (isServerError)
                SpinKitThreeBounce(
                  color: Colors.red,
                  size: 20,
                )
              else
                SpinKitThreeBounce(
                  color: AppColors.mainColor,
                  size: 20,
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    hide();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isServerError ? Colors.red : AppColors.mainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
