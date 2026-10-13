import 'package:project_camp_sewa/services/api_client.dart';
// ignore_for_file: unused_local_variable
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog.dart';
import 'package:project_camp_sewa/components/dialog/network_error_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/constants/database_helper.dart';
import 'package:project_camp_sewa/layouts/layout_pembayaran.dart';
import 'package:project_camp_sewa/models/alamat_toko_checkout_model.dart';
import 'package:project_camp_sewa/models/bank_model.dart';
import 'package:project_camp_sewa/screens/screen_dashboard.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';
import 'package:project_camp_sewa/services/controller_dashboard.dart';

class ApiTransaksi extends GetxController {
  DashboardController pageController = Get.put(DashboardController());
  TextEditingController pesanController = TextEditingController();
  Dio dio = ApiClient().dio;
  var listProdukCheckout = <Map<String, dynamic>>[].obs;
  final RxList<BankModel> listBankMetodeBayar = <BankModel>[].obs;
  final Rx<AlamatTokoCheckoutModel?> alamatTokoCheckout =
      Rx<AlamatTokoCheckoutModel?>(null);

  final RxBool isLoadingBiayaAntar = false.obs;
  final RxBool layananAntarToko = true.obs;
  final RxInt tarifBiayaAntarToko = 0.obs;
  final RxString keteranganBiayaAntar = "".obs;
  final RxInt minimalGratisAntar = 0.obs;

  Future<void> getBiayaAntarToko(BuildContext context, String idToko) async {
    isLoadingBiayaAntar.value = true;
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getBiayaAntarToko}";

