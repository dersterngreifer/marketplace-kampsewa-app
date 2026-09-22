import 'dart:io';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_camp_sewa/components/card/metode_pembayaran_card.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/layouts/layout_tambah_metode_transfer.dart';
import 'package:project_camp_sewa/models/bank_model.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/services/api_transaksi.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';

class LayoutTambahDataToko extends StatefulWidget {
  const LayoutTambahDataToko({super.key});

  @override
  State<LayoutTambahDataToko> createState() => _LayoutTambahDataTokoState();
}

class _LayoutTambahDataTokoState extends State<LayoutTambahDataToko> {
  ApiTransaksi apiTransaksi = Get.put(ApiTransaksi());
  ApiDataUser apiDataUser = Get.put(ApiDataUser());
  TextEditingController alamatController = TextEditingController();
  String? latitude;
  String? longitude;
  XFile? pickedBanner;

  static const Color _forest = Color(0xFF2C4E40);
  static const Color _dark = Color(0xFF2F2828);
  static const Color _bg = Color(0xFFFAFAF8);

  // box-shadow: rgba(0,0,0,0.05) 0px 6px 24px 0px, rgba(0,0,0,0.08) 0px 0px 0px 1px
  static final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 6),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 0),
      blurRadius: 0,
      spreadRadius: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    getListBank();
  }

  Future<void> getListBank() async {
    Authorization auth = Authorization();
    int? id = await auth.getId();
    String idStr = id.toString();
    // ignore: use_build_context_synchronously
    await apiTransaksi.getBankOpsiPembayaran(context, idStr);
  }

  void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();

    List<Placemark> placemarks = await Geocoding()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String jalan = placemark.street ?? '';
      String postalCode = placemark.postalCode ?? '';
      String kecamatan = placemark.subLocality ?? '';
      String kabupaten = placemark.locality ?? '';
      String provinsi = placemark.administrativeArea ?? '';
      alamatController.text =
          "$jalan, $kecamatan, $kabupaten, $provinsi, $postalCode";
      setState(() {});
    } else {
      if (mounted) {
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: "Tidak bisa Mengkonversi koordinat alamat anda",
        );
      }
    }
  }

  Future<void> _pickBanner() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        pickedBanner = image;
      });
    }
  }

  // ---- Reusable style helpers ----

  /// White card wrapper that gives every input its visible soft-shadow +
  /// hairline outline, instead of a flat/soft fill that disappears into
  /// the page background.
  Widget _inputCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4),
      child: child,
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppColors.fontStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade400),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, left: 20, right: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 15,
            decoration: BoxDecoration(
              color: _forest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppColors.fontStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: _dark),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _cardShadow,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: _dark, size: 16),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Store Saya",
                        style: AppColors.fontStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _dark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _sectionLabel("Nama Toko"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _inputCard(
                      child: TextField(
                        controller: apiDataUser.namaTokoController,
                        decoration: _fieldDecoration("Nama Tokomu"),
                        style: AppColors.fontStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _dark),
                      ),
                    ),
                  ),
                  _sectionLabel("Deskripsi Toko"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _inputCard(
                      child: TextField(
                        controller: apiDataUser.deskripsiTokoController,
                        keyboardType: TextInputType.text,
                        maxLines: 4,
                        decoration:
                            _fieldDecoration("Deskripsikan toko Anda..."),
                        style: AppColors.fontStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: _dark),
                      ),
                    ),
                  ),
                  _sectionLabel("Banner Toko"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: pickedBanner != null
                        ? Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: _cardShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(pickedBanner!.path),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        pickedBanner = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: _pickBanner,
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: _cardShadow,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: _forest.withValues(alpha: 0.09),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 22,
                                      color: _forest,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Pilih Banner Toko",
                                    style: AppColors.fontStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: _dark),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Rasio 3:1 direkomendasikan",
                                    style: AppColors.fontStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  _sectionLabel("Alamat"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _inputCard(
                            child: TextField(
                              controller: alamatController,
                              enabled: false,
                              maxLines: null,
                              decoration: _fieldDecoration(
                                  "Provinsi, Kota, Kecamatan, Kode Pos"),
                              style: AppColors.fontStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _dark),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: getLocation,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: _forest,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _forest.withValues(alpha: 0.28),
                                  offset: const Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.my_location_rounded,
                                    size: 15, color: Colors.white),
                                const SizedBox(height: 2),
                                Text(
                                  "Lokasiku",
                                  style: AppColors.fontStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _inputCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: TextField(
                        controller: apiDataUser.detailAlamatTokoController,
                        keyboardType: TextInputType.text,
                        maxLines: 3,
                        decoration: _fieldDecoration(
                            "Detail Lainnya (Contoh: Nama Jalan, Blok, No Rumah)"),
                        style: AppColors.fontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _dark),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Metode Pembayaran",
                          style: AppColors.fontStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: _dark),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(const LayoutTambahMetodeTransfer());
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _forest.withValues(alpha: 0.08),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Tambah",
                                  style: AppColors.fontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _forest),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.add_rounded,
                                    size: 16, color: _forest),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: CardMetodePembayaran(
                        metodePembayaran: "COD",
                        bank: "Pembayaran dengan uang cash",
                        noRek: "Default"),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() {
                      var listBank = apiTransaksi.listBankMetodeBayar;
                      return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            BankModel list = listBank[index];
                            return CardMetodePembayaran(
                              metodePembayaran: "Transfer",
                              bank: list.bank,
                              noRek: list.rekening,
                              edit: () {
                                Get.to(() => LayoutTambahMetodeTransfer(
                                      edit: true,
                                      bankId: list.id.toString(),
                                      noRek: list.rekening,
                                      jenisBank: list.bank,
                                    ));
                              },
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemCount: listBank.length);
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom action
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: _bg,
                border: Border(
                  top: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
                ),
              ),
              child: InkWell(
                onTap: () {
                  if (apiDataUser.namaTokoController.text.isNotEmpty) {
                    if (latitude != null && longitude != null) {
                      apiDataUser.isiDataToko(
                        context,
                        latitude!,
                        longitude!,
                        bannerPath: pickedBanner?.path,
                      );
                    } else {
                      CustomSnackBar.show(
                        context,
                        sukses: false,
                        title: "Gagal Menyimpan Data",
                        teks: "Masukkan Alamat Anda Terlebih Dahulu",
                      );
                    }
                  } else {
                    CustomSnackBar.show(
                      context,
                      sukses: false,
                      title: "Gagal Menyimpan Data",
                      teks: "Masukkan Nama Toko Terlebih Dahulu",
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _forest,
                    boxShadow: [
                      BoxShadow(
                        color: _forest.withValues(alpha: 0.25),
                        offset: const Offset(0, 8),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Lanjutkan",
                      style: AppColors.fontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
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
