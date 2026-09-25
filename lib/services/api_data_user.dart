import 'package:project_camp_sewa/services/api_client.dart';
// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:project_camp_sewa/components/dialog/alert_dialog.dart';
import 'package:project_camp_sewa/components/dialog/loading_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/alamat_model.dart';
import 'package:project_camp_sewa/models/user.dart';
import 'package:project_camp_sewa/services/api_transaksi.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';
import 'package:project_camp_sewa/services/controller_dashboard.dart';

class ApiDataUser extends GetxController {
  ApiTransaksi apiTransaksi = Get.put(ApiTransaksi());
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController jenisKelaminController = TextEditingController();
  TextEditingController detailAlamatController = TextEditingController();
  TextEditingController namaTokoController = TextEditingController();
  TextEditingController detailAlamatTokoController = TextEditingController();
  TextEditingController deskripsiTokoController = TextEditingController();
  TextEditingController noRekController = TextEditingController();
  TextEditingController jenisBankController = TextEditingController();
  Dio dio = ApiClient().dio;
  LoadingDialog loading = Get.put(LoadingDialog());
  DashboardController pageController = Get.put(DashboardController());
  final Rx<User?> dataUser = Rx<User?>(null);
  final RxList<AlamatUserModel> listAlamatUser = <AlamatUserModel>[].obs;

  // Statistik
  final RxInt totalSemuaPesanan = 0.obs;
  final RxInt totalSedangDisewa = 0.obs;
  final RxInt totalBelumDikonfirmasi = 0.obs;
  final RxInt totalProdukBelumDikonfirmasi = 0.obs;

  Future<void> getStatistikPesanan(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      if (id == null) return;

      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.getStatistikPesanan +
          id.toString();

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) => status! < 500,
          ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data is String ? jsonDecode(response.data) : response.data;
        if (responseData['message'] == 'success' &&
            responseData['data'] != null) {
          totalSemuaPesanan.value =
              responseData['data']['total_semua_pesanan'] ?? 0;
          totalSedangDisewa.value =
              responseData['data']['total_sedang_disewa'] ?? 0;
          totalBelumDikonfirmasi.value =
              responseData['data']['total_belum_dikonfirmasi'] ?? 0;
          totalProdukBelumDikonfirmasi.value =
              responseData['data']['total_produk_belum_dikonfirmasi'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint("Error fetching statistik: $e");
    }
  }

