import 'dart:io';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/services/api_transaksi.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';

class LayoutPembayaran extends StatefulWidget {
  const LayoutPembayaran({super.key});

  @override
  State<LayoutPembayaran> createState() => _LayoutPembayaranState();
}

class _LayoutPembayaranState extends State<LayoutPembayaran> {
  ApiTransaksi apiTransaksi = Get.put(ApiTransaksi());
  int? idPenyewaan;
  int? idToko;
  String? rekeningBank;
  String? totalPembayaran;
  String? bank;
  XFile? buktiPembayaran;
  XFile? jaminanSewa;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
    idPenyewaan = arguments['id_penyewaan'];
    idToko = arguments['id_toko'];
    rekeningBank = arguments['rekening_bank'];
    totalPembayaran = arguments['total_pembayaran'];
    bank = arguments['bank'];
  }

  String formatCurrency(String numberString) {
    final number = int.parse(numberString);
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  }

  checkPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.camera,
      Permission.storage,
    ].request();
    if (status[Permission.camera] != PermissionStatus.granted ||
        status[Permission.storage] != PermissionStatus.granted) {
      return;
    }
  }

  pickedBuktiPembayaran() async {
    final picker = ImagePicker();
    buktiPembayaran = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  pickedJaminanSewa() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2C4E40)));
        },
      );

      ApiDataUser apiDataUser = ApiDataUser();
      bool isKtpValid = await apiDataUser.verifyKTP(context, pickedFile.path);
      
      Navigator.pop(context); // Close loading dialog

      if (isKtpValid) {
        jaminanSewa = pickedFile;
      } else {
        CustomSnackBar.show(context, sukses: false, title: "Verifikasi Ditolak", teks: "Sistem mendeteksi gambar tersebut bukan KTP. Harap unggah KTP asli.");
        jaminanSewa = null;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Pembayaran",
          style: AppColors.fontStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 22),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Text("Total Pembayaran", style: AppColors.fontStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text(
                          "Rp ${totalPembayaran != null ? formatCurrency(totalPembayaran!) : '0'}",
                          style: AppColors.fontStyle(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFFEE2737)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C4E40).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(MdiIcons.bank, color: Color(0xFF2C4E40), size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bank ?? "Bank Transfer",
                                    style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    rekeningBank ?? "000 000 000",
                                    style: AppColors.fontStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
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

                  // Upload Section Title
                  Text(
                    "Verifikasi Pembayaran",
                    style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Harap sertakan bukti transfer dan jaminan identitas Anda.",
                    style: AppColors.fontStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // Upload Boxes
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadBox(
                          title: "Bukti Transfer",
                          file: buktiPembayaran,
                          onTap: () async {
                            await checkPermissions();
                            await pickedBuktiPembayaran();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUploadBox(
                          title: "Foto KTP Asli",
                          file: jaminanSewa,
                          onTap: () async {
                            await checkPermissions();
                            await pickedJaminanSewa();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Guidelines
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Colors.blue[700], size: 18),
                            const SizedBox(width: 8),
                            Text("Petunjuk M-Banking", style: AppColors.fontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blue[800])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "1. Buka aplikasi Mobile Banking Anda.\n2. Masukkan nomor rekening tujuan di atas.\n3. Masukkan nominal sesuai Total Pembayaran.\n4. Simpan resi (screenshot) dan upload di sini.",
                          style: AppColors.fontStyle(fontSize: 12, color: Colors.blue[900], height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (buktiPembayaran != null && jaminanSewa != null) {
                  final List<String> validExtensions = ['jpg', 'jpeg', 'png'];
                  final String extBukti = buktiPembayaran!.path.split('.').last.toLowerCase();
                  final String extJaminan = jaminanSewa!.path.split('.').last.toLowerCase();

                  if (!validExtensions.contains(extBukti) || !validExtensions.contains(extJaminan)) {
                    CustomSnackBar.show(context, sukses: false, title: "Format Tidak Valid", teks: "Pastikan file berformat JPG atau PNG");
                    return;
                  }

                  apiTransaksi.transaksiPembayaran(
                      context,
                      idPenyewaan!.toString(),
                      idToko!.toString(),
                      totalPembayaran!,
                      buktiPembayaran!,
                      jaminanSewa!);
                } else {
                  CustomSnackBar.show(context, sukses: false, title: "Pembayaran Gagal", teks: "Upload Bukti Pembayaran dan Jaminan Sewa Terlebih Dahulu!");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C4E40),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Center(
                child: Text(
                  "Selesaikan Transaksi",
                  style: AppColors.fontStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox({required String title, required XFile? file, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
            Text(" *", style: AppColors.fontStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: file == null ? Colors.grey.shade300 : const Color(0xFF2C4E40), width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: file != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(file.path), fit: BoxFit.cover),
                      Container(color: Colors.black.withOpacity(0.3)),
                      const Center(child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 32)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade400, size: 32),
                      const SizedBox(height: 8),
                      Text("Ketuk untuk\nupload", textAlign: TextAlign.center, style: AppColors.fontStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
