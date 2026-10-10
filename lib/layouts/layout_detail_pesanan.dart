import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/models/riwayat_model.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/layouts/layout_pembayaran.dart';
import 'package:project_camp_sewa/layouts/layout_detail_product.dart';

class LayoutDetailPesanan extends StatelessWidget {
  final RiwayatModel data;

  const LayoutDetailPesanan({super.key, required this.data});

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

  void _showAllProductsSheet(BuildContext context, List<RiwayatItemModel> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
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
                "Semua Produk (${items.length})",
                style: AppColors.fontStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFEEEEEE), height: 1),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.to(() => const LayoutDetailProduct(), arguments: {
                          'idToko': 0, 
                          'idProduk': item.idProduk,
                          'namaProduk': item.namaProduk,
                          'fotoProduk': item.fotoProduk,
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF5F5F5),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: item.fotoProduk.startsWith('assets/')
                                  ? AssetImage(item.fotoProduk) as ImageProvider
                                  : NetworkImage(resolveFullUrl(item.fotoProduk, ApiEndpoints.authendpoints.getImageProduk)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.namaProduk,
                                style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2F2828)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Variasi: ${item.ukuran.isNotEmpty ? item.ukuran : '-'}, ${item.warna.isNotEmpty ? item.warna : '-'}",
                                style: AppColors.fontStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_formatRupiah(item.hargaSatuan)}  x${item.qty}",
                                    style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    _formatRupiah(item.subtotal),
                                    style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C4E40)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
    
    String totalHarga = data.totalPesanan;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text("Detail Pesanan", style: AppColors.fontStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2F2828))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2F2828), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              color: (data.isTerlambat || isSelesaiBelumLunas) ? const Color(0xFFFFEBEE) : (isBelumBayar ? const Color(0xFFFFF4E5) : (isSelesai ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD))),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        (data.isTerlambat || isSelesaiBelumLunas) ? Icons.warning_amber_rounded : (isBelumBayar ? Icons.pending_actions : (isSelesai ? Icons.check_circle : Icons.local_shipping)),
                        color: (data.isTerlambat || isSelesaiBelumLunas) ? Colors.red : (isBelumBayar ? const Color(0xFFFF9800) : (isSelesai ? const Color(0xFF4CAF50) : const Color(0xFF2196F3))),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data.isTerlambat ? "$displayStatus (Terlambat)" : displayStatus,
                        style: AppColors.fontStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: (data.isTerlambat || isSelesaiBelumLunas) ? Colors.red : (isBelumBayar ? const Color(0xFFFF9800) : (isSelesai ? const Color(0xFF4CAF50) : const Color(0xFF2196F3))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data.statusTransaksi.toLowerCase() == "berlangsung" && data.waktuDeadlinePengembalian != null)
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        try {
                          final deadline = DateTime.parse(data.waktuDeadlinePengembalian!);
                          final now = DateTime.now();
                          final diff = deadline.difference(now);
                          
                          if (diff.isNegative || data.isTerlambat) {
                            String dendaText = "";
                            if (data.nominalDenda != null) {
                              dendaText = "\nTotal Denda Sementara: ${_formatRupiah(data.nominalDenda.toString())}";
                            }
                            String durasiText = data.durasiTerlambat != null ? " (Telat ${data.durasiTerlambat})" : "";
                            
                            return Text(
                              "Waktu penyewaan telah habis. Berstatus Terlambat$durasiText.$dendaText",
                              style: AppColors.fontStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                            );
                          }
                          
                          final days = diff.inDays;
                          final hours = diff.inHours % 24;
                          final minutes = diff.inMinutes % 60;
                          final seconds = diff.inSeconds % 60;
                          
                          String countdown = "";
                          if (days > 0) countdown += "$days Hari ";
                          countdown += "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
                          
                          return Text(
                            "Masa penyewaan sedang berlangsung.\nSisa Waktu: $countdown",
                            style: AppColors.fontStyle(fontSize: 13, color: const Color(0xFF2F2828), fontWeight: FontWeight.w600),
                          );
                        } catch (e) {
                          return Text(
                            "Masa penyewaan sedang berlangsung.",
                            style: AppColors.fontStyle(fontSize: 13, color: const Color(0xFF2F2828).withValues(alpha: 0.7)),
                          );
                        }
                      }
                    )
                  else if (data.isTerlambat)
                    Text(
                      "Waktu penyewaan telah habis. Berstatus Terlambat${data.durasiTerlambat != null ? " (Telat ${data.durasiTerlambat})" : ""}.${data.nominalDenda != null ? "\nTotal Denda Sementara: ${_formatRupiah(data.nominalDenda.toString())}" : ""}",
                      style: AppColors.fontStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  else
                    Text(
                      isMenungguVerifikasi
                        ? "Pembayaran Anda sedang diverifikasi oleh admin."
                        : isBelumBayar 
                          ? "Segera lakukan pembayaran agar pesanan dapat diproses."
                          : data.statusTransaksi.toLowerCase() == "pengambilan"
                            ? "Pembayaran berhasil diverifikasi. Silakan ambil pesanan Anda."
                            : data.statusTransaksi.toLowerCase() == "berlangsung"
                                ? "Masa penyewaan sedang berlangsung."
                                : isSelesaiBelumLunas
                                    ? "Pesanan telah selesai, namun denda Anda belum dilunasi."
                                    : isSelesai
                                        ? "Pesanan telah selesai. Terima kasih!"
                                        : data.statusTransaksi.toLowerCase() == "dibatalkan"
                                            ? "Pesanan ini telah dibatalkan."
                                            : "Pesanan kamu sedang dalam proses.",
                      style: AppColors.fontStyle(fontSize: 13, color: const Color(0xFF2F2828).withValues(alpha: 0.7)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Store Info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: Color(0xFF2C4E40)),
                  const SizedBox(width: 12),
                  Text(
                    data.namaToko,
                    style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2F2828)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Kunjungi Toko",
                      style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2C4E40)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Product Details
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rincian Produk", style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (data.items.isNotEmpty) {
                        Get.to(() => const LayoutDetailProduct(), arguments: {
                          'idToko': 0, 
                          'idProduk': data.items.first.idProduk,
                          'namaProduk': data.items.first.namaProduk,
                          'fotoProduk': data.items.first.fotoProduk,
                        });
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF5F5F5),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: data.fotoProduk.startsWith('assets/')
                                  ? AssetImage(data.fotoProduk) as ImageProvider
                                  : NetworkImage(resolveFullUrl(data.fotoProduk, ApiEndpoints.authendpoints.getImageProduk)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.namaProduk,
                                style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2F2828)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Variasi: ${data.ukuran.isNotEmpty ? data.ukuran : '-'}, ${data.warna.isNotEmpty ? data.warna : '-'}",
                                style: AppColors.fontStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_formatRupiah(data.harga)}  x${data.qty}",
                                    style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    _formatRupiah((int.parse(data.harga) * int.parse(data.qty)).toString()),
                                    style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C4E40)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  if (int.tryParse(data.qtyProdukLain) != null && int.parse(data.qtyProdukLain) > 0) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFEEEEEE), height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            final otherItems = data.items.length > 1 ? data.items.skip(1).toList() : <RiwayatItemModel>[];
                            if (otherItems.isEmpty) {
                              return Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE8F5E9),
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "+${data.qtyProdukLain}",
                                        style: AppColors.fontStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2C4E40)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "produk lainnya",
                                    style: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                ],
                              );
                            }

                            int visibleCount = otherItems.length > 5 ? 5 : otherItems.length;
                            bool hasMore = otherItems.length > 5;
                            int moreCount = otherItems.length - 5;
                            int totalCircles = visibleCount + (hasMore ? 1 : 0);

                            return Row(
                              children: [
                                SizedBox(
                                  width: (totalCircles * 18.0) + 12.0,
                                  height: 30,
                                  child: Stack(
                                    children: List.generate(totalCircles, (index) {
                                      if (index < visibleCount) {
                                        final item = otherItems[index];
                                        return Positioned(
                                          left: index * 18.0,
                                          child: Container(
                                            width: 30,
                                            height: 30,
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
                                          left: index * 18.0,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFE8F5E9),
                                              border: Border.all(color: Colors.white, width: 1.5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "+$moreCount",
                                                style: AppColors.fontStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2C4E40)),
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
                                  style: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                              ],
                            );
                          }
                        ),
                        GestureDetector(
                          onTap: () {
                            if (data.items.length > 1) {
                              _showAllProductsSheet(context, data.items);
                            } else {
                              Get.snackbar(
                                "Informasi", 
                                "Detail produk lainnya belum tersedia dari server.",
                                backgroundColor: Colors.black87,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                              );
                            }
                          },
                          child: Text(
                            "Lihat",
                            style: AppColors.fontStyle(
                              fontSize: 13, 
                              fontWeight: FontWeight.bold, 
                              color: data.items.length > 1 ? const Color(0xFF2C4E40) : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Rental Duration
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(MdiIcons.calendarClock, size: 20, color: Color(0xFF757575)),
                          const SizedBox(width: 12),
                          Text("Durasi Sewa", style: AppColors.fontStyle(fontSize: 14, color: const Color(0xFF2F2828))),
                        ],
                      ),
                      Text("${data.hari} Hari", style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(MdiIcons.calendarRangeOutline, size: 20, color: Color(0xFF757575)),
                          const SizedBox(width: 12),
                          Text("Tanggal Sewa", style: AppColors.fontStyle(fontSize: 14, color: const Color(0xFF2F2828))),
                        ],
                      ),
                      Text(
                        "${_formatDate(data.tanggalMulai ?? '')} - ${_formatDate(data.tanggalSelesai ?? '')}",
                        style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF757575)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Payment Summary
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rincian Pembayaran", style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Metode Pembayaran", style: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade600)),
                      Text(data.metode == 'COD' ? "Bayar Ditempat" : "Transfer Bank", style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal Produk", style: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade600)),
                      Text(_formatRupiah((int.parse(data.harga) * int.parse(data.qty)).toString()), style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal Sewa (${data.hari} Hari)", style: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade600)),
                      Text(_formatRupiah(totalHarga), style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFEEEEEE), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Pembayaran", style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(_formatRupiah(totalHarga), style: AppColors.fontStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFEE2737))),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 120), // Bottom padding for FAB
          ],
        ),
      ),
      bottomSheet: (isBelumBayar && !isMenungguVerifikasi && data.metode?.toLowerCase() != 'cod')
        ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const LayoutPembayaran(), arguments: {
                      'id_penyewaan': data.id,
                      'id_toko': 0, 
                      'rekening_bank': data.rekeningBank, 
                      'total_pembayaran': totalHarga,
                      'bank': data.namaBank,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C4E40),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Bayar Sekarang",
                    style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        : isSelesai
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ]
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showRatingSheet(context, data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C4E40),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Beri Penilaian",
                        style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            : null,
    );
  }
}
