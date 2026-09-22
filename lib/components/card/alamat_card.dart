import 'package:project_camp_sewa/theme_colors.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
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
  static const Color _forest = Color(0xFF2C4E40);
  static const Color _dark = Color(0xFF2F2828);

  Future<String> convertAlamat(String strLatitude, String strLongitude) async {
    double latitude = double.parse(strLatitude);
    double longitude = double.parse(strLongitude);
    List<Placemark> placemarks =
        await Geocoding().placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String jalan = placemark.street ?? '';
      String kecamatan = placemark.subLocality ?? '';
      String kabupaten = placemark.locality ?? '';
      String provinsi = placemark.administrativeArea ?? '';
      String postalCode = placemark.postalCode ?? '';
      String alamat = "$jalan, $kecamatan, $kabupaten, $provinsi, $postalCode";
      return alamat;
    } else {
      CustomSnackBar.show(
        context,
        sukses: false,
        teks: "Tidak bisa Mengkonversi koordinat alamat anda",
      );
      return "";
    }
  }

  bool get _isRumah => widget.tipeAlamat == "Rumah";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: _dark.withValues(alpha: 0.05),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _forest.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isRumah
                    ? MdiIcons.homeVariantOutline
                    : MdiIcons.officeBuildingOutline,
                color: _forest,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.namaUser ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFC107).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isRumah ? "Rumah" : "Kantor",
                          style: AppColors.fontStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB07C00),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Phone
                  Text(
                    widget.noTeleponUser ?? "",
                    style: AppColors.fontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1.5),
                        child: Icon(MdiIcons.mapMarkerOutline,
                            size: 14, color: Colors.grey.shade400),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: FutureBuilder<String>(
                          future:
                              convertAlamat(widget.latitude, widget.longitude),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                "Memuat alamat...",
                                style: AppColors.fontStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            }
                            return Text(
                              snapshot.data?.isNotEmpty == true
                                  ? snapshot.data!
                                  : "Alamat tidak ditemukan",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppColors.fontStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit button
            InkWell(
              onTap: widget.editAlamat,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(MdiIcons.pencilOutline, size: 16, color: _dark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
