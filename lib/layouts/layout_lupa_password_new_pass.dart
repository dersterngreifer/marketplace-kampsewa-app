import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/input/input_versi1.dart';
import 'package:project_camp_sewa/services/api_lupa_password.dart';

class LayoutLupaPasswordNewPass extends StatefulWidget {
  const LayoutLupaPasswordNewPass({super.key});

  @override
  State<LayoutLupaPasswordNewPass> createState() =>
      _LayoutLupaPasswordNewPassState();
}

class _LayoutLupaPasswordNewPassState extends State<LayoutLupaPasswordNewPass> {
  ApiLupaPassword apiLupaPassword = Get.put(ApiLupaPassword());
  static const Color temaBiru = Color(0xFF407BFF);
  static const Color gelap = Color(0xFF2F2828);

  @override
  Widget build(BuildContext context) {
    final dataKiriman = (Get.arguments as Map<String, dynamic>?) ?? {};
    String noTelephone = dataKiriman['nomor_telephone'] ?? '';
    bool lupaPass = dataKiriman['lupa_password'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: temaBiru,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  "assets/new-icons/newpassword.png",
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Password Baru",
                style: AppColors.fontStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: gelap,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Jangan lupa untuk memasukkan kembali password baru Anda pada kolom konfirmasi password.",
                style: AppColors.fontStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              Text(
                "Password",
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: gelap,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFF6F6F4),
                  boxShadow: [
                    BoxShadow(
                      color: temaBiru.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InputVersiSatu(
                  tipeInput: TextInputType.visiblePassword,
                  controller: apiLupaPassword.newPassController,
                  showEyes: true,
                  passwordTipe: true,
                  iconInput: const Icon(
                    Icons.lock_rounded,
                    size: 24,
                    color: temaBiru,
                  ),
                  placeHolder: "Masukkan Password Baru",
                  ukuranFontPlaceHolder: 15,
                  border: false,
                  ketebalanBorder: 0,
                ),
              ),

              const SizedBox(height: 24),
              Text(
                "Konfirmasi Password",
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: gelap,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFF6F6F4),
                  boxShadow: [
                    BoxShadow(
                      color: temaBiru.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InputVersiSatu(
                  tipeInput: TextInputType.visiblePassword,
                  controller: apiLupaPassword.confirmPassController,
                  showEyes: true,
                  passwordTipe: true,
                  iconInput: const Icon(
                    Icons.lock_rounded,
                    size: 24,
                    color: temaBiru,
                  ),
                  placeHolder: "Ketik Ulang Password Baru",
                  ukuranFontPlaceHolder: 15,
                  border: false,
                  ketebalanBorder: 0,
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Konfirmasi
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  apiLupaPassword.lupaPassResetPass(
                      context, noTelephone, lupaPass);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: temaBiru,
                    boxShadow: [
                      BoxShadow(
                        color: temaBiru.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Konfirmasi",
                        style: AppColors.fontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
