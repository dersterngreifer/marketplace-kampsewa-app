import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/components/card/alamat_card.dart';
import 'package:project_camp_sewa/layouts/layout_edit_alamat.dart';
import 'package:project_camp_sewa/models/alamat_model.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';

class LayoutAlamat extends StatefulWidget {
  const LayoutAlamat({super.key});

  @override
  State<LayoutAlamat> createState() => _LayoutAlamatState();
}

class _LayoutAlamatState extends State<LayoutAlamat> {
  ApiDataUser apiDataUser = Get.put(ApiDataUser());

  static const Color _forest = Color(0xFF2C4E40);
  static const Color _dark = Color(0xFF2F2828);

  @override
  void initState() {
    super.initState();
    apiDataUser.getListAlamatUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _dark, size: 16),
          ),
        ),
        title: Text(
          "Alamat Saya",
          style: AppColors.fontStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                List<AlamatUserModel> listAlamatUser =
                    apiDataUser.listAlamatUser;

                if (listAlamatUser.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: _forest.withValues(alpha: 0.07),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            MdiIcons.mapMarkerOffOutline,
                            size: 40,
                            color: _forest.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Belum ada alamat tersimpan",
                          style: AppColors.fontStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tambahkan alamat untuk\nmempermudah pengiriman pesananmu",
                          textAlign: TextAlign.center,
                          style: AppColors.fontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemBuilder: (context, index) {
                    AlamatUserModel listAlamat = listAlamatUser[index];
                    return AlamatCard(
                      editAlamat: () {
                        Get.to(() => LayoutEditAlamat(
                              edit: true,
                              idAlamat: listAlamat.id.toString(),
                              namaLengkap: listAlamat.name,
                              noTelepon: listAlamat.nomorTelephone,
                              ditandaiSebagai: listAlamat.type,
                              latitude: listAlamat.latitude,
                              longitude: listAlamat.longitude,
                              detailAlamat: listAlamat.detailLainnya ?? "",
                            ));
                      },
                      namaUser: listAlamat.name,
                      latitude: listAlamat.latitude,
                      longitude: listAlamat.longitude,
                      noTeleponUser: listAlamat.nomorTelephone,
                      tipeAlamat: listAlamat.type,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemCount: listAlamatUser.length,
                );
              }),
            ),

            // Bottom action
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF8),
                border: Border(
                  top: BorderSide(color: Colors.black.withValues(alpha: 0.04)),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Get.to(() => const LayoutEditAlamat(edit: false));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: _forest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _forest.withValues(alpha: 0.25),
                        offset: const Offset(0, 8),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        MdiIcons.plus,
                        size: 22,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tambah Alamat Baru",
                        style: AppColors.fontStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
