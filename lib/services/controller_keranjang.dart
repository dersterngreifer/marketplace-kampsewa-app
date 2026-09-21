import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/constants/database_helper.dart';
import 'package:project_camp_sewa/models/keranjang_model.dart'; // sesuaikan path

String rupiah(int n) => NumberFormat.decimalPattern('id').format(n);

class KeranjangController extends GetxController {
  /// Sumber data reaktif untuk UI keranjang.
  final items = <KeranjangModel>[].obs;
  final isLoading = false.obs;

  // ── Field lama (tetap dipakai layout lain) ──
  var selectedProdukCheckout = <Map<String, dynamic>>[].obs;
  final RxInt totalHargaKeranjang = 0.obs;
  final RxInt totalItemKeranjang = 0.obs;

  /// Jumlah toko berbeda pada item yang dipilih.
  /// Pembayaran hanya bisa 1 toko per transaksi.
  final RxInt totalSelectedTokoCheckout = 0.obs;

  // ── Getter turunan ──
  List<KeranjangModel> get selectedItems =>
      items.where((e) => e.isSelected).toList();

  bool get allSelected => items.isNotEmpty && items.every((e) => e.isSelected);

  List<Map<String, dynamic>> get uniqueStores {
    final seen = <int>{};
    final out = <Map<String, dynamic>>[];
    for (final e in items) {
      if (seen.add(e.idToko)) {
        out.add({'id_toko': e.idToko, 'nama_toko': e.namaToko});
      }
    }
    return out;
  }

  List<KeranjangModel> itemsOf(int idToko) =>
      items.where((e) => e.idToko == idToko).toList();

  /// Ringkasan toko yang sedang dipilih (untuk bottom sheet "Bayar per toko").
  List<Map<String, dynamic>> get selectedStoreSummary {
    final map = <int, Map<String, dynamic>>{};
    for (final e in selectedItems) {
      final row = map.putIfAbsent(
        e.idToko,
        () => {
          'id_toko': e.idToko,
          'nama_toko': e.namaToko,
          'jumlah': 0,
          'subtotal': 0,
        },
      );
      row['jumlah'] = (row['jumlah'] as int) + e.qty;
      row['subtotal'] = (row['subtotal'] as int) + e.subtotal;
    }
    return map.values.toList();
  }

  Future<void> loadKeranjang(BuildContext context) async {
    isLoading.value = true;
    try {
      final stores = await DatabaseHelper.instance.getUniqueStores(context);
      final all = <KeranjangModel>[];
      for (final s in stores) {
        if (!context.mounted) return;
        final rows = await DatabaseHelper.instance
            .getKeranjangByIdToko(context, s['id_toko'] as int);
        all.addAll(rows.map(KeranjangModel.fromDb));
      }
      items.assignAll(all);
    } finally {
      isLoading.value = false;
      _recalculate();
    }
  }

  Future<void> hapusItem(int id) async {
    items.removeWhere((e) => e.id == id);
    _recalculate();
    final ctx = Get.context;
    if (ctx == null) return;
    final result = await DatabaseHelper.instance.deleteKeranjang(id, ctx);
    if (!ctx.mounted) return;
    if (result == -1) await loadKeranjang(ctx); // gagal -> kembalikan dari DB
  }

  Future<void> _persist(int id, Map<String, dynamic> row) async {
    final ctx = Get.context;
    if (ctx == null) return;
    final result = await DatabaseHelper.instance.updateKeranjang(id, row, ctx);
    if (!ctx.mounted) return;
    if (result == -1) await loadKeranjang(ctx); // gagal -> rollback UI
  }

  // ── Aksi (optimistic: UI berubah dulu, DB menyusul) ──
  void toggleItem(int id, bool value) {
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    items[i] = items[i].copyWith(selected: value ? 1 : 0);
    _recalculate();
    _persist(id, {'selected': value ? 1 : 0});
  }

  void toggleStore(int idToko, bool value) {
    for (var i = 0; i < items.length; i++) {
      if (items[i].idToko == idToko) {
        items[i] = items[i].copyWith(selected: value ? 1 : 0);
        _persist(items[i].id!, {'selected': value ? 1 : 0});
      }
    }
    _recalculate();
  }

  void toggleAll(bool value) {
    for (var i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(selected: value ? 1 : 0);
      _persist(items[i].id!, {'selected': value ? 1 : 0});
    }
    _recalculate();
  }

  void changeQty(int id, int delta) {
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final newQty = items[i].qty + delta;
    if (newQty < 1) return;
    items[i] = items[i].copyWith(qty: newQty);
    _recalculate();
    _persist(id, {'qty': newQty});
  }

  // ── Checkout per toko ──

  /// Hanya item milik [idToko] yang ditandai selected (di UI dan di DB),
  /// supaya LayoutCheckout lama (yang membaca dari DB) hanya melihat 1 toko.
  /// Mengembalikan id item yang tadinya terpilih, untuk dipulihkan nanti.
  Future<Set<int>> selectOnlyStore(int idToko, BuildContext context) async {
    final previouslySelected = selectedItems.map((e) => e.id!).toSet();

    for (var i = 0; i < items.length; i++) {
      final shouldSelect = items[i].idToko == idToko;
      if (items[i].isSelected != shouldSelect) {
        items[i] = items[i].copyWith(selected: shouldSelect ? 1 : 0);
        if (!context.mounted) return previouslySelected;
        await DatabaseHelper.instance.updateKeranjang(
            items[i].id!, {'selected': shouldSelect ? 1 : 0}, context);
      }
    }
    _recalculate();
    return previouslySelected;
  }

  /// Dipanggil setelah kembali dari checkout: muat ulang keranjang lalu
  /// pulihkan pilihan toko lain yang masih ada di keranjang.
  Future<void> restoreSelection(Set<int> ids, BuildContext context) async {
    await loadKeranjang(context);
    for (var i = 0; i < items.length; i++) {
      final shouldSelect = ids.contains(items[i].id);
      if (items[i].isSelected != shouldSelect) {
        items[i] = items[i].copyWith(selected: shouldSelect ? 1 : 0);
        if (!context.mounted) return;
        await DatabaseHelper.instance.updateKeranjang(
            items[i].id!, {'selected': shouldSelect ? 1 : 0}, context);
      }
    }
    _recalculate();
  }

  // ── Kompatibilitas dengan kode lama ──
  Future<void> getSelectedProdukCheckout(BuildContext context) async {
    final produkCheckout =
        await DatabaseHelper.instance.getSelectedProdukCheckout(context);
    selectedProdukCheckout.assignAll(produkCheckout);
  }

  Future<void> getUniqueStores(BuildContext context) => loadKeranjang(context);
  void updateTotalHargaKeranjang(BuildContext context) => _recalculate();
  void updateTotalItemKeranjang(BuildContext context) => _recalculate();
  Future<void> getSelectedTokoCheckout(BuildContext context) async =>
      _recalculate();

  // ── Internal ──
    Future<void> deleteAllKeranjang(BuildContext context) async {
    items.clear();
    _recalculate();
    await DatabaseHelper.instance.deleteAllKeranjang(context);
    if (!context.mounted) return;
    await loadKeranjang(context);
  }

  void _recalculate() {
    final sel = selectedItems;
    totalItemKeranjang.value = sel.fold(0, (s, e) => s + e.qty);
    totalHargaKeranjang.value = sel.fold(0, (s, e) => s + e.subtotal);
    totalSelectedTokoCheckout.value = sel.map((e) => e.idToko).toSet().length;
  }
}

