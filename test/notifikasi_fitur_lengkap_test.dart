import 'package:flutter_test/flutter_test.dart';
import 'package:project_camp_sewa/models/notifikasi_model.dart';
import 'package:project_camp_sewa/services/controller_riwayat_badge.dart';

void main() {
  group('Fitur Notifikasi & Riwayat Dot Badge Tests', () {
    test('NotifikasiModel parses review milestone and targets correctly', () {
      final jsonMilestone = {
        'id': 101,
        'id_user': 501,
        'tipe': 'ulasan_milestone',
        'id_referensi': 77,
        'judul': 'Produk Mencapai 10 Ulasan!',
        'pesan': 'Selamat! Produk telah mencapai total 10 ulasan.',
        'url': null,
        'is_read': false,
        'created_at': '2026-10-20T12:00:00Z',
      };

      final notif = NotifikasiModel.fromJson(jsonMilestone);
      expect(notif.isUlasanMilestone, isTrue);
      expect(notif.idReferensi, 77);
      expect(notif.isSuspend, isFalse);
      expect(notif.isPesanan, isFalse);
    });

    test('NotifikasiModel maps rental transaction types to correct Riwayat tab index', () {
      final notifApprove = NotifikasiModel(
        id: 1,
        idUser: 501,
        tipe: 'pesanan_disetujui',
        judul: 'Disetujui',
        pesan: 'Silakan ambil barang',
        createdAt: '',
      );
      expect(notifApprove.targetRiwayatTabIndex, 1); // Pengambilan

      final notifOngoing = NotifikasiModel(
        id: 2,
        idUser: 501,
        tipe: 'pesanan_diambil',
        judul: 'Diambil',
        pesan: 'Masa sewa berjalan',
        createdAt: '',
      );
      expect(notifOngoing.targetRiwayatTabIndex, 2); // Berlangsung

      final notifDenda = NotifikasiModel(
        id: 3,
        idUser: 501,
        tipe: 'pesanan_denda',
        judul: 'Denda',
        pesan: 'Denda keterlambatan',
        createdAt: '',
      );
      expect(notifDenda.targetRiwayatTabIndex, 4); // Denda Belum Lunas

      final notifSelesai = NotifikasiModel(
        id: 4,
        idUser: 501,
        tipe: 'pesanan_selesai',
        judul: 'Selesai',
        pesan: 'Masa sewa selesai',
        createdAt: '',
      );
      expect(notifSelesai.targetRiwayatTabIndex, 3); // Selesai

      final notifBatal = NotifikasiModel(
        id: 5,
        idUser: 501,
        tipe: 'pesanan_dibatalkan',
        judul: 'Batal',
        pesan: 'Pesanan dibatalkan',
        createdAt: '',
      );
      expect(notifBatal.targetRiwayatTabIndex, 5); // Dibatalkan
    });

    test('NotifikasiModel identifies iklan types and web-only flags', () {
      final notifIklan = NotifikasiModel(
        id: 10,
        idUser: 501,
        tipe: 'iklan_selesai_otomatis',
        judul: 'Iklan Selesai',
        pesan: 'Masa tayang iklan telah berakhir',
        url: '/customer/buat-iklan',
        createdAt: '',
      );

      expect(notifIklan.isIklan, isTrue);
      expect(notifIklan.isWebOnly, isTrue);
    });

    test('RiwayatBadgeController tracks unread tabs and clears them on view', () {
      final badgeController = RiwayatBadgeController();

      final notifs = [
        NotifikasiModel(
          id: 1,
          idUser: 501,
          tipe: 'pesanan_disetujui',
          judul: 'Disetujui',
          pesan: 'Silakan ambil barang',
          isRead: false,
          createdAt: '',
        ),
        NotifikasiModel(
          id: 2,
          idUser: 501,
          tipe: 'pesanan_denda',
          judul: 'Denda',
          pesan: 'Denda belum lunas',
          isRead: false,
          createdAt: '',
        ),
      ];

      badgeController.syncFromNotifications(notifs);

      expect(badgeController.hasRiwayatUpdate, isTrue);
      expect(badgeController.unreadTabs.contains('Pengambilan'), isTrue);
      expect(badgeController.unreadTabs.contains('Denda Belum Lunas'), isTrue);
      expect(badgeController.unreadTabs.contains('Berlangsung'), isFalse);

      // User opens 'Pengambilan' tab -> dot on that tab disappears
      badgeController.markTabAsViewed('Pengambilan');
      expect(badgeController.unreadTabs.contains('Pengambilan'), isFalse);
      expect(badgeController.hasRiwayatUpdate, isTrue); // 'Denda Belum Lunas' still unread

      // User opens 'Denda Belum Lunas' tab -> dot disappears and bottom nav badge clears
      badgeController.markTabAsViewed('Denda Belum Lunas');
      expect(badgeController.unreadTabs.contains('Denda Belum Lunas'), isFalse);
      expect(badgeController.hasRiwayatUpdate, isFalse);
    });
  });
}
