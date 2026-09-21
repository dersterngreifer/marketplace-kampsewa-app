import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog2.dart';
import 'package:project_camp_sewa/models/keranjang_model.dart'; // sesuaikan path
import 'package:project_camp_sewa/services/controller_keranjang.dart';

const _green = Color(0xFF2C4E40);
const _dark = Color(0xFF2F2828);

/// Checkbox bulat modern, dipakai di card item, header toko, dan footer.
class AppCheck extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  const AppCheck({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? _green : Colors.transparent,
            border: Border.all(
              color: value ? _green : Colors.grey.shade400,
              width: 1.6,
            ),
          ),
          child: value
              ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

/// Dialog konfirmasi hapus (memakai CustomAlertDialog2 milikmu).
/// Mengembalikan true jika pengguna menekan tombol hapus.
Future<bool> konfirmasiHapusProduk(
    BuildContext context, KeranjangModel item) async {
  bool confirmed = false;
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.transparent,
      content: CustomAlertDialog2(
        teks: 'Yakin Ingin Menghapus Produk ${item.namaProduk} ?',
        hapus: () {
          confirmed = true;
          Get.back();
        },
      ),
    ),
  );
  return confirmed;
}

class ItemKeranjangCard extends StatelessWidget {
  final KeranjangModel item;
  const ItemKeranjangCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KeranjangController>();

    return Dismissible(
      key: ValueKey('keranjang_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => konfirmasiHapusProduk(context, item),
      onDismissed: (_) => c.hapusItem(item.id!),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFFEE2737),
        child: const Icon(MdiIcons.trashCanOutline, color: Colors.white),
      ),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(8, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppCheck(
              value: item.isSelected,
              onTap: () => c.toggleItem(item.id!, !item.isSelected),
            ),
            const SizedBox(width: 4),
            // Foto
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 84,
                height: 84,
                color: Colors.grey.shade100,
                child: item.fotoProduk.startsWith('assets/')
                  ? Image.asset(
                      item.fotoProduk,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                    )
                  : Image.network(
                      item.fotoProduk.startsWith('http')
                          ? item.fotoProduk
                          : ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.getImageProduk + item.fotoProduk,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.namaProduk,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final ok = await konfirmasiHapusProduk(context, item);
                          if (ok) c.hapusItem(item.id!);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6, bottom: 4),
                          child: Icon(MdiIcons.trashCanOutline,
                              color: Color(0xFFEE2737), size: 19),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.variantWarna} • ${item.variantUkuran}',
                      style: AppColors.fontStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rp ${rupiah(item.subtotal)}',
                              style: AppColors.fontStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _green,
                              ),
                            ),
                            Text(
                              'Rp ${rupiah(item.harga)} /hari',
                              style: AppColors.fontStyle(
                                fontSize: 10.5,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _QtyStepper(
                        qty: item.qty,
                        onMinus: () => c.changeQty(item.id!, -1),
                        onPlus: () => c.changeQty(item.id!, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _QtyStepper(
      {required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    final canMinus = qty > 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundBtn(
            icon: Icons.remove_rounded,
            onTap: canMinus ? onMinus : null,
            filled: false,
          ),
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                '$qty',
                style: AppColors.fontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),
            ),
          ),
          _RoundBtn(icon: Icons.add_rounded, onTap: onPlus, filled: true),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  const _RoundBtn(
      {required this.icon, required this.onTap, required this.filled});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? _green : Colors.white,
        ),
        child: Icon(
          icon,
          size: 17,
          color:
              filled ? Colors.white : (enabled ? _dark : Colors.grey.shade400),
        ),
      ),
    );
  }
}

