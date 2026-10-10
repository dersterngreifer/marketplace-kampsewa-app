import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/models/riwayat_model.dart';
import 'package:project_camp_sewa/layouts/layout_pembayaran.dart';
import 'package:project_camp_sewa/layouts/layout_detail_pesanan.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';

class RiwayatCard extends StatelessWidget {
  final RiwayatModel data;

  const RiwayatCard({super.key, required this.data});

  String _formatRupiah(String numberString) {
    try {
      final number = int.parse(numberString);
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
    } catch (e) {
      return "Rp $numberString";
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "-";
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd MMM yy', 'id_ID').format(parsed);
    } catch (e) {
      return dateStr;
    }
  }

  void _showRatingSheet(BuildContext context, RiwayatModel data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Nilai Pesanan",
                style: AppColors.fontStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Bagaimana pengalaman kamu menyewa ${data.namaProduk}?",
                style: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.star_border_rounded, size: 40, color: Colors.amber),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Tulis ulasan pengalaman menyewa barang ini...",
                    hintStyle: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2C4E40)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.snackbar(
                        "Terima Kasih", 
                        "Penilaian kamu berhasil dikirimkan.",
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C4E40),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      "Kirim Penilaian",
                      style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isBelumBayar = data.statusTransaksi.toLowerCase() == "belum bayar";
    bool isSelesaiBelumLunas = data.statusTransaksi.toLowerCase() == "selesai (belum lunas)";
    bool isSelesai = data.statusTransaksi.toLowerCase() == "selesai" || isSelesaiBelumLunas;
    bool isMenungguVerifikasi = isBelumBayar && data.statusPembayaran?.toLowerCase() == 'menunggu verifikasi';
    
    String displayStatus = isMenungguVerifikasi ? "Menunggu Verifikasi" : data.statusTransaksi;
    
    String finalTotalPesanan = data.totalPesanan;

    return GestureDetector(
      onTap: () {
        Get.to(() => LayoutDetailPesanan(data: data));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C4E40).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Store Name and Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 20, color: Color(0xFF2C4E40)),
                    const SizedBox(width: 8),
                    Text(
                      data.namaToko,
                      style: AppColors.fontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F2828),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (data.isTerlambat || isSelesaiBelumLunas)
                        ? const Color(0xFFFFEBEE)
                        : (isBelumBayar 
                            ? const Color(0xFFFFF4E5) 
                            : (isSelesai ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD))),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.isTerlambat ? "$displayStatus (Terlambat)" : displayStatus,
                    style: AppColors.fontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: (data.isTerlambat || isSelesaiBelumLunas)
                          ? Colors.red
                          : (isBelumBayar 
                              ? const Color(0xFFFF9800) 
                              : (isSelesai ? const Color(0xFF4CAF50) : const Color(0xFF2196F3))),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body: Product Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF5F5F5),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: data.fotoProduk.startsWith('assets/')
                          ? AssetImage(data.fotoProduk) as ImageProvider
                          : NetworkImage(resolveFullUrl(data.fotoProduk, ApiEndpoints.authendpoints.getImageProduk)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.namaProduk,
                        style: AppColors.fontStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F2828),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${data.ukuran != '' ? data.ukuran : '-'} / ${data.warna != '' ? data.warna : '-'}",
                              style: AppColors.fontStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF757575)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "x${data.qty}",
                            style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF757575)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatRupiah(data.harga),
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F2828),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer Info (Duration, Extra Products)
          if (data.items.length > 1 || (int.tryParse(data.qtyProdukLain) != null && int.parse(data.qtyProdukLain) > 0))
            Builder(
              builder: (context) {
                final otherItems = data.items.length > 1 ? data.items.skip(1).toList() : <RiwayatItemModel>[];
                
                // Fallback jika API belum mengembalikan items array utuh namun qtyProdukLain > 0
                if (otherItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F5E9),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              "+${data.qtyProdukLain}",
                              style: AppColors.fontStyle(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF2C4E40)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "produk lainnya",
                          style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF757575)),
                        ),
                      ],
                    ),
                  );
                }

                int visibleCount = otherItems.length > 5 ? 5 : otherItems.length;
                bool hasMore = otherItems.length > 5;
                int moreCount = otherItems.length - 5;
                int totalCircles = visibleCount + (hasMore ? 1 : 0);

                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: (totalCircles * 14.0) + 12.0,
                        height: 24,
                        child: Stack(
                          children: List.generate(totalCircles, (index) {
                            if (index < visibleCount) {
                              final item = otherItems[index];
                              return Positioned(
                                left: index * 14.0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: item.fotoProduk.startsWith('assets/')
                                          ? AssetImage(item.fotoProduk) as ImageProvider
                                          : NetworkImage(resolveFullUrl(item.fotoProduk, ApiEndpoints.authendpoints.getImageProduk)),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Positioned(
                                left: index * 14.0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE8F5E9),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "+$moreCount",
                                      style: AppColors.fontStyle(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF2C4E40)),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "produk lainnya",
                        style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF757575)),
                      ),
                    ],
                  ),
                );
              }
            ),
            
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(MdiIcons.clockOutline, size: 16, color: Color(0xFF757575)),
                        const SizedBox(width: 6),
                        Text(
                          "Sewa ${data.hari} Hari",
                          style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF757575)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(MdiIcons.calendarRangeOutline, size: 14, color: Color(0xFF9E9E9E)),
                        const SizedBox(width: 6),
                        Text(
                          "${_formatDate(data.tanggalMulai ?? '')} - ${_formatDate(data.tanggalSelesai ?? '')}",
                          style: AppColors.fontStyle(fontSize: 11, color: const Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total Belanja",
                      style: AppColors.fontStyle(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF757575)),
                    ),
                    Text(
                      _formatRupiah(finalTotalPesanan),
                      style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF2C4E40)),
                    ),
                    if (data.isTerlambat && data.nominalDenda != null)
                      Text(
                        "+ Denda berjalan ${_formatRupiah(data.nominalDenda.toString())}",
                        style: AppColors.fontStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
                      )
                    else if (data.statusDenda == 'belum_dibayar' && data.nominalDendaTersimpan != null)
                      Text(
                        "Denda belum lunas: ${_formatRupiah(data.nominalDendaTersimpan.toString())}",
                        style: AppColors.fontStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (isSelesai && data.items.isNotEmpty) {
                        Get.to(() => const LayoutDetailProduct(), arguments: {
                          'idToko': 0, // Fallback if id_toko isn't directly available in RiwayatModel
                          'idProduk': data.items.first.idProduk,
                          'namaProduk': data.items.first.namaProduk,
                          'fotoProduk': data.items.first.fotoProduk,
                        });
                      } else {
                        Get.to(() => LayoutDetailPesanan(data: data));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2C4E40)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isSelesai ? "Sewa Lagi" : "Detail Pesanan",
                      style: AppColors.fontStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C4E40),
                      ),
                    ),
                  ),
                ),
                if (isSelesai) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showRatingSheet(context, data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C4E40),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Beri Penilaian",
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else if (isBelumBayar && !isMenungguVerifikasi && (data.metode?.toLowerCase() != 'cod')) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const LayoutPembayaran(), arguments: {
                          'id_penyewaan': data.id,
                          'id_toko': 0, 
                          'rekening_bank': data.rekeningBank, 
                          'total_pembayaran': finalTotalPesanan,
                          'bank': data.namaBank,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C4E40),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Bayar Sekarang",
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    ));
  }
}
