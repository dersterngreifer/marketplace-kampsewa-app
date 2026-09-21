import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/components/card/keranjang_card.dart';
import 'package:project_camp_sewa/services/controller_keranjang.dart';

const _green = Color(0xFF2C4E40);

class GroupProdukKeranjang extends StatelessWidget {
  final String namaToko;
  final int idToko;
  const GroupProdukKeranjang(
      {super.key, required this.namaToko, required this.idToko});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KeranjangController>();

    return Obx(() {
      final list = c.itemsOf(idToko);
      if (list.isEmpty) return const SizedBox.shrink();

      final allSelected = list.every((e) => e.isSelected);
      final selected = list.where((e) => e.isSelected).toList();
      final subtotal = selected.fold<int>(0, (s, e) => s + e.subtotal);

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header toko
            Container(
              color: _green.withValues(alpha: 0.05),
              padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
              child: Row(
                children: [
                  AppCheck(
                    value: allSelected,
                    onTap: () => c.toggleStore(idToko, !allSelected),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        size: 16, color: Colors.white),
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
                        color: _green,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${list.length} produk',
                      style: AppColors.fontStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Item-item toko
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0)
                Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              ItemKeranjangCard(item: list[i]),
            ],

            // Subtotal toko (muncul kalau ada yang dipilih)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: selected.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      width: double.infinity,
                      color: Colors.grey.shade50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Text(
                            'Subtotal toko',
                            style: AppColors.fontStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Rp ${rupiah(subtotal)}',
                            style: AppColors.fontStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _green,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
