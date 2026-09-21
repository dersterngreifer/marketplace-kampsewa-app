import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/services/api_transaksi.dart';

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
    jaminanSewa = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                  width: MediaQuery.of(context).size.width / 4 - 25,
                ),
                Text(
                  "Pembayaran",
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
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Text(
                    "Total Pembayaran",
                    style: AppColors.fontStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  const Spacer(),
                  Text(
                    "IDR. ",
                    style: AppColors.fontStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  Text(
                    totalPembayaran != null
                        ? formatCurrency(totalPembayaran!)
                        : "0", //total pembayaran
                    style: AppColors.fontStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  Text(
                    ",00",
                    style: AppColors.fontStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              height: 2,
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.black.withValues(alpha: 0.25),
                        width: 1.2)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFF2F2828),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(
                            MdiIcons.bank,
                            size: 28,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            bank != null ? bank! : "bank - ", //bank
                            style: AppColors.fontStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 15, top: 8),
                    child: Text(
                      "Nomor Rekening",
                      style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 15, top: 5),
                    child: Text(
                      rekeningBank != null
                          ? rekeningBank!
                          : "000 000 000", //nomor rekening
                      style: AppColors.fontStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 15, top: 15),
                    child: Text(
                      "Bayar pesanan ke No. Rek di atas yang sudah tertera. Harap menyelesaikan pembayaran untuk melanjutkan pesanan anda",
                      style: AppColors.fontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25, right: 15, top: 14, bottom: 12),
                    child: Text(
                      "Menerima Transfer Bank Lainnya",
                      style: AppColors.fontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15, right: 10, top: 8, bottom: 5),
              child: Text(
                "Petunjuk Transfer M-Banking",
                style: AppColors.fontStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 10,
              ),
              child: Text(
                "1. Masuk ke menu Mobile Banking \n2. Pilih Menu tranfer \n3. Masukkan No. Rek yang sudah tertera \n4. Masukkan Nominal Pembayaran, lalu klik lanjutkan \n5. Klik konfirmasi, lalu masukkan pin mBanking anda",
                style: AppColors.fontStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              height: 1.2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 10, top: 15, bottom: 3),
              child: Row(
                children: [
                  Text(
                    "Bukti Pembayaran",
                    style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  Text(
                    "*",
                    style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black.withValues(alpha: 0.5), width: 1.2),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          //upload bukti pembayaran
                          await checkPermissions();
                          await pickedBuktiPembayaran();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withValues(alpha: 0.2)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.5, horizontal: 20),
                              child: Text(
                                "Pilih File",
                                style: AppColors.fontStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: Text(
                          buktiPembayaran != null
                              ? buktiPembayaran!.name
                              : "Upload Bukti Pembayaran", //nama file bukti pembayaran
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "*Wajib Diisi Untuk Melanjutkan",
                    style: AppColors.fontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEE2737)),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 3),
              child: Row(
                children: [
                  Text(
                    "Jaminan KTP/KTM/SIM",
                    style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  Text(
                    "*",
                    style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black.withValues(alpha: 0.5), width: 1.2),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          //upload jaminan
                          await checkPermissions();
                          await pickedJaminanSewa();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withValues(alpha: 0.2)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.5, horizontal: 20),
                              child: Text(
                                "Pilih File",
                                style: AppColors.fontStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: Text(
                          jaminanSewa != null
                              ? jaminanSewa!.name
                              : "Upload Jaminan", //nama file jaminan
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppColors.fontStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "*Wajib Diisi Untuk Melanjutkan",
                    style: AppColors.fontStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEE2737)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: InkWell(
                onTap: () {
                  //konfirmasi
                  if (buktiPembayaran != null && jaminanSewa != null) {
                    apiTransaksi.transaksiPembayaran(
                        context,
                        idPenyewaan!.toString(),
                        idToko!.toString(),
                        totalPembayaran!,
                        buktiPembayaran!,
                        jaminanSewa!);
                  } else {
                    CustomSnackBar.show(context, sukses: false,
                          title: "Pembayaran Gagal",
                          teks:
                              "Upload Bukti Pembayaran dan Jaminan Sewa Terlebih Dahulu!",);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF2F2828)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 18),
                      child: Text(
                        "Selesaikan Transaksi",
                        style: AppColors.fontStyle(
                            fontSize: 16,
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
