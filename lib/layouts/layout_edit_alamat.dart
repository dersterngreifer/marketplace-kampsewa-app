import 'package:project_camp_sewa/theme_colors.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
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
    } else {
      CustomSnackBar.show(
        context,
        sukses: false,
        teks: "Tidak bisa Mengkonversi koordinat alamat anda",
      );
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
      CustomSnackBar.show(
        context,
        sukses: false,
        teks: "Tidak bisa Mengkonversi koordinat alamat anda",
      );
    }
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
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2F2828), size: 24),
        ),
        title: Text(
          widget.edit ? "Edit Alamat" : "Alamat Baru",
          style: AppColors.fontStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F2828),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Kontak"),
                    _buildTextField(
                      controller: namaLengkapController,
                      hintText: "Nama Lengkap",
                      enabled: false,
                      icon: MdiIcons.accountOutline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: noTeleponController,
                      hintText: "Nomor Telepon Aktif",
                      enabled: false,
                      icon: MdiIcons.phoneOutline,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle("Lokasi"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: alamatController,
                            hintText: "Provinsi, Kota, Kecamatan, Kode Pos",
                            enabled: false,
                            icon: MdiIcons.mapMarkerOutline,
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => getLocation(),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 56, // Match the typical text field height
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF407BFF)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF407BFF)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(MdiIcons.crosshairsGps,
                                    color: Color(0xFF407BFF), size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  "Lacak",
                                  style: AppColors.fontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF407BFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: apiDataUser.detailAlamatController,
                      hintText:
                          "Detail Lainnya (Contoh: Nama Jalan, Blok, No Rumah)",
                      icon: MdiIcons.homeCityOutline,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle("Tandai Sebagai"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            title: "Rumah",
                            iconOn: "assets/icons/alamat-home-selected.png",
                            iconOff: "assets/icons/alamat-home.png",
                            isSelected: ditandaiSebagai == "Rumah",
                            onTap: () =>
                                setState(() => ditandaiSebagai = "Rumah"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTypeButton(
                            title: "Kantor",
                            iconOn: "assets/icons/alamat-office-selected.png",
                            iconOff: "assets/icons/alamat-kantor.png",
                            isSelected: ditandaiSebagai == "Kantor",
                            onTap: () =>
                                setState(() => ditandaiSebagai = "Kantor"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40), // Bottom padding for scroll
                  ],
                ),
              ),
            ),

            // Bottom Action Area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      if (latitude != null && longitude != null) {
                        if (widget.edit) {
                          apiDataUser.updateAlamatUser(
                              context,
                              widget.idAlamat!,
                              latitude!,
                              longitude!,
                              ditandaiSebagai);
                        } else {
                          apiDataUser.tambahAlamatUser(
                              context, latitude!, longitude!, ditandaiSebagai);
                        }
                      } else {
                        CustomSnackBar.show(context,
                            sukses: false,
                            teks:
                                "Lokasi belum dilacak. Silakan tekan tombol Lacak!");
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF407BFF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF407BFF).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Simpan Alamat",
                          style: AppColors.fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.edit) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => apiDataUser.deleteAlamatUser(
                          context, widget.idAlamat!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFEE2737)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            "Hapus Alamat",
                            style: AppColors.fontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEE2737),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppColors.fontStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2F2828),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
    required IconData icon,
    int? maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines != 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines != 1 ? 12 : 0, right: 12),
            child: Icon(icon, color: Colors.grey.shade500, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: AppColors.fontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2F2828),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppColors.fontStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required String iconOn,
    required String iconOff,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF407BFF).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF407BFF) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? iconOn : iconOff,
              height: 36,
              color:
                  isSelected ? const Color(0xFF407BFF) : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppColors.fontStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color:
                    isSelected ? const Color(0xFF407BFF) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
