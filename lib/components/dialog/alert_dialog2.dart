import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlertDialog2 extends StatelessWidget {
  final String? teks;
  final String? title;
  final String? confirmLabel;
  final String? cancelLabel;
  final Function() hapus;

  const CustomAlertDialog2({
    super.key,
    this.teks,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
    required this.hapus,
  });

  @override
  Widget build(BuildContext context) {
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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Warning
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEE2737).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/icons/warning-icon.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFEE2737),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title ?? "Konfirmasi Hapus",
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
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(100),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          cancelLabel ?? "Batal",
                          style: AppColors.fontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2F2828),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: const Color(0xFFEE2737),
                    borderRadius: BorderRadius.circular(100),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () {
                        Get.back();
                        hapus();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          confirmLabel ?? "Hapus",
                          style: AppColors.fontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

