import 'package:project_camp_sewa/theme_colors.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';

class AlamatCard extends StatefulWidget {
  final String? namaUser;
  final String? noTeleponUser;
  final String longitude;
  final String latitude;
  final String? tipeAlamat;
  final Function()? editAlamat;
  const AlamatCard(
      {super.key,
      required this.longitude,
      required this.latitude,
      this.noTeleponUser,
      this.namaUser,
      this.tipeAlamat,
      required this.editAlamat});

  @override
  State<AlamatCard> createState() => _AlamatCardState();
}

class _AlamatCardState extends State<AlamatCard> {
  Future<String> convertAlamat(String strLatitude, String strLongitude) async {
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
      return alamat;
    } else {
      CustomSnackBar.show(context, sukses: false,
            teks: "Tidak bisa Mengkonversi koordinat alamat anda",);
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF646363).withValues(alpha: 0.3),
                offset: const Offset(3.0, 3.0),
                blurRadius: 5.0)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Color(0xFF2F2828)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: widget.editAlamat,
                    child: Text(
                      "Edit Alamat",
                      style: AppColors.fontStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
            child: Text(
              widget.namaUser!,
              style: AppColors.fontStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 3),
            child: Text(
              widget.noTeleponUser!,
              style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
            child: FutureBuilder<String>(
              future: convertAlamat(widget.latitude, widget.longitude),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    "Loading...",
                    style: AppColors.fontStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  );
                } else {
                  return Text(
                    snapshot.data ?? "Alamat tidak ditemukan",
                    style: AppColors.fontStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  );
                }
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            child: Row(
              children: [
                widget.tipeAlamat == "Rumah"
                    ? Image.asset(
                        "assets/icons/icon-alamat-home.png",
                        scale: 2,
                      )
                    : Image.asset(
                        "assets/icons/alamat-kantor.png",
                        scale: 4,
                      ),
                const SizedBox(
                  width: 3,
                ),
                widget.tipeAlamat == "Rumah"
                    ? Text(
                        "Rumah",
                        style: AppColors.fontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      )
                    : Text(
                        "Kantor",
                        style: AppColors.fontStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
