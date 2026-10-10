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
const _red = Color(0xFFEE2737);

/// Warna latar halaman keranjang yang disarankan.
/// Pakai di Scaffold.backgroundColor supaya card terlihat terpisah dari latar.
const kKeranjangBg = Color(0xFFF2F5F3);

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
        },
      ),
    ),
  );
  return confirmed;
}

// ═══════════════════════════════════════════════════════════════════════════
//  GROUP TOKO — satu card putih berisi header toko + daftar item di dalamnya
// ═══════════════════════════════════════════════════════════════════════════

/// Pembungkus per-toko. Header toko punya latar hijau tipis, dipisah garis
/// dari item, dan seluruh grup berada di dalam satu card bersudut membulat
/// dengan bayangan sehingga tidak menyatu dengan latar halaman.
///
/// Contoh pemakaian:
/// ```dart
/// TokoGroupCard(
///   namaToko: toko.namaToko,
///   selected: semuaTerpilih,
///   onToggle: () => ...,
///   children: items
///       .map((e) => ItemKeranjangCard(item: e, grouped: true))
///       .toList(),
/// )
/// ```
class TokoGroupCard extends StatelessWidget {
  final String namaToko;
  final bool selected;
  final VoidCallback onToggle;
  final List<Widget> children;

  const TokoGroupCard({
    super.key,
    required this.namaToko,
    required this.selected,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Sisipkan divider tipis antar item
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade200,
        ));
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 7, 14, 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header toko ──
            Container(
              color: _green.withValues(alpha: 0.06),
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
              child: Row(
                children: [
                  AppCheck(value: selected, onTap: onToggle),
                  const SizedBox(width: 2),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: Colors.white, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      namaToko,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppColors.fontStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${children.length} produk',
                      style: AppColors.fontStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1, thickness: 1, color: _green.withValues(alpha: 0.10)),
            ...rows,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ITEM KERANJANG
// ═══════════════════════════════════════════════════════════════════════════

/// [grouped] = true  → dipakai di dalam [TokoGroupCard] (tanpa card sendiri).
/// [grouped] = false → tampil sebagai card mandiri bersudut membulat.
class ItemKeranjangCard extends StatelessWidget {
  final KeranjangModel item;
  final bool grouped;
  const ItemKeranjangCard(
      {super.key, required this.item, this.grouped = false});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KeranjangController>();

    final dismissible = Dismissible(
      key: ValueKey('keranjang_${item.id}'),
      direction: DismissDirection.endToStart,
      // Konfirmasi dulu; penghapusan dilakukan lewat controller sehingga
      // item hilang dari list secara reaktif.
      confirmDismiss: (_) async {
        final ok = await konfirmasiHapusProduk(context, item);
        if (ok) c.hapusItem(item.id!);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: _red,
        child: const Icon(MdiIcons.trashCanOutline, color: Colors.white),
      ),
      child: _buildContent(context, c),
    );

    if (grouped) return dismissible;

    // Card mandiri
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 7, 14, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isSelected
              ? _green.withValues(alpha: 0.35)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: dismissible,
      ),
    );
  }

  Widget _buildContent(BuildContext context, KeranjangController c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: item.isSelected
          ? Color.alphaBlend(_green.withValues(alpha: 0.04), Colors.white)
          : Colors.white,
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 82,
                height: 82,
                color: Colors.grey.shade100,
                child: item.fotoProduk.startsWith('assets/')
                    ? Image.asset(
                        item.fotoProduk,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400),
                      )
                    : Image.network(
                        resolveFullUrl(item.fotoProduk,
                            ApiEndpoints.authendpoints.getImageProduk),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400),
                      ),
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
                    const SizedBox(width: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final ok = await konfirmasiHapusProduk(context, item);
                        if (ok) c.hapusItem(item.id!);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _red.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(MdiIcons.trashCanOutline,
                            color: _red, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
        color: _green.withValues(alpha: 0.07),
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
