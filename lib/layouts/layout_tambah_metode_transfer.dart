import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';

class LayoutTambahMetodeTransfer extends StatefulWidget {
  final bool edit;
  final String? bankId;
  final String? noRek;
  final String? jenisBank;
  const LayoutTambahMetodeTransfer({super.key, this.edit = false, this.bankId, this.noRek, this.jenisBank});

  @override
  State<LayoutTambahMetodeTransfer> createState() =>
      _LayoutTambahMetodeTransferState();
}

class _LayoutTambahMetodeTransferState
    extends State<LayoutTambahMetodeTransfer> {
  ApiDataUser apiDataUser = Get.put(ApiDataUser());

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2F2828), size: 24),
        ),
        title: Text(
          widget.edit ? "Edit Metode Transfer" : "Tambah Metode Transfer",
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30, top: 10),
                        child: Image.asset(
                          "assets/images/kartu-metode-pembayaran.png",
                          height: 120,
                        ),
                      ),
                    ),
                    
                    _buildSectionTitle("No Rekening"),
                    _buildTextField(
                      controller: apiDataUser.noRekController,
                      hintText: "Masukkan Nomor Rekening",
                      icon: MdiIcons.numeric,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildSectionTitle("Jenis Bank"),
                    _buildTextField(
                      controller: apiDataUser.jenisBankController,
                      hintText: "Contoh: BCA / Mandiri / Dana",
                      icon: MdiIcons.bankOutline,
                    ),
                    const SizedBox(height: 40),
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
                      if (widget.edit) {
                        apiDataUser.updateBankMetodeTransfer(context, widget.bankId!);
                      } else {
                        apiDataUser.tambahBankMetodeTransfer(context);
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
                            color: const Color(0xFF407BFF).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Simpan",
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
                      onTap: () => apiDataUser.deleteBankMetodeTransfer(context, widget.bankId!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEE2737).withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            "Hapus Metode Pembayaran",
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
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2F2828),
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    bool enabled = true,
    required IconData icon,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(icon, color: Colors.grey.shade500, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
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
}
