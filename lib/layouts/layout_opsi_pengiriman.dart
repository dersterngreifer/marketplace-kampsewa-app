import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
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
    if(apiDataUser.listAlamatUser.isNotEmpty) {
      AlamatUserModel alamat = apiDataUser.listAlamatUser[0];
      double longitude = double.parse(alamat.longitude);
      double latitude = double.parse(alamat.latitude);
      String convertedAlamat = await convertAlamat(latitude, longitude);
      alamatUser.value = convertedAlamat;
    } else {
      alamatUser.value = "Alamat belum diatur";
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
      CustomSnackBar.show(context, sukses: false, teks: "Tidak bisa Mengkonversi koordinat alamat anda");
      return "";
    }
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Widget addressWidget,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isSelected ? Colors.blue[700] : Colors.grey[600], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppColors.fontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: Colors.blue[700], size: 24)
                else
                  Icon(Icons.radio_button_unchecked, color: Colors.grey[400], size: 24),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              addressWidget,
            ],
          ],
        ),
      ),
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
          "Opsi Pengiriman",
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
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    "Pilih Jasa Pengiriman",
                    style: AppColors.fontStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Barang akan dikirim ke alamat Anda atau diambil langsung di store penyewa.",
                    style: AppColors.fontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildOptionCard(
                    title: "Ambil Ditempat",
                    subtitle: "Ambil langsung ke lokasi store",
                    price: "Gratis (Rp 0)",
                    icon: MdiIcons.storefrontOutline,
                    isSelected: selectedOption == "ambil",
                    onTap: () => setState(() => selectedOption = "ambil"),
                    addressWidget: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(MdiIcons.mapMarkerOutline, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Alamat Store", style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                alamatToko.value,
                                style: AppColors.fontStyle(fontSize: 13, color: Colors.black54),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildOptionCard(
                    title: "Antar Ke Alamatmu",
                    subtitle: "Dikirim oleh kurir",
                    price: "Mulai dari Rp 5.000",
                    icon: MdiIcons.truckDeliveryOutline,
                    isSelected: selectedOption == "antar",
                    onTap: () => setState(() => selectedOption = "antar"),
                    addressWidget: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(MdiIcons.mapMarkerOutline, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Alamat Pengiriman", style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                alamatUser.value,
                                style: AppColors.fontStyle(fontSize: 13, color: Colors.black54),
                              )),
                            ],
                          ),
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.edit_outlined, color: Colors.blue[700], size: 20),
                        //   onPressed: () {},
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedOption == "antar") {
                    CustomSnackBar.show(context, sukses: false, title: "Fitur Segera Tersedia", teks: "Maaf Fitur Pengantaran Belum Tersedia");
                  } else {
                    Get.back(
                      result: selectedOption == "antar"
                        ? {'selectedOption': "Antar Ke Alamatmu", 'alamat': alamatUser.value}
                        : {'selectedOption': "Ambil Ditempat", 'alamat': alamatToko.value}
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F2828),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  "Konfirmasi",
                  style: AppColors.fontStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