      final response = await dio.get(
        url,
        queryParameters: {'id_toko': idToko},
        options: Options(
          headers: header,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 && data['data'] != null) {
        final info = data['data'];
        layananAntarToko.value =
            info['layanan_antar'] == true || info['layanan_antar'] == 1;
        tarifBiayaAntarToko.value =
            int.tryParse(info['biaya_antar']?.toString() ?? '0') ?? 0;
        keteranganBiayaAntar.value = info['keterangan']?.toString() ?? "";
        minimalGratisAntar.value = int.tryParse(
                info['minimal_transaksi_gratis_antar']?.toString() ?? '0') ??
            0;
      } else {
        layananAntarToko.value = true;
        tarifBiayaAntarToko.value = 0;
        keteranganBiayaAntar.value = "";
        minimalGratisAntar.value = 0;
      }
    } catch (e) {
      layananAntarToko.value = true;
      tarifBiayaAntarToko.value = 0;
    } finally {
      isLoadingBiayaAntar.value = false;
    }
  }

  Future<void> transaksiCheckout(
      BuildContext context,
      String tanggalMulai,
      String tanggalSelesai,
      String metodeBayar,
      String totalPembayaran,
      String? bankTransfer,
      String? rekeningBank,
      int? idToko, {
      String opsiPengiriman = "Ambil Ditempat",
      int biayaAntar = 0,
      String? alamatPengiriman,
  }) async {
    //param totalPembayaran,bankTransfer,dan rekeningBank digunakan untuk mengirim argument ke LayoutPembayaran
    await getlistProdukCheckout(
        context); //mendapatkan list produk yang dicheckout
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.transaksiCheckout +
          idStr;

      Map<String, dynamic> body = {
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'metode': metodeBayar,
        'biaya_admin': 1000,
        'opsi_pengiriman': opsiPengiriman,
        'biaya_antar': biayaAntar,
        if (alamatPengiriman != null && alamatPengiriman.isNotEmpty)
          'alamat_pengiriman': alamatPengiriman,
        if (pesanController.text.isNotEmpty) 'pesan': pesanController.text,
        'produk_details': listProdukCheckout,
      };

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        int idPenyewaan = json['penyewaan']['id'];
        CustomSnackBar.show(context, sukses: true,
              teks: "Transaksi Berhasil Dibuat",);

        if (metodeBayar == "Transfer") {
          Get.to(const LayoutPembayaran(), arguments: {
            'id_penyewaan': idPenyewaan,
            'id_toko': idToko,
            'rekening_bank': rekeningBank,
            'total_pembayaran': totalPembayaran,
            'bank': bankTransfer
          });
        } else {
          pageController.setPageIndex(3);
          Get.to(const ScreenDashboard());
        }
        DatabaseHelper.instance.deleteKeranjangCheckout(context);
      } else {
        String errorMessage = json['error'];
        CustomSnackBar.show(context, sukses: false,
              teks: errorMessage,);
      }
    } on DioException catch (dioError) {
      if (context.mounted) {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.transparent,
                  content: CustomAlertDialog(
                    sukses: false,
                    teks: dioError.message ?? "An unknown error occurred",
                  ),
                );
              });
        }
      }
    }
  }

  Future<void> getlistProdukCheckout(BuildContext context) async {
    try {
      List<Map<String, dynamic>> produkCheckout =
          await DatabaseHelper.instance.listInputProdukCheckout(context);
      listProdukCheckout.assignAll(produkCheckout);
    } catch (e) {
      CustomSnackBar.show(context, sukses: false,
            teks: "Gagal Mengambil List Produk",);
    }
  }

  Future<void> getAlamatToko(BuildContext context, String idToko) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getAlamatTokoCheckout}";

      // Buat query parameters
      Map<String, String> queryParams = {};
      if (idToko.isNotEmpty) {
        queryParams['id_user'] = idToko;
      }

      // Tambahkan query parameters ke URL jika ada
      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        final List<dynamic> lokasiTokoList = data['lokasi_toko'];
        if (lokasiTokoList.isNotEmpty) {
          alamatTokoCheckout.value =
              AlamatTokoCheckoutModel.fromJson(lokasiTokoList[0]);
        }
      } else {
        String errorMessage = data['error'];
        CustomSnackBar.show(context, sukses: false,
              title: "Error",
              teks: errorMessage,);
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
                ),
              );
            });
      }
    }
  }

  Future<void> getBankOpsiPembayaran(
      BuildContext context, String idToko) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.getBankOpsiPembayaranTransfer;

      final response = await dio.get(
        url,
        queryParameters: {'id_user': idToko},
        options: Options(
          headers: header,
          validateStatus: (status) {
            return status! < 500; // Accept status codes less than 500
          },
        ),
      );

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        List<BankModel> bankList = List<BankModel>.from(
            data['bank'].map((e) => BankModel.fromJson(e)).toList());
        listBankMetodeBayar.assignAll(bankList);
      } else {
        if (context.mounted) {
          CustomSnackBar.show(context, sukses: false,
                title: "Error",
                teks: "Gagal Mendapatkan List Bank",);
        }
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
                ),
              );
            });
      }
    }
  }

  Future<void> transaksiPembayaran(BuildContext context, String idTransaksi, String idToko, String totalBayar,
      XFile buktiPembayaran, XFile jaminanSewa) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.transaksiPembayaran;

      FormData formData = FormData.fromMap({
        'id_toko': idToko,
        'id_penyewaan': idTransaksi,
        'jumlah_pembayaran': totalBayar,
        'kembalian_pembayaran': "0",
        'biaya_admin': "1000",
        'kurang_pembayaran': "0",
        'total_pembayaran': totalBayar,
        'bukti_pembayaran': await MultipartFile.fromFile(buktiPembayaran.path,
            filename: "$idTransaksi-${buktiPembayaran.path.split('/').last}"),
        'jaminan_sewa': await MultipartFile.fromFile(jaminanSewa.path,
            filename: "$idTransaksi-${jaminanSewa.path.split('/').last}"),
      });

      final response = await dio.post(url,
          data: formData,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 201) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: true,
                  title: "Menunggu Verifikasi",
                  teks: "Pembayaran berhasil dikirim. Bukti transfer dan KTP Anda sedang diverifikasi oleh pihak toko. Mohon tunggu beberapa saat, pesanan Anda akan segera diproses.",
                ),
              );
            },
          ).then((_) {
            pageController.setPageIndex(3);
            Get.offAll(() => const ScreenDashboard());
          });
        }
      } else {
        CustomSnackBar.show(context, sukses: false,
              title: "Error",
              teks: "Gagal Mendapatkan List Bank",);
      }
    } on DioException catch (dioError) {
      if (NetworkErrorDialog.isNetworkOrServerError(dioError)) return;
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: CustomAlertDialog(
                  sukses: false,
                  teks: dioError.message ?? "An unknown error occurred",
                ),
              );
            });
      }
    }
  }
}

