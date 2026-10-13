import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:project_camp_sewa/services/api_data_user.dart' as import_api_data_user;
import 'package:project_camp_sewa/layouts/layout_instruksi_kyc.dart' as import_instruksi_kyc;
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/components/card/chekout_produk_card.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/layouts/layout_metode_pembayaran.dart';
import 'package:project_camp_sewa/layouts/layout_opsi_pengiriman.dart';
import 'package:project_camp_sewa/models/keranjang_model.dart';
import 'package:project_camp_sewa/services/api_transaksi.dart';
import 'package:project_camp_sewa/services/controller_keranjang.dart';

class LayoutCheckout extends StatefulWidget {
  const LayoutCheckout({super.key});

  @override
  State<LayoutCheckout> createState() => _LayoutCheckoutState();
}

class _LayoutCheckoutState extends State<LayoutCheckout> {
  KeranjangController keranjangController = Get.put(KeranjangController());
  ApiTransaksi apiTransaksi = Get.put(ApiTransaksi());
  String? metodeBayar;
  String opsiPengiriman = "Ambil Ditempat";
  int biayaAntar = 0;
  String? jenisBank;
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;
  DateTimeRange durasiSewa = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  String? formatedTanggalAwal;
  String? formatedTanggalAkhir;
  double? longitudeToko;
  double? latitudeToko;
  RxString alamatPengiriman = "sedang mendapatkan alamat...".obs;
  int? idToko;
  RxString namaToko = "".obs;
  String? rekeningBank;

  @override
  void initState() {
    super.initState();
    keranjangController.getSelectedProdukCheckout(context);
    keranjangController.updateTotalItemKeranjang(context);
    keranjangController.updateTotalHargaKeranjang(context);
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await keranjangController.getSelectedProdukCheckout(context);

    final List<Map<String, dynamic>> produkCheckout =
        keranjangController.selectedProdukCheckout.toList();

    if (produkCheckout.isNotEmpty) {
      final KeranjangModel keranjang = KeranjangModel.fromMap(produkCheckout[0]);
      idToko = keranjang.idToko;
      namaToko.value = keranjang.namaToko;
      // ignore: use_build_context_synchronously
      await apiTransaksi.getAlamatToko(context, idToko.toString());
      final alamat = apiTransaksi.alamatTokoCheckout.value;
      if (alamat != null) {
        longitudeToko = double.parse(alamat.longitude);
        latitudeToko = double.parse(alamat.latitude);
        String convertedAlamat = await convertAlamat(latitudeToko!, longitudeToko!);
        alamatPengiriman.value = convertedAlamat;
      }
    }
  }

