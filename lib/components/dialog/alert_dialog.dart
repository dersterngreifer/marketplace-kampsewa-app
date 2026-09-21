import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlertDialog extends StatelessWidget {
  final String? teks;
  final String? title;
  final bool sukses;
  
  const CustomAlertDialog({
    super.key,
    this.sukses = true,
    this.teks,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = sukses ? const Color(0xFF2C4E40) : const Color(0xFFEE2737);
    final iconPath = sukses ? "assets/images/sukses-logo.png" : "assets/images/error-logo.png";
    final defaultTitle = sukses ? "Berhasil" : "Terjadi Kesalahan";

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  sukses ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: primaryColor,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title ?? defaultTitle,
              style: AppColors.fontStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2F2828),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            if (teks != null)
              Text(
                teks!,
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            
            // Button
            Material(
              color: primaryColor,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Get.back(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Text(
                    "Mengerti",
                    style: AppColors.fontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

