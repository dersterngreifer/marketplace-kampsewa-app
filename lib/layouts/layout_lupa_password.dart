import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/input/input_versi1.dart';
import 'package:project_camp_sewa/services/api_lupa_password.dart';

class LayoutLupaPassword extends StatefulWidget {
  const LayoutLupaPassword({super.key});

  @override
  State<LayoutLupaPassword> createState() => _LayoutLupaPasswordState();
}

class _LayoutLupaPasswordState extends State<LayoutLupaPassword> {
  ApiLupaPassword apiLupaPassword = Get.put(ApiLupaPassword());

  // Brand palette KampSewa
  static const Color hijauTua = Color(0xFF2C4E40);
  static const Color gelap = Color(0xFF2F2828);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: hijauTua,
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
                  "assets/new-icons/lupa-password.png",
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Lupa Password",
                style: AppColors.fontStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: gelap,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Kamu harus verifikasi menggunakan nomor HP untuk mendapatkan kode OTP pemulihan.",
                style: AppColors.fontStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Nomor HP Terdaftar",
                style: AppColors.fontStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: gelap,
                ),
              ),
              const SizedBox(height: 12),

              // Input field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFF6F6F4),
                  boxShadow: [
                    BoxShadow(
                      color: hijauTua.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InputVersiSatu(
                  tipeInput: TextInputType.phone,
                  controller: apiLupaPassword.telephoneController,
                  iconInput: const Icon(
                    Icons.phone_iphone_rounded,
                    size: 24,
                    color: hijauTua,
                  ),
                  placeHolder: "Masukkan Nomor HP",
                  ukuranFontPlaceHolder: 15,
                  border: false,
                  ketebalanBorder: 0,
                ),
              ),

              const SizedBox(height: 40),

              // Tombol CTA solid color
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  apiLupaPassword.lupaPass(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: hijauTua,
                    boxShadow: [
                      BoxShadow(
                        color: hijauTua.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kirim OTP",
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
                          Icons.arrow_forward_rounded,
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
