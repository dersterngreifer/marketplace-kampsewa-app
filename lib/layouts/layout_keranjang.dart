// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/services/api_data_user.dart'
    as import_api_data_user;
import 'package:project_camp_sewa/layouts/layout_instruksi_kyc.dart'
    as import_instruksi_kyc;
import 'package:project_camp_sewa/components/card/group_produk_keranjang.dart';
import 'package:project_camp_sewa/components/card/keranjang_card.dart'
    show AppCheck;
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog2.dart';
import 'package:project_camp_sewa/layouts/layout_checkout.dart';
import 'package:project_camp_sewa/services/controller_keranjang.dart';

const _green = Color(0xFF2C4E40);

class LayoutKeranjang extends StatefulWidget {
  const LayoutKeranjang({super.key});

  @override
  State<LayoutKeranjang> createState() => _LayoutKeranjangState();
}

class _LayoutKeranjangState extends State<LayoutKeranjang> {
  final KeranjangController c = Get.put(KeranjangController());

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    c.loadKeranjang(context);
  }

  Future<void> _checkout() async {
    final apiDataUser = Get.find<import_api_data_user.ApiDataUser>();
    final user = apiDataUser.dataUser.value;
    final needsKYC = user != null &&
        user.type == 0 &&
        (user.nomorIdentitas == null || user.nomorIdentitas.toString().isEmpty || 
         user.fotoIdentitas == null || user.fotoIdentitas.toString().isEmpty);

    if (needsKYC) {
      CustomSnackBar.show(context, sukses: false,
            title: 'Perhatian',
            teks:
                'Harap lengkapi identitas (KTP) Anda sebelum melakukan penyewaan barang.',);
      Get.to(() => const import_instruksi_kyc.LayoutInstruksiKYC());
      return;
    }

    final stores = c.selectedStoreSummary;

    if (stores.length == 1) {
      await _goCheckout(stores.first['id_toko'] as int);
    } else {
      _showStorePicker(stores);
    }
  }

  /// Set selected hanya untuk 1 toko -> checkout -> pulihkan pilihan lain.
  Future<void> _goCheckout(int idToko) async {
    final previous = await c.selectOnlyStore(idToko, context);
    await Get.to(() => const LayoutCheckout());
    if (!mounted) return;
    await c.restoreSelection(previous, context);
  }

  void _showStorePicker(List<Map<String, dynamic>> stores) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Bayar per toko',
                  style: AppColors.fontStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _green)),
              const SizedBox(height: 4),
              Text(
                'Kamu memilih produk dari ${stores.length} toko. '
                'Pembayaran dilakukan satu toko per transaksi, pilih toko yang dibayar dulu. '
                'Pilihan toko lainnya tetap tersimpan.',
                style: AppColors.fontStyle(
                    fontSize: 12.5, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 16),
              for (final s in stores) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.storefront_rounded,
                            size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['nama_toko'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppColors.fontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2F2828))),
                            Text(
                              '${s['jumlah']} item Ã¢â‚¬Â¢ Rp ${rupiah(s['subtotal'] as int)}',
                              style: AppColors.fontStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _goCheckout(s['id_toko'] as int);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Bayar',
                              style: AppColors.fontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value && c.items.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: _green));
                }
                final stores = c.uniqueStores;
                if (stores.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  color: _green,
                  onRefresh: () async {
                    final apiDataUser = Get.find<import_api_data_user.ApiDataUser>();
                    await apiDataUser.getDataUser(context);
                    await c.loadKeranjang(context);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => GroupProdukKeranjang(
                      key: ValueKey(stores[i]['id_toko']),
                      namaToko: stores[i]['nama_toko'],
                      idToko: stores[i]['id_toko'],
                    ),
                  ),
                );
              }),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _green, size: 18),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keranjang',
                  style: AppColors.fontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _green,
                    letterSpacing: -0.3,
                  ),
                ),
                Obx(() => Text(
                      '${c.items.length} produk dari ${c.uniqueStores.length} toko',
                      style: AppColors.fontStyle(
                          fontSize: 12, color: Colors.black45),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Obx(() {
      final totalItem = c.totalItemKeranjang.value;
      final totalHarga = c.totalHargaKeranjang.value;
      final canCheckout = totalItem > 0;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pilih semua
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppCheck(
                  value: c.allSelected,
                  onTap: () => c.toggleAll(!c.allSelected),
                ),
                Text('Semua',
                    style: AppColors.fontStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              ],
            ),
            const SizedBox(width: 10),
            // Total
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total ($totalItem item)',
                    style: AppColors.fontStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.3), end: Offset.zero)
                            .animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text.rich(
                      key: ValueKey(totalHarga),
                      TextSpan(children: [
                        TextSpan(
                          text: 'Rp ${rupiah(totalHarga)}',
                          style: AppColors.fontStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _green,
                          ),
                        ),
                        TextSpan(
                          text: ' /hari',
                          style: AppColors.fontStyle(
                              fontSize: 11, color: Colors.black45),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Tombol checkout
            GestureDetector(
              onTap: canCheckout ? _checkout : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: canCheckout ? _green : Colors.grey.shade300,
                  boxShadow: canCheckout
                      ? [
                          BoxShadow(
                            color: _green.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    canCheckout ? 'Checkout ($totalItem)' : 'Checkout',
                    style: AppColors.fontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: canCheckout ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (c.items.isEmpty) return const SizedBox();
              return IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomAlertDialog2(
                        title: "Hapus Semua",
                        teks: "Apakah Anda yakin ingin mengosongkan keranjang belanja?",
                        hapus: () => c.deleteAllKeranjang(context),
                      );
                    },
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEE2737).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_sweep_rounded,
                      color: Color(0xFFEE2737), size: 20),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 50, color: _green),
          ),
          const SizedBox(height: 20),
          Text('Keranjang Masih Kosong',
              style: AppColors.fontStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk ke keranjang\nuntuk mulai berbelanja',
            textAlign: TextAlign.center,
            style: AppColors.fontStyle(
                fontSize: 13, color: Colors.black45, height: 1.5),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _green,
              ),
              child: Text('Cari Produk',
                  style: AppColors.fontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}





