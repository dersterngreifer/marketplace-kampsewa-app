import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/input/otp_input.dart';
import 'package:project_camp_sewa/services/api_lupa_password.dart';

class LayoutLupaPasswordOTP extends StatefulWidget {
  const LayoutLupaPasswordOTP({super.key});

  @override
  State<LayoutLupaPasswordOTP> createState() => _LayoutLupaPasswordOTPState();
}

class _LayoutLupaPasswordOTPState extends State<LayoutLupaPasswordOTP> {
  ApiLupaPassword apiLupaPassword = Get.put(ApiLupaPassword());
  TextEditingController otp1 = TextEditingController();
  TextEditingController otp2 = TextEditingController();
  TextEditingController otp3 = TextEditingController();
  TextEditingController otp4 = TextEditingController();
  TextEditingController otp5 = TextEditingController();
  TextEditingController otp6 = TextEditingController();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();
  final FocusNode focusNode6 = FocusNode();

  static const Color hijauTua = Color(0xFF2C4E40);
  static const Color gelap = Color(0xFF2F2828);

  @override
  Widget build(BuildContext context) {
    final dataKiriman = (Get.arguments as Map<String, dynamic>?) ?? {};
    String noTelephone = dataKiriman['nomor_telephone'] ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: const Color(0xFFFFC02B),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: gelap,
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
                  "assets/new-icons/periksa-otp.png",
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Periksa WhatsApp",
                style: AppColors.fontStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: gelap,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Kami telah mengirimkan 6 digit kode OTP ke nomor WhatsApp $noTelephone.",
                style: AppColors.fontStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: OtpInput(
                        controller: otp1,
                        focusNode: focusNode1,
                        nextFocusNode: focusNode2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: OtpInput(
                        controller: otp2,
                        focusNode: focusNode2,
                        nextFocusNode: focusNode3,
                        previousFocusNode: focusNode1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: OtpInput(
                        controller: otp3,
                        focusNode: focusNode3,
                        nextFocusNode: focusNode4,
                        previousFocusNode: focusNode2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: OtpInput(
                        controller: otp4,
                        focusNode: focusNode4,
                        nextFocusNode: focusNode5,
                        previousFocusNode: focusNode3,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: OtpInput(
                        controller: otp5,
                        focusNode: focusNode5,
                        nextFocusNode: focusNode6,
                        previousFocusNode: focusNode4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: OtpInput(
                      controller: otp6,
                      focusNode: focusNode6,
                      previousFocusNode: focusNode5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Tombol Verifikasi
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  String inputOTP = otp1.text +
                      otp2.text +
                      otp3.text +
                      otp4.text +
                      otp5.text +
                      otp6.text;
                  apiLupaPassword.lupaPassVerifikasiOTP(
                      context, inputOTP, noTelephone);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFFFC02B),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC02B).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Verifikasi",
                      style: AppColors.fontStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: gelap,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: InkWell(
                  onTap: () {
                    apiLupaPassword.lupaPassKirimUlangOTP(context, noTelephone);
                  },
                  child: Text(
                    "Kirim Ulang OTP?",
                    style: AppColors.fontStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: hijauTua,
                    ),
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
