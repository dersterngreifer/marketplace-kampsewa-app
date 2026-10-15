import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:project_camp_sewa/components/card/item_variant.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/constants/database_helper.dart';
import 'package:project_camp_sewa/services/api_produk.dart';
import 'package:project_camp_sewa/theme_colors.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    if (widget.idProduk != null) {
      // Bersihkan state varian sebelumnya agar data produk lain tidak tampil
      apiProduk.groupedByColor.clear();
      apiProduk.uniqueSizes.clear();
      apiProduk.colors.clear();
      selectedWarna = null;
      selectedUkuran = null;

      // Panggil endpoint varian keranjang produk yang benar dan cepat
      await apiProduk.getProdukBottomSheet(
          context, null, null, widget.idProduk.toString());

      if (apiProduk.colors.isNotEmpty) {
        selectedWarna = apiProduk.colors.first;
        apiProduk.updateAllUniqueSizes(color: selectedWarna);
        if (apiProduk.uniqueSizes.isNotEmpty) {
          selectedUkuran = apiProduk.uniqueSizes.first;
        }
      }
      await _updateState();
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateState() async {
    if (selectedWarna != null && selectedUkuran != null) {
      var result = apiProduk.getStockAndPrice(selectedWarna!, selectedUkuran!);
      if (result != null) {
        final cartQty = await DatabaseHelper.instance.getVariantQtyInCart(
            widget.idProduk ?? 0, selectedWarna!, selectedUkuran!);

        if (!mounted) return;
        setState(() {
          _qtyInCart = cartQty;
          harga = result['harga']?.toString() ?? widget.harga ?? '0';
          int stokInt = result['stok'] is int
              ? result['stok']
              : (int.tryParse(result['stok']?.toString() ?? '0') ?? 0);
          stok = stokInt.toString();
          pemberitahuan = "";

          if (stokInt < 1) {
            qty = 1;
            pemberitahuan = "*Stok varian ini habis";
          } else if (_sisaStokTersedia < 1) {
            qty = 1;
            pemberitahuan =
                "*Sisa stok telah mencapai batas maksimal alokasi keranjang";
          } else if (qty > _sisaStokTersedia) {
            qty = _sisaStokTersedia > 0 ? _sisaStokTersedia : 1;
          }
        });
      }
    }
  }

  String formatCurrency(String numberString) {
    if (numberString.isEmpty) return '0';
    final number = (double.tryParse(numberString) ?? 0).round();
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  }

  Widget _buildImage() {
    final img = widget.image ?? '';
    if (img.isEmpty) {
      return Container(
          color: Colors.grey.shade200,
          child: Icon(Icons.image_not_supported_rounded,
              color: Colors.grey.shade400));
    }
    if (img.startsWith('assets/')) {
      return Image.asset(img,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey));
    }
    final url = resolveFullUrl(img, ApiEndpoints.authendpoints.getImageProduk);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined,
          color: Colors.grey.shade400),
    );
  }

  Widget _buildChipShimmer(double width) {
    return Container(
      width: width,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Warna" label shimmer
            Container(
              width: 50,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            // Warna chips shimmer
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  _buildChipShimmer(75),
                  const SizedBox(width: 8),
                  _buildChipShimmer(85),
                  const SizedBox(width: 8),
                  _buildChipShimmer(65),
                  const SizedBox(width: 8),
                  _buildChipShimmer(70),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // "Ukuran" label shimmer
            Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            // Ukuran chips shimmer
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  _buildChipShimmer(55),
                  const SizedBox(width: 8),
                  _buildChipShimmer(55),
                  const SizedBox(width: 8),
                  _buildChipShimmer(55),
                  const SizedBox(width: 8),
                  _buildChipShimmer(65),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // "Jumlah" row shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 65,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 105,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Button shimmer
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVariantState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  "Varian produk tidak tersedia",
                  style: AppColors.fontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2828),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Produk ini belum memiliki varian yang dapat disewa saat ini.",
                  textAlign: TextAlign.center,
                  style: AppColors.fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              "Stok Tidak Tersedia",
              style: AppColors.fontStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
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
        child: SingleChildScrollView(
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

              // Header Produk
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
                          if (isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 84,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            )
                          else if (stok != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C4E40)
                                  .withValues(alpha: 0.1),
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
                      icon: Icon(Icons.close_rounded,
                          color: Colors.grey.shade600),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bagian Varian atau Loading Shimmer
              if (isLoading)
                _buildShimmerLoading()
              else if (apiProduk.colors.isEmpty)
                _buildEmptyVariantState()
              else ...[
                // Warna
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Warna",
                    style: AppColors.fontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F2828)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: Obx(() {
                    List<String> listWarna = apiProduk.colors;
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final color = listWarna[index];
                        return ItemVariant(
                          item: color,
                          selected: selectedWarna == color,
                          aksi: () {
                            apiProduk.updateAllUniqueSizes(color: color);
                            setState(() {
                              selectedWarna = color;
                              if (!apiProduk.uniqueSizes
                                  .contains(selectedUkuran)) {
                                selectedUkuran =
                                    apiProduk.uniqueSizes.isNotEmpty
                                        ? apiProduk.uniqueSizes.first
                                        : null;
                              }
                            });
                            _updateState();
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemCount: listWarna.length,
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Ukuran
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Ukuran",
                    style: AppColors.fontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F2828)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: Obx(() {
                    List<String> listUkuran = apiProduk.uniqueSizes;
                    if (listUkuran.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Pilih warna terlebih dahulu",
                            style: AppColors.fontStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final size = listUkuran[index];
                        return ItemVariant(
                          item: size,
                          selected: selectedUkuran == size,
                          aksi: () {
                            setState(() {
                              selectedUkuran = size;
                            });
                            _updateState();
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemCount: listUkuran.length,
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Notifikasi & Jumlah
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (_qtyInCart > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFED6723)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFED6723)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons.shopping_cart_checkout_rounded,
                                  size: 16,
                                  color: Color(0xFFED6723)),
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
                      if (pemberitahuan != null &&
                          pemberitahuan!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEE2737)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 14, color: Color(0xFFEE2737)),
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
                            style: AppColors.fontStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2F2828)),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(MdiIcons.minus,
                                      size: 18,
                                      color: qty > 1 && _sisaStokTersedia > 0
                                          ? const Color(0xFF2F2828)
                                          : Colors.grey.shade400),
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
                                      style: AppColors.fontStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(Icons.add,
                                      size: 18,
                                      color: (stok != null &&
                                              qty < _sisaStokTersedia)
                                          ? const Color(0xFF2F2828)
                                          : Colors.grey.shade400),
                                  onPressed: () {
                                    setState(() {
                                      if (stok != null) {
                                        final currentStok =
                                            int.tryParse(stok!) ?? 0;
                                        if (currentStok < 1) {
                                          pemberitahuan =
                                              "*Stok varian ini habis";
                                        } else if (_sisaStokTersedia < 1) {
                                          pemberitahuan =
                                              "*Sisa stok telah mencapai batas maksimal alokasi keranjang";
                                        } else if (qty < _sisaStokTersedia) {
                                          qty++;
                                          pemberitahuan = "";
                                        } else {
                                          pemberitahuan =
                                              "*Sisa stok telah mencapai batas maksimal alokasi keranjang";
                                        }
                                      } else {
                                        pemberitahuan =
                                            "*Pilih Warna dan Ukuran Terlebih Dahulu";
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

                // Tombol Tambahkan ke Keranjang
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Builder(builder: (context) {
                    final isStokHabis =
                        stok != null && (int.tryParse(stok!) ?? 0) < 1;
                    final isLimitKeranjang = _sisaStokTersedia < 1;
                    final bool canAdd = selectedWarna != null &&
                        selectedUkuran != null &&
                        !isStokHabis &&
                        !isLimitKeranjang;

                    String buttonText;
                    if (isStokHabis) {
                      buttonText = "Stok Varian Habis";
                    } else if (isLimitKeranjang) {
                      buttonText = "Mencapai Batas Keranjang";
                    } else {
                      final basePrice = int.tryParse(harga ??
                              widget.harga
                                  ?.replaceAll(RegExp(r'[^0-9]'), '') ??
                              '0') ??
                          0;
                      final calculatedPrice = (basePrice * qty).toString();
                      buttonText =
                          "Tambahkan - Rp ${formatCurrency(calculatedPrice)}";
                    }

                    return Material(
                      color: canAdd
                          ? const Color(0xFF2C4E40)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(100),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: canAdd
                            ? () async {
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
                                await DatabaseHelper.instance
                                    .insertKeranjang(newRow, context);
                                Get.back();
                              }
                            : () {
                                if (selectedWarna == null ||
                                    selectedUkuran == null) {
                                  setState(() {
                                    pemberitahuan =
                                        "*Pilih Warna dan Ukuran Terlebih Dahulu";
                                  });
                                } else if (isStokHabis) {
                                  setState(() {
                                    pemberitahuan = "*Stok varian ini habis";
                                  });
                                } else if (isLimitKeranjang) {
                                  setState(() {
                                    pemberitahuan =
                                        "*Sisa stok telah mencapai batas maksimal alokasi keranjang";
                                  });
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Text(
                            buttonText,
                            style: AppColors.fontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
