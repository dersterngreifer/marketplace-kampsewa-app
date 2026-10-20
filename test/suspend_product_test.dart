import 'package:flutter_test/flutter_test.dart';
import 'package:project_camp_sewa/models/detail_produk_model.dart';
import 'package:project_camp_sewa/models/notifikasi_model.dart';
import 'package:project_camp_sewa/models/produk_model.dart';
import 'package:project_camp_sewa/models/suspend_info_model.dart';

void main() {
  group('Suspend and Product Models Test', () {
    test('SuspendInfoModel parses from JSON correctly', () {
      final json = {
        "id_suspend": 15,
        "alasan": "Foto Berbau Seksual / Vulgar",
        "catatan": "Mohon ganti foto utama dengan foto asli produk jaket camping.",
        "status_revisi": "menunggu_perbaikan",
        "created_at": "2026-10-20 10:45:00",
        "instruksi": "Revisi dan pengajuan pemulihan hanya dapat dilakukan melalui Dashboard Web KampSewa."
      };

      final suspend = SuspendInfoModel.fromJson(json);

      expect(suspend.idSuspend, 15);
      expect(suspend.alasan, "Foto Berbau Seksual / Vulgar");
      expect(suspend.catatan, "Mohon ganti foto utama dengan foto asli produk jaket camping.");
      expect(suspend.statusRevisi, "menunggu_perbaikan");
      expect(suspend.createdAt, "2026-10-20 10:45:00");
      expect(suspend.instruksi, contains("Dashboard Web"));
    });

    test('ProdukModel parses suspended product correctly', () {
      final json = {
        "id": 142,
        "id_produk": 142,
        "id_user": 5011,
        "nama_user": "Icha Riska Nadilla",
        "nama_toko": "Outdoor Adventure Store",
        "foto_toko": "http://marketplace-kampsewa-web.test/assets/image/customers/logo_toko/toko.png",
        "nama_produk": "Pakaian Anti Air Dan Hangat Untuk Camping",
        "kategori": "Pakaian",
        "status_produk": "Ditangguhkan",
        "rata_rating": "4.8",
        "harga_sewa": 35000,
        "stok": 10,
        "total_likes": 12,
        "is_liked": false,
        "foto_depan": "http://marketplace-kampsewa-web.test/assets/image/customers/produk/foto1.jpg",
        "images": [
          "http://marketplace-kampsewa-web.test/assets/image/customers/produk/foto1.jpg"
        ],
        "is_locked": true,
        "locked_message": "Produk ini ditangguhkan oleh Admin KampSewa. Silakan lakukan revisi perbaikan produk melalui Dashboard Web KampSewa.",
        "revisi_via_web_only": true,
        "suspend_info": {
          "id_suspend": 15,
          "alasan": "Foto Berbau Seksual / Vulgar",
          "catatan": "Mohon ganti foto utama dengan foto asli produk jaket camping.",
          "status_revisi": "menunggu_perbaikan",
          "created_at": "2026-10-20 10:45:00",
          "instruksi": "Revisi dan pengajuan pemulihan hanya dapat dilakukan melalui Dashboard Web KampSewa."
        }
      };

      final produk = ProdukModel.fromJson(json);

      expect(produk.idProduk, 142);
      expect(produk.statusProduk, "Ditangguhkan");
      expect(produk.isLocked, isTrue);
      expect(produk.lockedMessage, contains("Dashboard Web"));
      expect(produk.revisiViaWebOnly, isTrue);
      expect(produk.suspendInfo, isNotNull);
      expect(produk.suspendInfo!.idSuspend, 15);
      expect(produk.suspendInfo!.alasan, "Foto Berbau Seksual / Vulgar");
    });

    test('ProdukModel parses active product correctly with isLocked = false', () {
      final json = {
        "id": 143,
        "id_produk": 143,
        "id_user": 5011,
        "nama_user": "Icha Riska Nadilla",
        "nama_toko": "Outdoor Adventure Store",
        "foto_toko": "http://marketplace-kampsewa-web.test/assets/image/customers/logo_toko/toko.png",
        "nama_produk": "Tenda Dome 4 Orang",
        "kategori": "Tenda",
        "status_produk": "Tersedia",
        "rata_rating": "5.0",
        "harga_sewa": 60000,
        "stok": 4,
        "total_likes": 25,
        "is_liked": true,
        "foto_depan": "http://marketplace-kampsewa-web.test/assets/image/customers/produk/tenda.jpg",
        "images": [
          "http://marketplace-kampsewa-web.test/assets/image/customers/produk/tenda.jpg"
        ],
        "is_locked": false,
        "locked_message": null,
        "revisi_via_web_only": true,
        "suspend_info": null
      };

      final produk = ProdukModel.fromJson(json);

      expect(produk.idProduk, 143);
      expect(produk.statusProduk, "Tersedia");
      expect(produk.isLocked, isFalse);
      expect(produk.lockedMessage, isNull);
      expect(produk.suspendInfo, isNull);
    });

    test('DetailProdukModel parses suspended product correctly', () {
      final json = {
        "id": 142,
        "id_produk": 142,
        "nama_produk": "Pakaian Anti Air Dan Hangat Untuk Camping",
        "deskripsi_produk": "Jaket gunung waterproof cocok untuk cuaca ekstrem.",
        "status_produk": "Ditangguhkan",
        "harga_sewa": 35000,
        "stok": 10,
        "rating": 4.8,
        "total_ulasan": 7,
        "id_user": 5011,
        "nama_user": "Icha Riska Nadilla",
        "nama_toko": "Outdoor Adventure Store",
        "foto_toko": "http://marketplace-kampsewa-web.test/assets/image/customers/logo_toko/toko.png",
        "foto_depan": "http://marketplace-kampsewa-web.test/assets/image/customers/produk/foto1.jpg",
        "images": [
          "http://marketplace-kampsewa-web.test/assets/image/customers/produk/foto1.jpg"
        ],
        "is_locked": true,
        "locked_message": "Produk ini ditangguhkan oleh Admin KampSewa. Silakan lakukan revisi perbaikan produk melalui Dashboard Web KampSewa.",
        "revisi_via_web_only": true,
        "suspend_info": {
          "id_suspend": 15,
          "alasan": "Foto Berbau Seksual / Vulgar",
          "catatan": "Mohon ganti foto utama dengan foto asli produk jaket camping.",
          "status_revisi": "menunggu_perbaikan",
          "created_at": "2026-10-20 10:45:00",
          "instruksi": "Revisi dan pengajuan pemulihan hanya dapat dilakukan melalui Dashboard Web KampSewa."
        }
      };

      final detail = DetailProdukModel.fromJson(json);

      expect(detail.idProduk, 142);
      expect(detail.statusProduk, "Ditangguhkan");
      expect(detail.isLocked, isTrue);
      expect(detail.suspendInfo, isNotNull);
      expect(detail.suspendInfo!.catatan, "Mohon ganti foto utama dengan foto asli produk jaket camping.");
    });

    test('NotifikasiModel parses suspend notification correctly', () {
      final json = {
        "id": 89,
        "id_user": 5011,
        "tipe": "produk_suspend",
        "id_referensi": 142,
        "judul": "Produk Ditangguhkan (Suspend)",
        "pesan": "Produk \"Pakaian Anti Air Dan Hangat Untuk Camping\" telah ditangguhkan oleh admin. Alasan: Foto Berbau Seksual / Vulgar. Silakan lakukan revisi perbaikan produk melalui Dashboard Web KampSewa.",
        "alasan": "Foto Berbau Seksual / Vulgar",
        "is_read": false,
        "created_at": "2026-10-20T10:45:00.000000Z"
      };

      final notif = NotifikasiModel.fromJson(json);

      expect(notif.id, 89);
      expect(notif.tipe, "produk_suspend");
      expect(notif.idReferensi, 142);
      expect(notif.isRead, isFalse);
      expect(notif.alasan, "Foto Berbau Seksual / Vulgar");
    });
  });
}
