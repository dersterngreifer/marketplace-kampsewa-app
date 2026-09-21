import 'package:project_camp_sewa/theme_colors.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/button/alamat_opsi_pengiriman.dart';
import 'package:project_camp_sewa/components/button/opsi_pengiriman.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/models/alamat_model.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/services/api_transaksi.dart';

class LayoutOpsiPengiriman extends StatefulWidget {
  const LayoutOpsiPengiriman({super.key});

  @override
  State<LayoutOpsiPengiriman> createState() => _LayoutOpsiPengirimanState();
}

class _LayoutOpsiPengirimanState extends State<LayoutOpsiPengiriman> {
  ApiTransaksi apiTransaksi = Get.put(ApiTransaksi());
  ApiDataUser apiDataUser = Get.put(ApiDataUser());
  String selectedImageAntar = "assets/icons/selected-opsi-antar.png";
  String defaultImageAntar = "assets/icons/default-opsi-antar.png";
  String selectedImageAmbil = "assets/icons/selected-opsi-ambil.png";
  String defaultImageAmbil = "assets/icons/default-opsi-ambil.png";
  Color selectedBgColor = const Color(0xFF2F2828);
  Color defaultBgColor = Colors.white;
  Color selectedTextColor = Colors.white;
  Color defaultTextColor = Colors.black;
  String selectedOption = "ambil";
  RxString alamatUser = "Sedang Mengambil Alamat...".obs;
  RxString alamatToko = "Sedang Mengambil Alamat...".obs;
  String? idToko;

  @override
  void initState() {
    super.initState();
    getAlamatTokoOpsiPengiriman();
    getAlamatUserOpsiPengiriman();
  }

  Future<void> getAlamatTokoOpsiPengiriman() async {
    final arguments = await Get.arguments as Map<String, dynamic>;
    idToko = arguments['idToko'];
    await apiTransaksi.getAlamatToko(context, idToko!);
    final alamat = apiTransaksi.alamatTokoCheckout.value;
    if (alamat != null) {
      double longitudeToko = double.parse(alamat.longitude);
      double latitudeToko = double.parse(alamat.latitude);
      String convertedAlamat = await convertAlamat(latitudeToko, longitudeToko);
      alamatToko.value = convertedAlamat;
    }
  }

  Future<void> getAlamatUserOpsiPengiriman() async {
    await apiDataUser.getListAlamatUser(context);
    AlamatUserModel alamat = apiDataUser.listAlamatUser[0];
    double longitude = double.parse(alamat.longitude);
    double latitude = double.parse(alamat.latitude);
    String convertedAlamat = await convertAlamat(latitude, longitude);
    alamatUser.value = convertedAlamat;
  }

  Future<String> convertAlamat(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await Geocoding().placemarkFromCoordinates(latitude, longitude);

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
      CustomSnackBar.show(context, sukses: false,
            teks: "Tidak bisa Mengkonversi koordinat alamat anda",);
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 3),
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
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4 - 45,
                ),
                Text(
                  "Opsi Pengiriman",
                  style: AppColors.fontStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
              ]),
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 20, bottom: 5),
              child: Text(
                "Pilih Jasa Pengiriman",
                style: AppColors.fontStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.3,
                child: Text(
                  "Barang akan dikirim sesuai dengan alamat yang anda tentukan atau barang anda ambil di store penyewa",
                  style: AppColors.fontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedOption = "antar";
                      });
                    },
                    child: ButtonOpsiPengiriman(
                      image: selectedOption == "antar"
                          ? selectedImageAntar
                          : defaultImageAntar,
                      bgColor: selectedOption == "antar"
                          ? selectedBgColor
                          : defaultBgColor,
                      borderColor: selectedOption == "antar"
                          ? selectedBgColor
                          : defaultTextColor,
                      teksColor: selectedOption == "antar"
                          ? selectedTextColor
                          : defaultTextColor,
                      teksOpsi: "Antar Ke Alamatmu",
                      teksHarga: "Dari IDR.5.000,00",
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedOption = "ambil";
                      });
                    },
                    child: ButtonOpsiPengiriman(
                      image: selectedOption == "ambil"
                          ? selectedImageAmbil
                          : defaultImageAmbil,
                      bgColor: selectedOption == "ambil"
                          ? selectedBgColor
                          : defaultBgColor,
                      borderColor: selectedOption == "ambil"
                          ? selectedBgColor
                          : defaultTextColor,
                      teksColor: selectedOption == "ambil"
                          ? selectedTextColor
                          : defaultTextColor,
                      teksOpsi: "Ambil Ditempat",
                      teksHarga: "Dari IDR.0,00",
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Obx(
              () => AlamatOpsiPengiriman(
                opsi: "Alamat Pengiriman",
                alamat: alamatUser.value,
                keteranganKirim:
                    "Barang akan dikirim sesuai dengan tanggal yang ditentukan",
                opacity: selectedOption == "antar" ? 1 : 0.5,
                edit: selectedOption == "antar" ? true : false,
                checklist: selectedOption == "antar" ? true : false,
              ),
            ),
            Obx(
              () => AlamatOpsiPengiriman(
                opsi: "Alamat Store",
                alamat: alamatToko.value,
                keteranganKirim:
                    "Barang akan dikirim sesuai dengan tanggal yang ditentukan",
                opacity: selectedOption == "ambil" ? 1 : 0.5,
                edit: false,
                checklist: selectedOption == "ambil" ? true : false,
              ),
            ),
            Container(
              height: 1.2,
              color: Colors.black.withValues(alpha: 0.25),
            ),
            const Spacer(),
            Container(
              height: 2,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: InkWell(
                onTap: () {
                  if (selectedOption == "antar") {
                    CustomSnackBar.show(context, sukses: false,
                          title: "Fitur Segera Tersedia",
                          teks: "Maaf Fitur Pengantaran Belum Tersedia",);
                  } else {
                    Get.back(
                        result: selectedOption ==
                                "antar" //ini nanti alamatnya ngambil dari api lalu dimasukin disini
                            ? {
                                'selectedOption': "Antar Ke Alamatmu",
                                'alamat': alamatUser.value
                              }
                            : {
                                'selectedOption': "Ambil di Tempat",
                                'alamat': alamatToko.value
                              });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF2F2828),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Konfirmasi",
                        style: AppColors.fontStyle(
                            fontSize: 17,
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
      )),
    );
  }
}
