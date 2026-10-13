import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class ButtonSwipeRight extends StatelessWidget {
  final String title;
  final Future<void> Function()? fungsi;
  final Color titleColor;
  final Color roundedBgColor;
  final Color bgColor;
  final Color iconColor;

  const ButtonSwipeRight({
    super.key,
    this.title = "Mulai Sekarang!",
    required this.fungsi,
    this.bgColor = const Color(0xFF1E1E1E),
    this.iconColor = Colors.black,
    this.titleColor = Colors.white,
    this.roundedBgColor = Colors.white,
  });

  Future<void> _handleAction(ActionSliderController controller) async {
    controller.loading();
    HapticFeedback.mediumImpact();

    // Berikan jeda kecil untuk feedback animasi loading
    await Future.delayed(const Duration(milliseconds: 200));

    controller.success();

    // Jeda sejenak untuk menampilkan icon sukses (checkmark)
    await Future.delayed(const Duration(milliseconds: 250));

    if (fungsi != null) {
      await fungsi!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSlider.standard(
      sliderBehavior: SliderBehavior.stretch,
      height: 60.0,
      backgroundColor: bgColor,
      toggleColor: roundedBgColor,
      icon: Icon(
        Icons.arrow_forward_rounded,
        color: iconColor,
        size: 24,
      ),
      loadingIcon: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: iconColor,
        ),
      ),
      successIcon: const Icon(
        Icons.check_rounded,
        color: AppColors.mainColor,
        size: 26,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      action: _handleAction,
      onTap: (controller, pos) => _handleAction(controller),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppColors.fontStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_double_arrow_right_rounded,
            color: titleColor.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}
