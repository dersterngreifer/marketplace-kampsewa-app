import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class DialogMenungguVerifikasi extends StatelessWidget {
  final VoidCallback onLihatStatus;
  final VoidCallback onKeBeranda;
  final String? idPenyewaan;
  final String? totalBayar;

  const DialogMenungguVerifikasi({
    super.key,
    required this.onLihatStatus,
    required this.onKeBeranda,
    this.idPenyewaan,
    this.totalBayar,
  });

  String _formatCurrency(String numberString) {
    try {
      final number = int.parse(numberString.replaceAll(RegExp(r'[^0-9]'), ''));
      final formatter = NumberFormat.decimalPattern('id');
      return "Rp ${formatter.format(number)}";
    } catch (_) {
      return "Rp $numberString";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Badge
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2C4E40).withValues(alpha: 0.08),
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF3B6755), Color(0xFF233F34)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Menunggu Verifikasi Toko",
                        style: AppColors.fontStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  "Pembayaran Terkirim!",
                  style: AppColors.fontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  "Bukti transfer dan foto KTP Anda berhasil diunggah. Pihak toko sedang meninjau pembayaran Anda sebelum pesanan diproses.",
                  style: AppColors.fontStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Order Summary Card (if available)
                if ((idPenyewaan != null && idPenyewaan!.isNotEmpty) ||
                    (totalBayar != null && totalBayar!.isNotEmpty))
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (idPenyewaan != null && idPenyewaan!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.tag_rounded, size: 16, color: Colors.blueGrey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                "Pesanan #$idPenyewaan",
                                style: AppColors.fontStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                            ],
                          ),
                        if (totalBayar != null && totalBayar!.isNotEmpty)
                          Text(
                            _formatCurrency(totalBayar!),
                            style: AppColors.fontStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEE2737),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Process Timeline Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF10B981),
                        title: "Upload Bukti & KTP",
                        subtitle: "Telah berhasil diunggah",
                        badgeText: "Selesai",
                        badgeColor: const Color(0xFFD1FAE5),
                        badgeTextColor: const Color(0xFF047857),
                      ),
                      _buildTimelineDivider(isCompleted: true),
                      _buildTimelineItem(
                        icon: Icons.hourglass_bottom_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: "Verifikasi oleh Toko",
                        subtitle: "Sedang ditinjau pemilik toko",
                        badgeText: "Proses",
                        badgeColor: const Color(0xFFFEF3C7),
                        badgeTextColor: const Color(0xFFB45309),
                      ),
                      _buildTimelineDivider(isCompleted: false),
                      _buildTimelineItem(
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFF94A3B8),
                        title: "Pesanan Siap Disewa",
                        subtitle: "Ambil di toko / tunggu diantar",
                        badgeText: "Menunggu",
                        badgeColor: const Color(0xFFF1F5F9),
                        badgeTextColor: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Estimated Time Notice
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF86EFAC).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Estimasi waktu verifikasi sekitar 5 - 30 menit.",
                          style: AppColors.fontStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Primary Button: Lihat Status Pesanan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onLihatStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C4E40),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Lihat Status Pesanan",
                          style: AppColors.fontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Secondary Button: Kembali ke Beranda
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: onKeBeranda,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Kembali ke Beranda",
                      style: AppColors.fontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppColors.fontStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                subtitle,
                style: AppColors.fontStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badgeText,
            style: AppColors.fontStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: badgeTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider({required bool isCompleted}) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10),
      height: 14,
      child: Container(
        width: 2,
        height: 14,
        color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
      ),
    );
  }
}
