import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/components/card/item_variant.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/constants/database_helper.dart';
import 'package:project_camp_sewa/services/api_produk.dart';

class BottomSheetProduk extends StatefulWidget {
  final String? image;
  final String? namaProduk;
  final String? harga;
  final int? idProduk;
  final int? idToko;
  final String? namaToko;

  const BottomSheetProduk({
    super.key,
    this.image,
    this.namaProduk,
    this.harga,
    this.idProduk,
    this.idToko,
    this.namaToko,
  });

  @override
  State<BottomSheetProduk> createState() => _BottomSheetProdukState();
}

class _BottomSheetProdukState extends State<BottomSheetProduk> {
  ApiProduk apiProduk = Get.put(ApiProduk());
  String? pemberitahuan = "";
  String? selectedWarna;
  String? selectedUkuran;
  String? harga;
  String? stok;
  int qty = 1;

  int _qtyInCart = 0;
  int get _sisaStokTersedia => (int.tryParse(stok ?? '0') ?? 0) - _qtyInCart;

  Future<void> _updateState() async {
    if (selectedWarna != null && selectedUkuran != null) {
      var result = apiProduk.getStockAndPrice(selectedWarna!, selectedUkuran!);
      if (result != null) {
        final cartQty = await DatabaseHelper.instance.getVariantQtyInCart(
            widget.idProduk ?? 0, selectedWarna!, selectedUkuran!);
            
        if (!mounted) return;
        setState(() {
          _qtyInCart = cartQty;
          harga = result['harga'].toString();
          int stokInt = result['stok'];
          stok = stokInt.toString();
          pemberitahuan = "";
          
          if (stokInt < 1) {
            qty = 1;
            pemberitahuan = "*Stok varian ini habis";
          } else if (_sisaStokTersedia < 1) {
            qty = 1;
            pemberitahuan = "*Sisa stok telah mencapai batas maksimal alokasi keranjang";
          } else if (qty > _sisaStokTersedia) {
            qty = _sisaStokTersedia;
          }
        });
      }
    }
  }

  String formatCurrency(String numberString) {
    final number = int.parse(numberString);
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  }

  Widget _buildImage() {
    final img = widget.image ?? '';
    if (img.isEmpty) {
      return Container(color: Colors.grey.shade200, child: Icon(Icons.image_not_supported_rounded, color: Colors.grey.shade400));
    }
    if (img.startsWith('assets/')) {
      return Image.asset(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey));
    }
    final url = img.startsWith('http') ? img : ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.getImageProduk + img;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildImage(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.namaProduk ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2F2828),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Rp ${harga != null ? formatCurrency(harga!) : formatCurrency(widget.harga ?? '0')}/hari",
                          style: AppColors.fontStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C4E40),
                          ),
                        ),
                        if (stok != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C4E40).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Sisa Stok: $stok",
                              style: AppColors.fontStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C4E40),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Warna",
                style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2F2828)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: Obx(() {
                List<String> listWarna = apiProduk.colors;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return ItemVariant(
                      item: listWarna[index],
                      selected: selectedWarna == listWarna[index],
                      aksi: () {
                        apiProduk.updateAllUniqueSizes(color: listWarna[index]);
                        setState(() {
                          selectedWarna = listWarna[index];
                        });
                        _updateState();
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemCount: listWarna.length,
                );
              }),
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Ukuran",
                style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2F2828)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: Obx(() {
                List<String> listUkuran = apiProduk.uniqueSizes;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => ItemVariant(
                    item: listUkuran[index],
                    selected: selectedUkuran == listUkuran[index],
                    aksi: () {
                      setState(() {
                        selectedUkuran = listUkuran[index];
                      });
                      _updateState();
                    },
                  ),
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemCount: listUkuran.length,
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (_qtyInCart > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFED6723).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFED6723).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_cart_checkout_rounded, size: 16, color: Color(0xFFED6723)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Varian ini sudah ada $_qtyInCart item di keranjang",
                              style: AppColors.fontStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFED6723),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  if (pemberitahuan != null && pemberitahuan!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEE2737).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFEE2737)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pemberitahuan!,
                              style: AppColors.fontStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEE2737),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jumlah",
                        style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2F2828)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(MdiIcons.minus, size: 18, color: qty > 1 ? const Color(0xFF2F2828) : Colors.grey.shade400),
                              onPressed: () {
                                setState(() {
                                  if (qty > 1) {
                                    qty--;
                                    pemberitahuan = "";
                                  }
                                });
                              },
                            ),
                            SizedBox(
                              width: 32,
                              child: Center(
                                child: Text(
                                  qty.toString(),
                                  style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add, size: 18, color: Color(0xFF2F2828)),
                              onPressed: () {
                                setState(() {
                                  if (stok != null) {
                                    if (qty < _sisaStokTersedia) {
                                      qty++;
                                      pemberitahuan = "";
                                    } else {
                                      pemberitahuan = "*Sisa stok telah mencapai batas maksimal alokasi keranjang";
                                    }
                                  } else {
                                    pemberitahuan = "*Pilih Warna dan Ukuran Terlebih Dahulu";
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Material(
                color: const Color(0xFF2C4E40),
                borderRadius: BorderRadius.circular(100),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () async {
                    if (selectedWarna != null && selectedUkuran != null) {
                      if (_sisaStokTersedia < 1) {
                        setState(() {
                          pemberitahuan = "*Sisa stok telah mencapai batas maksimal alokasi keranjang";
                        });
                        return;
                      }

                      Map<String, dynamic> newRow = {
                        'id_toko': widget.idToko,
                        'id_produk': widget.idProduk,
                        'nama_toko': widget.namaToko,
                        'foto_produk': widget.image,
                        'nama_produk': widget.namaProduk,
                        'variant_warna': selectedWarna,
                        'variant_ukuran': selectedUkuran,
                        'harga': harga,
                        'qty': qty,
                        'selected': 0
                      };
                      await DatabaseHelper.instance.insertKeranjang(newRow, context);
                      Get.back();
                    } else {
                      setState(() {
                        pemberitahuan = "*Pilih Warna dan Ukuran Terlebih Dahulu";
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      "Tambahkan ke Keranjang",
                      style: AppColors.fontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