  Future<void> getDataUser(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.getDataUser + idStr;

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
        // listDataUser =
        //     List.from(dataUser['user']).map((e) => User.fromJson(e)).toList();

        // ?? Debug: lihat semua key yang mengandung "foto" dari response mentah
        final rawUser = data['data_users'];
        print("\x1B[35mDEBUG raw keys: ${rawUser.keys.toList()}\x1B[0m");
        print(
            "\x1B[35mDEBUG raw foto-related: ${rawUser.entries.where((e) => e.key.toString().toLowerCase().contains('foto')).toList()}\x1B[0m");

        dataUser.value = User.fromJson(data['data_users']);
        final User? attachData = dataUser.value;

        // ?? Debug sementara
        print("\x1B[35mDEBUG fotoToko: ${attachData?.fotoToko}\x1B[0m");
        print("\x1B[35mDEBUG bannerToko: ${attachData?.bannerToko}\x1B[0m");

        namaController.text = attachData!.name!;
        emailController.text = attachData.email!;
        phoneNumberController.text = attachData.nomorTelephone!;
        tanggalLahirController.text = attachData.tanggalLahir!;
        jenisKelaminController.text = attachData.jenisKelamin ?? '';

        // Ambil statistik setelah berhasil dapat data user
        await getStatistikPesanan(context);
      } else {
        String errorMessage = data['message'];
        CustomSnackBar.show(
          context,
          sukses: false,
          title: "Error",
          teks: errorMessage,
        );
      }
    } on DioException catch (dioError) {
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

  Future<void> updateProfile(BuildContext context, XFile? photoProfile) async {
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
          ApiEndpoints.authendpoints.updateDataUser +
          idStr;
      FormData formData = FormData.fromMap({
        'name': namaController.text,
        'email': emailController.text.trim(),
        'nomor_telephone': phoneNumberController.text,
        'tanggal_lahir': tanggalLahirController.text,
        'jenis_kelamin': jenisKelaminController.text,
        if (photoProfile != null)
          'foto': await MultipartFile.fromFile(photoProfile.path,
              filename: "$idStr-${photoProfile.path.split('/').last}"),
      });

      final response = await dio.post(url,
          data: formData,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! <= 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: "Profile Berhasil di Update",
        );

        namaController.clear();
        emailController.clear();
        phoneNumberController.clear();
        tanggalLahirController.clear();
        if (context.mounted) {
          pageController.setPageIndex(3);
          getDataUser(context);
          Get.back();
        }
      } else {
        String errorMessage = json['message'];
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
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

  Future<void> tambahAlamatUser(BuildContext context, String latitude,
      String longitude, String type) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.tambahAlamatUser;
      Map body = {
        'id_user': idStr,
        'longitude': longitude,
        'latitude': latitude,
        if (detailAlamatController.text.isNotEmpty)
          'detail_lainnya': detailAlamatController.text,
        if (type == "Rumah") 'type': 0 else 'type': 2
      };

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! <= 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: "Berhasil Menambahkan Alamat",
        );

        if (context.mounted) {
          //get data alamat supaya memperbarui data di layout alamat
          getListAlamatUser(context);
          Get.back();
        }
      } else {
        String errorMessage = json['error'];
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
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

  Future<void> getListAlamatUser(BuildContext context) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          "${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getAlamatUser}$idStr";

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
        List<AlamatUserModel> alamatList = List<AlamatUserModel>.from(
            data['alamat_user']
                .map((e) => AlamatUserModel.fromJson(e))
                .toList());
        listAlamatUser.assignAll(alamatList);
      } else {
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: "Data Produk Gagal Dimuat",
        );
      }
    } on DioException catch (dioError) {
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

  Future<void> updateAlamatUser(BuildContext context, String idAlamat,
      String latitude, String longitude, String type) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.updateAlamatUser +
          idAlamat;

      Map body = {
        'longitude': longitude,
        'latitude': latitude,
        if (detailAlamatController.text.isNotEmpty)
          'detail_lainnya': detailAlamatController.text,
        if (type == "Rumah") 'type': 0 else 'type': 2
      };

      final response = await dio.put(url,
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
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: "Profile Berhasil di Update",
        );

        if (context.mounted) {
          getListAlamatUser(context);
          Get.back();
        }
      } else {
        String errorMessage = json['message'];
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
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

  Future<void> deleteAlamatUser(BuildContext context, String idAlamat) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.deleteAlamatUser +
          idAlamat;

      final response = await dio.delete(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500; // Accept status codes less than 500
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: "Alamat Berhasil Dihapus",
        );

        if (context.mounted) {
          getListAlamatUser(context);
          Get.back();
        }
      } else {
        String errorMessage = json['message'];
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
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

  Future<void> tambahBankMetodeTransfer(BuildContext context) async {
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
          ApiEndpoints.authendpoints.tambahBankMetodeTransfer;

      Map body = {
        'id_user': idStr,
        'rekening': noRekController.text,
        'bank': jenisBankController.text,
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
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: "Berhasil Menambahkan Metode Transfer",
        );

        if (context.mounted) {
          apiTransaksi.getBankOpsiPembayaran(context, idStr);
          Get.back();
        }
      } else {
        String errorMessage = json['message'];
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
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

  Future<void> isiDataToko(
      BuildContext context, String latitude, String longitude,
      {String? bannerPath, String? fotoTokoPath}) async {
    try {
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.isiDataToko + idStr;

      Map<String, dynamic> body = {
        'name_store': namaTokoController.text,
        'longitude': longitude,
        'latitude': latitude,
        'detail_lainnya': detailAlamatTokoController.text,
        'deskripsi_toko': deskripsiTokoController.text,
      };

      if (bannerPath != null && bannerPath.isNotEmpty) {
        body['banner_toko'] = await MultipartFile.fromFile(
          bannerPath,
          filename: bannerPath.split('/').last,
        );
      }
      if (fotoTokoPath != null && fotoTokoPath.isNotEmpty) {
        body['foto_toko'] = await MultipartFile.fromFile(
          fotoTokoPath,
          filename: fotoTokoPath.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(body);

      final response = await dio.post(url,
          data: formData,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500;
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: "Berhasil Menambahkan Data Toko",
        );

        if (context.mounted) {
          namaTokoController.clear();
          detailAlamatTokoController.clear();
          deskripsiTokoController.clear();
          Get.back();
        }
      } else {
        String errorMessage = json['message'] ?? 'Terjadi kesalahan';
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
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

  Future<bool> verifyKTP(BuildContext context, String filePath) async {
    try {
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ',
      };

      var url = ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.verifyKTP;

      FormData formData = FormData.fromMap({
        'foto_identitas': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: header,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        return true;
      } else {
        CustomSnackBar.show(context,
            sukses: false, teks: json['message'] ?? 'KTP ditolak oleh sistem');
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(context,
            sukses: false, teks: 'Terjadi kesalahan saat verifikasi KTP');
      }
      return false;
    }
  }

  Future<void> inputKYC(
      BuildContext context, String nomorIdentitas, XFile? fotoIdentitas) async {
    try {
      loading.showLoadingDialog();
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var url =
          ApiEndpoints.baseUrl + ApiEndpoints.authendpoints.inputKYC + idStr;

      Map<String, dynamic> body = {
        'nomor_identitas': nomorIdentitas,
      };

      if (fotoIdentitas != null) {
        body['foto_identitas'] = await MultipartFile.fromFile(
          fotoIdentitas.path,
          filename: fotoIdentitas.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(body);

      final response = await dio.post(url,
          data: formData,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500;
            },
          ));

      loading.hideLoadingDialog();

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        CustomSnackBar.show(
          context,
          sukses: true,
          teks: "Identitas Berhasil Diverifikasi",
        );

        if (context.mounted) {
          await getDataUser(context);
          pageController.setPageIndex(3);
          Get.back();
        }
      } else {
        String errorMessage = json['message'] ?? 'Terjadi kesalahan';
        CustomSnackBar.show(
          context,
          sukses: false,
          teks: errorMessage,
        );
      }
    } on DioException catch (dioError) {
      loading.hideLoadingDialog();
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

  Future<void> updateBankMetodeTransfer(
      BuildContext context, String bankId) async {
    try {
      Authorization auth = Authorization();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ',
      };

      var url = "/api/user/update-bank/";

      Map body = {
        'rekening': noRekController.text,
        'bank': jenisBankController.text,
      };

      final response = await dio.post(url,
          data: body,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500;
            },
          ));

      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200) {
        CustomSnackBar.show(context,
            sukses: true, teks: "Berhasil Mengubah Metode Transfer");

        if (context.mounted) {
          apiTransaksi.getBankOpsiPembayaran(context, idStr);
          Get.back();
        }
      } else {
        CustomSnackBar.show(context,
            sukses: false, teks: json['message'] ?? "Gagal mengubah data");
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(context,
            sukses: false, teks: "Terjadi kesalahan Saat Update Bank");
      }
    }
  }

  Future<void> deleteBankMetodeTransfer(
      BuildContext context, String bankId) async {
    try {
      Authorization auth = Authorization();
      int? id = await auth.getId();
      String idStr = id.toString();
      var header = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ',
      };

      var url = "/api/user/delete-bank/";

      final response = await dio.get(url,
          options: Options(
            headers: header,
            validateStatus: (status) {
              return status! < 500;
            },
          ));

      if (response.statusCode == 200) {
        CustomSnackBar.show(context,
            sukses: true, teks: "Berhasil Menghapus Metode Transfer");

        if (context.mounted) {
          apiTransaksi.getBankOpsiPembayaran(context, idStr);
          Get.back();
        }
      } else {
        CustomSnackBar.show(context,
            sukses: false, teks: "Gagal menghapus data");
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(context,
            sukses: false, teks: "Terjadi kesalahan Saat Hapus Bank");
      }
    }
  }

  Future<bool> updateInformasiToko(
    BuildContext context, {
    String? nameStore,
    String? deskripsiToko,
    String? bannerPath,
    String? fotoTokoPath,
  }) async {
    try {
      print("\x1B[33m=== START UPDATE INFORMASI TOKO ===\x1B[0m");
      Authorization auth = Authorization();
      String? token = await auth.getToken();
      int? id = await auth.getId();
      var url = ApiEndpoints.baseUrl +
          ApiEndpoints.authendpoints.isiDataToko +
          id.toString();
      print("\x1B[36mURL: $url\x1B[0m");

      Map<String, dynamic> body = {};
      if (nameStore != null) body['name_store'] = nameStore;
      if (deskripsiToko != null) body['deskripsi_toko'] = deskripsiToko;

      if (bannerPath != null && bannerPath.isNotEmpty) {
        body['banner_toko'] = await MultipartFile.fromFile(bannerPath,
            filename: bannerPath.split('/').last);
        print("\x1B[36mAttach Banner: $bannerPath\x1B[0m");
      }
      if (fotoTokoPath != null && fotoTokoPath.isNotEmpty) {
        body['foto_toko'] = await MultipartFile.fromFile(fotoTokoPath,
            filename: fotoTokoPath.split('/').last);
        print("\x1B[36mAttach Foto Toko: $fotoTokoPath\x1B[0m");
      }

      print("\x1B[36mBody payload keys: ${body.keys.toList()}\x1B[0m");

      final response = await dio.post(
        url,
        data: FormData.fromMap(body),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print("\x1B[32m=== RESPONSE UPDATE INFORMASI TOKO ===\x1B[0m");
      print("\x1B[32mStatus Code: ${response.statusCode}\x1B[0m");
      print("\x1B[32mData: ${response.data}\x1B[0m");

      if (response.statusCode == 200) {
        await getDataUser(context);
        return true;
      }
      return false;
    } catch (e) {
      print("\x1B[31m=== ERROR EXCEPTION UPDATE INFORMASI TOKO ===\x1B[0m");
      if (e is DioException) {
        print("\x1B[31mStatus Code: ${e.response?.statusCode}\x1B[0m");
        print("\x1B[31mResponse Data: ${e.response?.data}\x1B[0m");
      } else {
        print("\x1B[31mError: $e\x1B[0m");
      }
      return false;
    }
  }
}
