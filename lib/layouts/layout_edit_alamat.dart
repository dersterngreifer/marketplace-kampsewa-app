import 'package:project_camp_sewa/theme_colors.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/models/user.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';

class LayoutEditAlamat extends StatefulWidget {
  final bool edit;
  final String? idAlamat;
  final String? namaLengkap;
  final String? noTelepon;
  final String? longitude;
  final String? latitude;
  final String? detailAlamat;
  final String? ditandaiSebagai;
  const LayoutEditAlamat(
      {super.key,
      required this.edit,
      this.idAlamat,
      this.namaLengkap,
      this.noTelepon,
      this.longitude,
      this.latitude,
      this.detailAlamat,
      this.ditandaiSebagai});

  @override
  State<LayoutEditAlamat> createState() => _LayoutEditAlamatState();
}

class _LayoutEditAlamatState extends State<LayoutEditAlamat> {
  ApiDataUser apiDataUser = Get.put(ApiDataUser());
  TextEditingController namaLengkapController = TextEditingController();
  TextEditingController noTeleponController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  String ditandaiSebagai = "Rumah";
  String? latitude;
  String? longitude;

  @override
  void initState() {
    if (widget.edit) {
      namaLengkapController.text = widget.namaLengkap ?? "";
      noTeleponController.text = widget.noTelepon ?? "";
      latitude = widget.latitude;
      longitude = widget.longitude;
      convertAlamat(latitude!, longitude!);
      apiDataUser.detailAlamatController.text = widget.detailAlamat ?? "";
      ditandaiSebagai = widget.ditandaiSebagai ?? "Rumah";
    } else {
      apiDataUser.getDataUser(context);
      User? data = apiDataUser.dataUser.value;
      namaLengkapController.text = data!.name!;
      noTeleponController.text = data.nomorTelephone!;
    }
    super.initState();
  }

  @override
  void dispose() {
    namaLengkapController.dispose();
    noTeleponController.dispose();
    alamatController.dispose();
    super.dispose();
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
      CustomSnackBar.show(context, sukses: false,
            teks: "Tidak bisa Mengkonversi koordinat alamat anda",);
    }
  }

  void convertAlamat(String strLatitude, String strLongitude) async {
    double latitude = double.parse(strLatitude);
    double longitude = double.parse(strLongitude);
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
      alamatController.text = alamat;
    } else {
      CustomSnackBar.show(context, sukses: false,
            teks: "Tidak bisa Mengkonversi koordinat alamat anda",);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Column(
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
                      width: MediaQuery.of(context).size.width / 4 - 15,
                    ),
                    Text(
                      widget.edit ? "Edit Alamat" : "Alamat Baru",
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
                      top: 25, left: 25, right: 20, bottom: 5),
                  child: Text(
                    "Kontak",
                    style: AppColors.fontStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 4),
                      child: TextField(
                        controller: namaLengkapController,
                        decoration: InputDecoration(
                            hintText: "Nama Lengkap",
                            enabled: false,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: TextField(
                        controller: noTeleponController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: "Nomor Telepon Aktif",
                            enabled: false,
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
                      top: 15, left: 25, right: 20, bottom: 5),
                  child: Text(
                    "Alamat",
                    style: AppColors.fontStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            //get location
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: TextField(
                        controller: apiDataUser.detailAlamatController,
                        keyboardType: TextInputType.text,
                        maxLines: 3,
                        decoration: InputDecoration(
                            hintText:
                                "Detail Lainnya (Contoh: {Nama Jalan, Blok, No Rumah)",
                            hintStyle: AppColors.fontStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            border: InputBorder.none),
                        style: AppColors.fontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 25, right: 20, bottom: 5),
                  child: Text(
                    "Tandai Sebagai",
                    style: AppColors.fontStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          ditandaiSebagai = "Rumah";
                        });
                      },
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          color: ditandaiSebagai == "Rumah"
                              ? const Color(0xFF2F2828)
                              : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              ditandaiSebagai == "Rumah"
                                  ? "assets/icons/alamat-home-selected.png"
                                  : "assets/icons/alamat-home.png",
                              scale: 2,
                            ),
                            Text(
                              "Rumah",
                              style: AppColors.fontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ditandaiSebagai == "Rumah"
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          ditandaiSebagai = "Kantor";
                        });
                      },
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                          color: ditandaiSebagai == "Kantor"
                              ? const Color(0xFF2F2828)
                              : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              ditandaiSebagai == "Kantor"
                                  ? "assets/icons/alamat-office-selected.png"
                                  : "assets/icons/alamat-kantor.png",
                              scale: 2,
                            ),
                            Text(
                              "Kantor",
                              style: AppColors.fontStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ditandaiSebagai == "Kantor"
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 35),
                  child: InkWell(
                    onTap: () {
                      if (widget.edit) {
                        //edit alamat
                        if (latitude != null && longitude != null) {
                          apiDataUser.updateAlamatUser(
                              context,
                              widget.idAlamat!,
                              latitude!,
                              longitude!,
                              ditandaiSebagai);
                        } else {
                          CustomSnackBar.show(context, sukses: false,
                                teks: "Latitude dan Longitude Kosong!",);
                        }
                      } else {
                        if (latitude != null && longitude != null) {
                          apiDataUser.tambahAlamatUser(
                              context, latitude!, longitude!, ditandaiSebagai);
                        } else {
                          CustomSnackBar.show(context, sukses: false,
                                teks: "Latitude dan Longitude Kosong!",);
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF2F2828),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Simpan",
                            style: AppColors.fontStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.edit,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: 15, bottom: 20),
                    child: InkWell(
                      onTap: () {
                        apiDataUser.deleteAlamatUser(context, widget.idAlamat!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFFEE2737),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Hapus Alamat",
                              style: AppColors.fontStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      )),
    );
  }
}
