import 'package:get/get.dart';
import 'package:project_camp_sewa/models/notifikasi_model.dart';
import 'package:project_camp_sewa/services/api_notifikasi.dart';

class RiwayatBadgeController extends GetxController {
  /// Menyimpan label tab yang memiliki data pesanan baru / belum dilihat
  /// Pilihan: 'Pembayaran', 'Pengambilan', 'Berlangsung', 'Selesai', 'Denda Belum Lunas', 'Dibatalkan'
  final RxSet<String> unreadTabs = <String>{}.obs;

  /// Penanda apakah ada pembaruan transaksi yang belum dilihat (untuk dot badge di bottom bar)
  bool get hasRiwayatUpdate => unreadTabs.isNotEmpty;

  /// Sinkronisasi tab-tab yang belum dilihat dari list notifikasi
  void syncFromNotifications(List<NotifikasiModel> notifikasiList) {
    final Set<String> updated = {};
    for (final notif in notifikasiList) {
      if (!notif.isRead && notif.isPesanan) {
        final tabIndex = notif.targetRiwayatTabIndex;
        final label = _getTabLabelByIndex(tabIndex);
        if (label != null) {
          updated.add(label);
        }
      }
    }
    unreadTabs.assignAll(updated);
  }

  /// Menandai tab tertentu telah dibuka/dilihat oleh penyewa sehingga titik merah langsung hilang
  void markTabAsViewed(String tabLabel) {
    if (unreadTabs.contains(tabLabel)) {
      unreadTabs.remove(tabLabel);

      // Tandai notifikasi terkait sebagai dibaca di ApiNotifikasi jika ada
      if (Get.isRegistered<ApiNotifikasi>()) {
        final apiNotifikasi = Get.find<ApiNotifikasi>();
        final tabIndex = _getTabIndexByLabel(tabLabel);
        final toMark = apiNotifikasi.listNotifikasi.where(
          (n) => !n.isRead && n.isPesanan && n.targetRiwayatTabIndex == tabIndex,
        ).toList();

        for (final notif in toMark) {
          apiNotifikasi.markAsRead(notif.id);
        }
      }
    }
  }

  void clearAll() {
    unreadTabs.clear();
  }

  String? _getTabLabelByIndex(int? index) {
    switch (index) {
      case 0:
        return 'Pembayaran';
      case 1:
        return 'Pengambilan';
      case 2:
        return 'Berlangsung';
      case 3:
        return 'Selesai';
      case 4:
        return 'Denda Belum Lunas';
      case 5:
        return 'Dibatalkan';
      default:
        return null;
    }
  }

  int? _getTabIndexByLabel(String label) {
    switch (label) {
      case 'Pembayaran':
        return 0;
      case 'Pengambilan':
        return 1;
      case 'Berlangsung':
        return 2;
      case 'Selesai':
        return 3;
      case 'Denda Belum Lunas':
        return 4;
      case 'Dibatalkan':
        return 5;
      default:
        return null;
    }
  }
}
