import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/models/bank_model.dart';
import 'package:project_camp_sewa/services/api_transaksi.dart';

class LayoutMetodePembayaran extends StatefulWidget {
  const LayoutMetodePembayaran({super.key});

  @override
  State<LayoutMetodePembayaran> createState() => _LayoutMetodePembayaranState();
}

class _LayoutMetodePembayaranState extends State<LayoutMetodePembayaran> {
  ApiTransaksi apiTransaksi = Get.put(ApiTransaksi());
  String selectedOption = "transfer";
  String? selectedBank;
  String? rekeningBank;

  @override
  void initState() {
    super.initState();
    getListBank();
  }

  Future<void> getListBank() async {
    final arguments = await Get.arguments as Map<String, dynamic>;
    String idToko = arguments['idToko'];
    await apiTransaksi.getBankOpsiPembayaran(context, idToko);
  }

  Widget _buildPaymentOption({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? expandedContent,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange.shade400 : Colors.grey.shade300,
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
                    color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isSelected ? Colors.orange[700] : Colors.grey[600], size: 24),
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
                        description,
                        style: AppColors.fontStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: Colors.orange[700], size: 24)
                else
                  Icon(Icons.radio_button_unchecked, color: Colors.grey[400], size: 24),
              ],
            ),
            if (isSelected && expandedContent != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              expandedContent,
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
          "Metode Pembayaran",
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
                    "Pilih Metode Pembayaran",
                    style: AppColors.fontStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Harap membaca syarat & ketentuan saat memilih metode pembayaran",
                    style: AppColors.fontStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildPaymentOption(
                    title: "Transfer Bank",
                    description: "Transfer manual ke rekening store",
                    icon: MdiIcons.bankOutline,
                    isSelected: selectedOption == "transfer",
                    onTap: () => setState(() => selectedOption = "transfer"),
                    expandedContent: Obx(() {
                      if (apiTransaksi.listBankMetodeBayar.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Memuat daftar bank...", style: AppColors.fontStyle(fontSize: 13, color: Colors.grey)),
                        );
                      }
                      return Column(
                        children: apiTransaksi.listBankMetodeBayar.map((bank) {
                          bool isBankSelected = selectedBank == bank.bank;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedBank = bank.bank;
                                rekeningBank = bank.rekening;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: isBankSelected ? Colors.orange.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isBankSelected ? Colors.orange.shade300 : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Center(
                                      child: Text(
                                        bank.bank.toUpperCase(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Transfer ${bank.bank.toUpperCase()}",
                                      style: AppColors.fontStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                    ),
                                  ),
                                  if (isBankSelected)
                                    Icon(Icons.check, color: Colors.orange[700], size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),

                  _buildPaymentOption(
                    title: "Bayar Ditempat (COD)",
                    description: "Bayar tunai saat pengambilan barang",
                    icon: MdiIcons.cashFast,
                    isSelected: selectedOption == "COD",
                    onTap: () => setState(() {
                      selectedOption = "COD";
                      selectedBank = null;
                      rekeningBank = null;
                    }),
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
                  Get.back(
                    result: selectedOption == "transfer"
                      ? {
                          'metodeBayar': "Transfer",
                          'jenisBank': selectedBank ?? "Pilih Bank",
                          'rekeningBank': rekeningBank ?? ""
                        }
                      : {'metodeBayar': "Bayar Ditempat"}
                  );
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