  Future<String> convertAlamat(double latitude, double longitude) async {
    List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String jalan = placemark.street ?? '';
      String postalCode = placemark.postalCode ?? '';
      String kecamatan = placemark.subLocality ?? '';
      String kabupaten = placemark.locality ?? '';
      String provinsi = placemark.administrativeArea ?? '';
      String alamat = "$jalan, $kecamatan, $kabupaten, $provinsi, $postalCode";
      return alamat;
    } else {
      if (mounted) {
        CustomSnackBar.show(context, sukses: false, teks: "Tidak bisa Mengkonversi koordinat alamat anda");
      }
      return "";
    }
  }

  String formatCurrency(String numberString) {
    final number = int.parse(numberString);
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  }

  Widget _buildSection({required Widget child, bool isError = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isError ? Border.all(color: Colors.red.shade400, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isError ? Colors.red.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 24),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Checkout",
          style: AppColors.fontStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                children: [
                  // Store & Product Section
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F2828).withOpacity(0.06),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(MdiIcons.storefrontOutline, color: const Color(0xFF2F2828), size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Obx(() => Text(
                                  namaToko.value,
                                  style: AppColors.fontStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2F2828),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ),
                            ],
                          ),
                        ),
                        
                        // Product List
                        Obx(() {
                          final List<Map<String, dynamic>> produkCheckout =
                              keranjangController.selectedProdukCheckout.toList();
                          return ListView.builder(
                              itemCount: produkCheckout.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final KeranjangModel keranjang =
                                    KeranjangModel.fromMap(produkCheckout[index]);
                                return CheckoutProdukCard(
                                  image: keranjang.fotoProduk,
                                  namaProduk: keranjang.namaProduk,
                                  variasiWarna: keranjang.variantWarna,
                                  variasiUkuran: keranjang.variantUkuran,
                                  hargaProduk: keranjang.harga.toString(),
                                  qtyProduk: keranjang.qty.toString(),
                                );
                              });
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Date Picker Section
                  _buildSection(
                    isError: tanggalAwal == null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final tanggalSewa = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                            helpText: 'PILIH RENTANG TANGGAL SEWA',
                            cancelText: 'BATAL',
                            confirmText: 'SIMPAN',
                            saveText: 'SIMPAN',
                            fieldStartHintText: 'Tanggal Mulai',
                            fieldEndHintText: 'Tanggal Berakhir',
                            fieldStartLabelText: 'Mulai',
                            fieldEndLabelText: 'Berakhir',
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: const Color(0xFF2C4E40),
                                  scaffoldBackgroundColor: Colors.white,
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF2C4E40), 
                                    onPrimary: Colors.white, 
                                    onSurface: Colors.black87,
                                    surface: Colors.white,
                                  ),
                                  appBarTheme: const AppBarTheme(
                                    backgroundColor: Color(0xFF2C4E40),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    iconTheme: IconThemeData(color: Colors.white),
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF2C4E40),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF2C4E40), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    labelStyle: const TextStyle(color: Color(0xFF2C4E40), fontWeight: FontWeight.w600),
                                  ),
                                  datePickerTheme: DatePickerThemeData(
                                    backgroundColor: Colors.white,
                                    surfaceTintColor: Colors.transparent,
                                    headerBackgroundColor: const Color(0xFF2C4E40),
                                    headerForegroundColor: Colors.white,
                                    dividerColor: Colors.grey.shade200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    dayStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                    weekdayStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.black54, fontSize: 13),
                                    rangePickerBackgroundColor: Colors.white,
                                    rangePickerElevation: 0,
                                    rangePickerHeaderBackgroundColor: const Color(0xFF2C4E40),
                                    rangePickerHeaderForegroundColor: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                        );

                        if (tanggalSewa != null) {
                          setState(() {
                            durasiSewa = tanggalSewa;
                            tanggalAwal = tanggalSewa.start;
                            tanggalAkhir = tanggalSewa.end;
                            formatedTanggalAwal = DateFormat('yyyy-MM-dd').format(tanggalAwal!);
                            formatedTanggalAkhir = DateFormat('yyyy-MM-dd').format(tanggalAkhir!);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(MdiIcons.calendarRange, color: tanggalAwal == null ? Colors.red[600] : Colors.blue[700], size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  "Tentukan Tanggal Sewa",
                                  style: AppColors.fontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: tanggalAwal == null ? Colors.red[600] : Colors.black87,
                                  ),
                                ),
                                if (tanggalAwal == null) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Wajib",
                                      style: AppColors.fontStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                // Box Tanggal Mulai
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Tanggal Mulai", style: AppColors.fontStyle(fontSize: 11, color: Colors.black54)),
                                        const SizedBox(height: 4),
                                        Text(
                                          tanggalAwal != null ? DateFormat('dd MMM yyyy').format(tanggalAwal!) : "Pilih Tanggal",
                                          style: AppColors.fontStyle(
                                            fontSize: 13,
                                            fontWeight: tanggalAwal != null ? FontWeight.w700 : FontWeight.w500,
                                            color: tanggalAwal != null ? Colors.black87 : Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: 20),
                                ),
                                // Box Tanggal Akhir
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Tanggal Berakhir", style: AppColors.fontStyle(fontSize: 11, color: Colors.black54)),
                                        const SizedBox(height: 4),
                                        Text(
                                          tanggalAkhir != null ? DateFormat('dd MMM yyyy').format(tanggalAkhir!) : "Pilih Tanggal",
                                          style: AppColors.fontStyle(
                                            fontSize: 13,
                                            fontWeight: tanggalAkhir != null ? FontWeight.w700 : FontWeight.w500,
                                            color: tanggalAkhir != null ? Colors.black87 : Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Delivery Option Section
                  _buildSection(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final pilihanPengiriman = await Get.to(
                            () => const LayoutOpsiPengiriman(),
                            arguments: {'idToko': idToko.toString()});
                        setState(() {
                          if (pilihanPengiriman != null) {
                            opsiPengiriman = pilihanPengiriman['selectedOption'];
                            alamatPengiriman.value = pilihanPengiriman['alamat'];
                            biayaAntar = pilihanPengiriman['biayaAntar'] ?? 0;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Opsi Pengiriman",
                              style: AppColors.fontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(MdiIcons.truckDeliveryOutline, color: Colors.green[700], size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opsiPengiriman,
                                        style: AppColors.fontStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Obx(() => Text(
                                        alamatPengiriman.value,
                                        style: AppColors.fontStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  biayaAntar > 0
                                      ? "Rp ${formatCurrency(biayaAntar.toString())}"
                                      : "Gratis",
                                  style: AppColors.fontStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.navigate_next_rounded, color: Colors.grey, size: 28),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Message Section
                  _buildSection(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(MdiIcons.messageTextOutline, color: Colors.black87, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Pesan untuk Toko",
                                style: AppColors.fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: apiTransaksi.pesanController,
                              maxLines: 2,
                              minLines: 1,
                              style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.w400),
                              decoration: InputDecoration(
                                hintText: "Silakan tinggalkan pesan (opsional)...",
                                hintStyle: AppColors.fontStyle(fontSize: 13, color: Colors.grey.shade400),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Payment Method Section
                  _buildSection(
                    isError: metodeBayar == null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final pilihanPembayaran = await Get.to(
                            () => const LayoutMetodePembayaran(),
                            arguments: {'idToko': idToko.toString()});
                        setState(() {
                          if (pilihanPembayaran != null) {
                            metodeBayar = pilihanPembayaran["metodeBayar"];
                            jenisBank = pilihanPembayaran["jenisBank"];
                            rekeningBank = pilihanPembayaran["rekeningBank"];
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(MdiIcons.walletOutline, color: Colors.orange[700], size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Metode Pembayaran",
                                style: AppColors.fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: metodeBayar == null ? Colors.red[600] : Colors.black87,
                                ),
                              ),
                            ),
                            if (metodeBayar == null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Wajib pilih",
                                  style: AppColors.fontStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[700],
                                  ),
                                ),
                              )
                            else
                              Text(
                                jenisBank != null ? "$metodeBayar - ${jenisBank!}" : metodeBayar!,
                                style: AppColors.fontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            const SizedBox(width: 4),
                            const Icon(Icons.navigate_next_rounded, color: Colors.grey, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Payment Details Section
                  _buildSection(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(MdiIcons.receiptTextOutline, color: Colors.black87, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Rincian Pembayaran",
                                style: AppColors.fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Produk", style: AppColors.fontStyle(fontSize: 13, color: Colors.black54)),
                              Obx(() => Text("${keranjangController.totalItemKeranjang.value} Produk", style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Durasi Sewa", style: AppColors.fontStyle(fontSize: 13, color: Colors.black54)),
                              Text("${durasiSewa.duration.inDays} Hari", style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Sub Total Produk", style: AppColors.fontStyle(fontSize: 13, color: Colors.black54)),
                              Obx(() {
                                int subTotal = keranjangController.totalHargaKeranjang.value;
                                int durasi = durasiSewa.duration.inDays == 0 ? 1 : durasiSewa.duration.inDays;
                                int grandTotal = subTotal * durasi;
                                return Text("Rp ${formatCurrency(grandTotal.toString())}", style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600));
                              }),
                            ],
                          ),
                          if (biayaAntar > 0 || opsiPengiriman == "Antar Ke Alamatmu") ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Biaya Pengantaran", style: AppColors.fontStyle(fontSize: 13, color: Colors.black54)),
                                Text(
                                  biayaAntar > 0
                                      ? "Rp ${formatCurrency(biayaAntar.toString())}"
                                      : "Gratis",
                                  style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Biaya Layanan", style: AppColors.fontStyle(fontSize: 13, color: Colors.black54)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text("Free", style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green[700])),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, thickness: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Pembayaran", style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                              Obx(() {
                                int subTotal = keranjangController.totalHargaKeranjang.value;
                                int durasi = durasiSewa.duration.inDays == 0 ? 1 : durasiSewa.duration.inDays;
                                int grandTotal = (subTotal * durasi) + biayaAntar;
                                return Text(
                                  "Rp ${formatCurrency(grandTotal.toString())}",
                                  style: AppColors.fontStyle(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFEE2737)),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Total Pembayaran",
                          style: AppColors.fontStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Obx(() {
                          int subTotal = keranjangController.totalHargaKeranjang.value;
                          int durasi = durasiSewa.duration.inDays == 0 ? 1 : durasiSewa.duration.inDays;
                          int total = (subTotal * durasi) + biayaAntar;
                          return Text(
                            "Rp ${formatCurrency(total.toString())}",
                            style: AppColors.fontStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.w700, 
                              color: const Color(0xFFEE2737)
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final apiDataUser = Get.find<import_api_data_user.ApiDataUser>();
                      final user = apiDataUser.dataUser.value;
                      bool needsKYC = user != null && user.type == 0 && 
                          (user.nomorIdentitas == null || user.nomorIdentitas.toString().isEmpty || 
                           user.fotoIdentitas == null || user.fotoIdentitas.toString().isEmpty);

                      if (needsKYC) {
                        CustomSnackBar.show(context, sukses: false, title: "Perhatian", teks: "Harap lengkapi identitas (KTP) Anda sebelum menyewa barang.");
                        Get.to(() => const import_instruksi_kyc.LayoutInstruksiKYC());
                        return;
                      }

                      if (tanggalAwal == null) {
                        CustomSnackBar.show(context, sukses: false, title: "Notifikasi", teks: "Masukkan Tanggal Sewa Terlebih Dahulu");
                        return;
                      }
                      if (metodeBayar == null) {
                        CustomSnackBar.show(context, sukses: false, title: "Notifikasi", teks: "Pilih Metode Pembayaran Terlebih Dahulu");
                        return;
                      }
                      
                      String metode = metodeBayar == "Bayar Ditempat" ? "COD" : "Transfer";
                      int subTotal = keranjangController.totalHargaKeranjang.value;
                      int durasi = durasiSewa.duration.inDays == 0 ? 1 : durasiSewa.duration.inDays;
                      int finalTotal = (subTotal * durasi) + biayaAntar;
                      apiTransaksi.transaksiCheckout(
                          context,
                          formatedTanggalAwal!,
                          formatedTanggalAkhir!,
                          metode,
                          finalTotal.toString(),
                          jenisBank,
                          rekeningBank ?? '',
                          idToko,
                          opsiPengiriman: opsiPengiriman,
                          biayaAntar: biayaAntar,
                          alamatPengiriman: alamatPengiriman.value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C4E40),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Checkout",
                      style: AppColors.fontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
