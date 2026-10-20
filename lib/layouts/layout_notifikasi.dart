import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';
import 'package:project_camp_sewa/models/notifikasi_model.dart';
import 'package:project_camp_sewa/screens/screen_riwayat.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/services/api_notifikasi.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LayoutNotifikasi extends StatefulWidget {
  const LayoutNotifikasi({super.key});

  @override
  State<LayoutNotifikasi> createState() => _LayoutNotifikasiState();
}

class _LayoutNotifikasiState extends State<LayoutNotifikasi> {
  final ApiNotifikasi apiNotifikasi = Get.put(ApiNotifikasi(), permanent: true);
  bool unreadOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiNotifikasi.fetchNotifikasi(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.mainColor,
                  onRefresh: () => apiNotifikasi.fetchNotifikasi(
                    context: context,
                    unreadOnly: unreadOnly,
                  ),
                  child: _buildNotificationList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C4E40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notifikasi",
                  style: AppColors.fontStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F2828),
                  ),
                ),
                Obx(() {
                  final count = apiNotifikasi.unreadCount.value;
                  return Text(
                    count > 0 ? "$count notifikasi baru" : "Semua telah dibaca",
                    style: AppColors.fontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: count > 0
                          ? const Color(0xFFE53935)
                          : Colors.grey.shade500,
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            if (apiNotifikasi.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return TextButton.icon(
              onPressed: () => apiNotifikasi.markAllAsRead(context: context),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: Text(
                "Baca Semua",
                style: AppColors.fontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mainColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _buildChip(
            label: "Semua",
            isSelected: !unreadOnly,
            onTap: () {
              if (unreadOnly) {
                setState(() => unreadOnly = false);
                apiNotifikasi.fetchNotifikasi(
                    context: context, unreadOnly: false);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: "Belum Dibaca",
            isSelected: unreadOnly,
            onTap: () {
              if (!unreadOnly) {
                setState(() => unreadOnly = true);
                apiNotifikasi.fetchNotifikasi(
                    context: context, unreadOnly: true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C4E40) : const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppColors.fontStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF5F6368),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return Obx(() {
      if (apiNotifikasi.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.mainColor),
        );
      }

      final allItems = apiNotifikasi.listNotifikasi;
      // Filter out notifikasi ulasan satu-persatu (ulasan_baru) sesuai ketentuan Point 4.
      // Hanya tampilkan notifikasi milestone (ulasan_milestone) dan notifikasi penting lainnya.
      final items = allItems.where((n) => n.tipe != 'ulasan_baru').toList();

      if (items.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C4E40).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: Color(0xFF2C4E40),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  unreadOnly
                      ? "Tidak ada notifikasi belum dibaca"
                      : "Belum ada notifikasi",
                  style: AppColors.fontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2828),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Pemberitahuan produk, ulasan, pesanan & transaksi akan muncul di sini.",
                  textAlign: TextAlign.center,
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildNotificationCard(item);
        },
      );
    });
  }

  Widget _buildNotificationCard(NotifikasiModel notif) {
    final bool isSuspend = notif.isSuspend;
    final bool isPulih = notif.isPulih;
    final bool isUlasan = notif.isUlasanMilestone;
    final bool isIklan = notif.isIklan;
    final bool isPesanan = notif.isPesanan;

    Color cardBg = notif.isRead ? Colors.white : const Color(0xFFF9FBFF);
    Color borderColor =
        notif.isRead ? Colors.grey.shade200 : const Color(0xFFBBDEFB);
    Color iconBg = const Color(0xFFE3F2FD);
    Color iconColor = const Color(0xFF1976D2);
    IconData iconData = Icons.notifications_rounded;

    if (isSuspend) {
      cardBg = notif.isRead ? Colors.white : const Color(0xFFFFF9F9);
      borderColor =
          notif.isRead ? Colors.grey.shade200 : const Color(0xFFFFCDD2);
      iconBg = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFD32F2F);
      iconData = Icons.lock_person_rounded;
    } else if (isPulih) {
      cardBg = notif.isRead ? Colors.white : const Color(0xFFF9FFF9);
      borderColor =
          notif.isRead ? Colors.grey.shade200 : const Color(0xFFC8E6C9);
      iconBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      iconData = Icons.verified_rounded;
    } else if (isUlasan) {
      cardBg = notif.isRead ? Colors.white : const Color(0xFFFFFDF5);
      borderColor =
          notif.isRead ? Colors.grey.shade200 : const Color(0xFFFFECB3);
      iconBg = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFFFA000);
      iconData = Icons.reviews_rounded;
    } else if (isIklan) {
      final bool isIklanSuspend = notif.tipe == 'iklan_suspend';
      final bool isIklanSelesai =
          notif.tipe.contains('selesai') || notif.tipe.contains('force');
      cardBg = notif.isRead ? Colors.white : const Color(0xFFFAF7FF);
      borderColor = notif.isRead
          ? Colors.grey.shade200
          : (isIklanSuspend
              ? const Color(0xFFFFCCBC)
              : const Color(0xFFD1C4E9));
      iconBg =
          isIklanSuspend ? const Color(0xFFFBE9E7) : const Color(0xFFEDE7F6);
      iconColor =
          isIklanSuspend ? const Color(0xFFD84315) : const Color(0xFF5E35B1);
      iconData = isIklanSelesai
          ? Icons.event_available_rounded
          : Icons.campaign_rounded;
    } else if (isPesanan) {
      if (notif.tipe.contains('denda')) {
        cardBg = notif.isRead ? Colors.white : const Color(0xFFFFFDF8);
        borderColor =
            notif.isRead ? Colors.grey.shade200 : const Color(0xFFFFCCBC);
        iconBg = const Color(0xFFFBE9E7);
        iconColor = const Color(0xFFD84315);
        iconData = Icons.gavel_rounded;
      } else if (notif.tipe.contains('batal')) {
        cardBg = notif.isRead ? Colors.white : const Color(0xFFFAFAFA);
        borderColor =
            notif.isRead ? Colors.grey.shade200 : const Color(0xFFCFD8DC);
        iconBg = const Color(0xFFECEFF1);
        iconColor = const Color(0xFF546E7A);
        iconData = Icons.cancel_rounded;
      } else if (notif.tipe.contains('selesai')) {
        cardBg = notif.isRead ? Colors.white : const Color(0xFFF9FFFD);
        borderColor =
            notif.isRead ? Colors.grey.shade200 : const Color(0xFFB2DFDB);
        iconBg = const Color(0xFFE0F2F1);
        iconColor = const Color(0xFF00796B);
        iconData = Icons.check_circle_rounded;
      } else if (notif.tipe.contains('ambil') ||
          notif.tipe.contains('setuju')) {
        cardBg = notif.isRead ? Colors.white : const Color(0xFFF9FFF9);
        borderColor =
            notif.isRead ? Colors.grey.shade200 : const Color(0xFFC8E6C9);
        iconBg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2E7D32);
        iconData = Icons.inventory_2_rounded;
      } else {
        cardBg = notif.isRead ? Colors.white : const Color(0xFFF9FBFF);
        borderColor =
            notif.isRead ? Colors.grey.shade200 : const Color(0xFFBBDEFB);
        iconBg = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1976D2);
        iconData = Icons.local_shipping_rounded;
      }
    }

    return InkWell(
      onTap: () => _handleCardTap(notif),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: notif.isRead ? 1 : 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 20, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.judul,
                              style: AppColors.fontStyle(
                                fontSize: 13.5,
                                fontWeight: notif.isRead
                                    ? FontWeight.w700
                                    : FontWeight.w800,
                                color: isSuspend
                                    ? const Color(0xFFC62828)
                                    : const Color(0xFF2F2828),
                              ),
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: isSuspend
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimestamp(notif.createdAt),
                        style: AppColors.fontStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              notif.pesan,
              style: AppColors.fontStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
                height: 1.4,
              ),
            ),
            if (notif.alasan != null && notif.alasan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 14, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Alasan: ${notif.alasan}",
                        style: AppColors.fontStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Tombol Aksi Sesuai Jenis Pemberitahuan (Point 8)
            const SizedBox(height: 12),
            _buildActionButtons(notif),
          ],
        ),
      ),
    );
  }

  void _handleCardTap(NotifikasiModel notif) {
    if (!notif.isRead) {
      apiNotifikasi.markAsRead(notif.id);
    }
    if ((notif.isSuspend || notif.isPulih || notif.isUlasanMilestone) &&
        notif.idReferensi != null) {
      final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
      Get.to(() => const LayoutDetailProduct(), arguments: {
        'idToko': currentUserId,
        'idProduk': notif.idReferensi,
      });
    } else if (notif.isPesanan) {
      final targetIndex = notif.targetRiwayatTabIndex ?? 0;
      Get.to(() => RiwayatScreen(initialIndex: targetIndex));
    }
  }

  Widget _buildActionButtons(NotifikasiModel notif) {
    if (notif.isSuspend) {
      return Row(
        children: [
          if (notif.idReferensi != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (!notif.isRead) apiNotifikasi.markAsRead(notif.id);
                  final currentUserId =
                      Get.find<ApiDataUser>().dataUser.value?.id;
                  Get.to(() => const LayoutDetailProduct(), arguments: {
                    'idToko': currentUserId,
                    'idProduk': notif.idReferensi,
                  });
                },
                icon: const Icon(Icons.visibility_outlined, size: 14),
                label: Text(
                  "Lihat Produk",
                  style: AppColors.fontStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (notif.idReferensi != null) const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                if (!notif.isRead) apiNotifikasi.markAsRead(notif.id);
                final Uri url = Uri.parse(ApiEndpoints.baseUrl);
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  Get.snackbar("Error", "Gagal membuka web browser");
                }
              },
              icon: const Icon(Icons.open_in_browser_rounded, size: 14),
              label: Text(
                "Revisi di Web",
                style: AppColors.fontStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C4E40),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    }

    if (notif.isUlasanMilestone) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            if (!notif.isRead) apiNotifikasi.markAsRead(notif.id);
            final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
            Get.to(() => const LayoutDetailProduct(), arguments: {
              'idToko': currentUserId,
              'idProduk': notif.idReferensi,
            });
          },
          icon: const Icon(Icons.star_outline_rounded, size: 15),
          label: Text(
            "Lihat Ulasan & Produk",
            style: AppColors.fontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C4E40),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    if (notif.isPulih) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            if (!notif.isRead) apiNotifikasi.markAsRead(notif.id);
            final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
            Get.to(() => const LayoutDetailProduct(), arguments: {
              'idToko': currentUserId,
              'idProduk': notif.idReferensi,
            });
          },
          icon: const Icon(Icons.visibility_outlined, size: 15),
          label: Text(
            "Lihat Produk Aktif",
            style: AppColors.fontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C4E40),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    if (notif.isIklan) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (!notif.isRead) apiNotifikasi.markAsRead(notif.id);
            final targetUrl = notif.url != null && notif.url!.isNotEmpty
                ? notif.url!
                : "${ApiEndpoints.baseUrl}/customer/buat-iklan";
            final Uri uri = Uri.parse(targetUrl.startsWith('http')
                ? targetUrl
                : "${ApiEndpoints.baseUrl}$targetUrl");
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              Get.snackbar("Error", "Gagal membuka dashboard iklan");
            }
          },
          icon: const Icon(Icons.open_in_browser_rounded, size: 15),
          label: Text(
            "Kelola Iklan di Web",
            style: AppColors.fontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E35B1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    if (notif.isPesanan) {
      final tabIndex = notif.targetRiwayatTabIndex ?? 0;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            if (!notif.isRead) apiNotifikasi.markAsRead(notif.id);
            Get.to(() => RiwayatScreen(initialIndex: tabIndex));
          },
          icon: const Icon(Icons.receipt_long_rounded, size: 15),
          label: Text(
            "Lihat di Riwayat Pesanan",
            style: AppColors.fontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C4E40),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    // Default Fallback
    if (notif.idReferensi != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            if (!notif.isRead) apiNotifikasi.markAsRead(notif.id);
            final currentUserId = Get.find<ApiDataUser>().dataUser.value?.id;
            Get.to(() => const LayoutDetailProduct(), arguments: {
              'idToko': currentUserId,
              'idProduk': notif.idReferensi,
            });
          },
          icon: const Icon(Icons.visibility_outlined, size: 15),
          label: Text(
            "Lihat Detail",
            style: AppColors.fontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2C4E40),
            side: const BorderSide(color: Color(0xFF2C4E40)),
            padding: const EdgeInsets.symmetric(vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatTimestamp(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) {
        return "Baru saja";
      } else if (diff.inHours < 1) {
        return "${diff.inMinutes} menit lalu";
      } else if (diff.inDays < 1) {
        return "${diff.inHours} jam lalu";
      } else if (diff.inDays < 7) {
        return "${diff.inDays} hari lalu";
      } else {
        return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      }
    } catch (_) {
      return raw;
    }
  }
}
