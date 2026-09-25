import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';

class ItemVariant extends StatefulWidget {
  final String item;
  final bool selected;
  final Function()? aksi;
  const ItemVariant(
      {super.key,
      required this.item,
      required this.aksi,
      this.selected = false});

  @override
  State<ItemVariant> createState() => _ItemVariantState();
}

class _ItemVariantState extends State<ItemVariant> {
  // Gradient hijau brand — menggantikan warna gelap/coklat flat sebelumnya.
  static const Color _gradientStart = Color(0xFF2C4E40);
  static const Color _gradientEnd = Color(0xFF3F7360);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.aksi,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: widget.selected
              ? const LinearGradient(
                  colors: [_gradientStart, _gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: widget.selected ? null : Colors.white,
          border: widget.selected
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
          boxShadow: widget.selected
              ? [
                  BoxShadow(
                    color: _gradientStart.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.selected) ...[
                  const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 5),
                ],
                Text(
                  widget.item,
                  style: AppColors.fontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.selected
                          ? Colors.white
                          : const Color(0xFF424242)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
