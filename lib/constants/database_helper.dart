// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/layouts/layout_keranjang.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('keranjang.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE keranjang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_toko INTEGER,
        nama_toko TEXT,
        id_produk INTEGER,
        foto_produk TEXT,
        nama_produk TEXT,
        variant_warna TEXT,
        variant_ukuran TEXT,
        harga INTEGER,
        qty INTEGER,
        selected INTEGER
    )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  static void _navigateToKeranjang() {
    Get.to(() => const LayoutKeranjang());
  }

  Future<void> insertKeranjang(
      Map<String, dynamic> row, BuildContext context) async {
    final db = await instance.database;

    try {
      final existing = await db.query(
        'keranjang',
        where: 'id_produk = ? AND variant_warna = ? AND variant_ukuran = ?',
        whereArgs: [
          row['id_produk'],
          row['variant_warna'],
          row['variant_ukuran']
        ],
      );

      if (existing.isNotEmpty) {
        final existingQty = existing.first['qty'] as int;
        final newQty = row['qty'] as int;
        final updatedQty = existingQty + newQty;

        await db.update(
          'keranjang',
          {'qty': updatedQty},
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        await db.insert('keranjang', row);
      }

      CustomSnackBar.show(
        context,
        sukses: true,
        teks: "Berhasil Memasukkan Produk Ke Keranjang",
        actionLabel: "Lihat",
        onAction: _navigateToKeranjang,
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        sukses: false,
        teks: "Gagal Memasukkan Produk",
      );
    }
  }

  Future<int> getVariantQtyInCart(
      int idProduk, String warna, String ukuran) async {
    final db = await instance.database;
    final result = await db.query(
      'keranjang',
      where: 'id_produk = ? AND variant_warna = ? AND variant_ukuran = ?',
      whereArgs: [idProduk, warna, ukuran],
    );
    if (result.isNotEmpty) {
      return (result.first['qty'] as int?) ?? 0;
    }
    return 0;
  }

  Future<int> updateKeranjang(
      int id, Map<String, dynamic> row, BuildContext context) async {
    final db = await instance.database;

    try {
      return await db.update(
        'keranjang',
        row,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal mengupdate data produk",);
      return -1;
    }
  }

  Future<int> deleteKeranjang(int id, BuildContext context) async {
    final db = await instance.database;

    try {
      final result = await db.delete(
        'keranjang',
        where: 'id = ?',
        whereArgs: [id],
      );
      CustomSnackBar.show(context, sukses: true,
            teks: "Berhasil Menghapus Produk",);
      return result;
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Menghapus Produk",);
      return -1;
    }
  }

  Future<int> deleteKeranjangCheckout(BuildContext context) async {
    final db = await instance.database;

    try {
      final result = await db.delete(
        'keranjang',
        where: 'selected = 1',
      );
      return result;
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Menghapus Produk Chekout",);
      return -1;
    }
  }

  Future<int> deleteAllKeranjang(BuildContext context) async {
    final db = await instance.database;

    try {
      int result = await db.delete('keranjang');

      CustomSnackBar.show(context, sukses: true,
          teks: "Berhasil Menghapus Semua Produk",);

      return result;
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Menghapus Produk",);
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getUniqueStores(
      BuildContext context) async {
    final db = await instance.database;

    try {
      final result = await db
          .rawQuery('SELECT DISTINCT id_toko, nama_toko FROM keranjang');
      return result;
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Mengambil Nama Toko",);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKeranjangByIdToko(
      BuildContext context, int idToko) async {
    final db = await instance.database;

    try {
      final result = await db.query(
        'keranjang',
        where: 'id_toko = ?',
        whereArgs: [idToko],
      );
      return result;
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Menghapus Produk",);
      return [];
    }
  }

  Future<int> getTotalHargaKeranjang(BuildContext context) async {
    final db = await instance.database;

    try {
      final result = await db.rawQuery(
          'SELECT SUM(harga * qty) as total_harga FROM keranjang Where selected = 1');
      if (result.isNotEmpty && result.first['total_harga'] != null) {
        return (result.first['total_harga'] as num).toInt();
      } else {
        return 0;
      }
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Mendapatkan Total Harga",);
      return -1;
    }
  }

  Future<int> getCountSelectedProduk(BuildContext context) async {
    final db = await instance.database;

    try {
      final result = await db.rawQuery(
          'SELECT SUM(qty) as total_item FROM keranjang Where selected = 1');
      if (result.isNotEmpty && result.first['total_item'] != null) {
        return (result.first['total_item'] as num).toInt();
      } else {
        return 0;
      }
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Mendapatkan Selected Produk",);
      return -1;
    }
  }

  Future<int> getCountSelectedTokoCheckout(BuildContext context) async {
    final db = await instance.database;

    try {
      final result = await db.rawQuery(
          'SELECT COUNT(DISTINCT id_toko) as selected_toko FROM keranjang Where selected = 1');
      if (result.isNotEmpty && result.first['selected_toko'] != null) {
        return (result.first['selected_toko'] as num).toInt();
      } else {
        return 0;
      }
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Mendapatkan Total Toko yang Dipilih",);
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getSelectedProdukCheckout(
      BuildContext context) async {
    final db = await instance.database;

    try {
      final result =
          await db.rawQuery('SELECT * FROM keranjang Where selected = 1');
      return result;
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Mengambil Nama Toko",);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> listInputProdukCheckout(
      //mengambil produk yang nantinya dimasukkin ke database
      BuildContext context) async {
    final db = await instance.database;

    try {
      final result = await db.rawQuery(
          'SELECT id_produk, variant_warna as warna, variant_ukuran as ukuran, qty, harga*qty as subtotal FROM keranjang Where selected = 1');
      return result;
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Mengambil List Produk",);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllKeranjang(BuildContext context) async {
    final db = await instance.database;
    return await db.query('keranjang', orderBy: 'nama_toko ASC, id DESC');
  }
}
