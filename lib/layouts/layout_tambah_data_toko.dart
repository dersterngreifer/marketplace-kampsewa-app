import 'dart:io';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();

    List<Placemark> placemarks =
        await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String jalan = placemark.street ?? '';
      String postalCode = placemark.postalCode ?? '';
      String kecamatan = placemark.subLocality ?? '';
      String kabupaten = placemark.locality ?? '';
      String provinsi = placemark.administrativeArea ?? '';
      alamatController.text =
          "$jalan, $kecamatan, $kabupaten, $provinsi, $postalCode";
    } else {
      if (mounted) {
        CustomSnackBar.show(context, sukses: false,
              teks: "Tidak bisa Mengkonversi koordinat alamat anda",);
      }
    }
  }

  Future<void> _pickBanner() async {
    final status = await Permission.photos.request();

    if (!status.isGranted) {
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black,
                          size: 28,
                        )),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: Text(
                          "Store Saya",
                          style: AppColors.fontStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              height: 2,
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, right: 20, bottom: 8),
                    child: Text(
                      "Nama Toko",
                      style: AppColors.fontStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.3),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: TextField(
                          controller: apiDataUser.namaTokoController,
                          decoration: InputDecoration(
                              hintText: "Nama Tokomu",
                              hintStyle: AppColors.fontStyle(
                                  fontSize: 14.5, fontWeight: FontWeight.w500),
                              border: InputBorder.none),
                          style: AppColors.fontStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25, left: 20, right: 20, bottom: 8),
                    child: Text(
                      "Deskripsi Toko",
                      style: AppColors.fontStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.3),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: TextField(
                          controller: apiDataUser.deskripsiTokoController,
                          keyboardType: TextInputType.text,
                          maxLines: 4,
                          decoration: InputDecoration(
                              hintText: "Deskripsikan toko Anda...",
                              hintStyle: AppColors.fontStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              border: InputBorder.none),
                          style: AppColors.fontStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25, left: 20, right: 20, bottom: 8),
                    child: Text(
                      "Banner Toko",
                      style: AppColors.fontStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: pickedBanner != null
                        ? Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.black, width: 1.3),
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
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        pickedBanner = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.6),
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
                                border: Border.all(
                                    color: Colors.black, width: 1.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 36,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Pilih Banner Toko",
                                    style: AppColors.fontStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rasio 3:1 direkomendasikan",
                                    style: AppColors.fontStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25, left: 20, right: 20, bottom: 8),
                    child: Text(
                      "Alamat",
                      style: AppColors.fontStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: TextField(
                                  controller: alamatController,
                                  enabled: false,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      hintText:
                                          "Provinsi, Kota, Kecamatan, Kode Pos",
                                      hintStyle: AppColors.fontStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                      border: InputBorder.none),
                                  style: AppColors.fontStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () {
                              getLocation();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xFF2F2828),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 8),
                                  child: Text(
                                    "Ambil\nLokasimu",
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: AppColors.fontStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.3),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        child: TextField(
                          controller: apiDataUser.detailAlamatTokoController,
                          keyboardType: TextInputType.text,
                          maxLines: 3,
                          decoration: InputDecoration(
                              hintText:
                                  "Detail Lainnya (Contoh: {Nama Jalan, Blok, No Rumah)",
                              hintStyle: AppColors.fontStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              border: InputBorder.none),
                          style: AppColors.fontStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 30, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Metode Pembayaran",
                          style: AppColors.fontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(const LayoutTambahMetodeTransfer());
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF2F2828),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              child: Row(
                                children: [
                                  Text(
                                    "Tambah",
                                    style: AppColors.fontStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const CardMetodePembayaran(
                      metodePembayaran: "COD",
                      bank: "Pembayaran dengan uang cash",
                      noRek: "Default"),
                  const SizedBox(
                    height: 5,
                  ),
                  Obx(() {
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
                              //ke Edit metode Transfer
                            },
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 5,
                            ),
                        itemCount: listBank.length);
                  }),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    height: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 25),
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
                            CustomSnackBar.show(context, sukses: false,
                                  title: "Gagal Menyimpan Data",
                                  teks: "Masukkan Alamat Anda Terlebih Dahulu",);
                          }
                        } else {
                          CustomSnackBar.show(context, sukses: false,
                                title: "Gagal Menyimpan Data",
                                teks: "Masukkan Nama Toko Terlebih Dahulu",);
                        }
                      },
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF2F2828)),
                        child: Center(
                          child: Text(
                            "Lanjutkan",
                            style: AppColors.fontStyle(
                                fontSize: 18.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
