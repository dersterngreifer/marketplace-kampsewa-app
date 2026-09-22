import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';

class CardMetodePembayaran extends StatefulWidget {
  final String metodePembayaran;
  final String bank;
  final String noRek;
  final Function()? edit;
  const CardMetodePembayaran(
      {super.key,
      required this.metodePembayaran,
      required this.bank,
      required this.noRek,
      this.edit});

  @override
  State<CardMetodePembayaran> createState() => _CardMetodePembayaranState();
}

class _CardMetodePembayaranState extends State<CardMetodePembayaran> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            width: 1, 
            color: const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  widget.metodePembayaran == "Transfer"
                      ? "assets/images/metode-pembayaran-transfer.png"
                      : "assets/images/metode-pembayaran-cod.png",
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.metodePembayaran,
                          style: AppColors.fontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        if (widget.metodePembayaran == "Transfer" && widget.edit != null)
                          InkWell(
                            onTap: widget.edit,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                "Ubah",
                                style: AppColors.fontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF407BFF),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.bank,
                      style: AppColors.fontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.noRek,
                      style: AppColors.fontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
