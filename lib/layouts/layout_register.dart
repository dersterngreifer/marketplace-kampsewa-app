import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/cupertino.dart' as import_cupertino;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/components/button/button_versi1.dart';
import 'package:project_camp_sewa/components/input/input_versi1.dart';
import 'package:project_camp_sewa/services/api_register.dart';

class LayoutRegister extends StatefulWidget {
  const LayoutRegister({super.key});

  @override
  State<LayoutRegister> createState() => _LayoutRegisterState();
}

class _LayoutRegisterState extends State<LayoutRegister> {
  ApiRegistrasi apiRegistrasi = Get.put(ApiRegistrasi());

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Hero image dengan gradient overlay ──
            Stack(
              children: [
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.2,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1a/58/bc/c7/senaru-crater-rim-2-days.jpg?w=1200&h=-1&s=1"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.45, 1.0],
                        colors: [
                          Color(0x55010935),
                          Color(0x11010935),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Title ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "BUAT AKUN BARU",
                      style: AppColors.fontStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mainColor,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "REGISTRASI",
                      style: AppColors.fontStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Accent divider
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mainColor,
                            AppColors.mainColor.withValues(alpha: 0.3)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 5),
              child: InputVersiSatu(
                warnaBgInput: const Color(0xFFF3F4F6),
                controller: apiRegistrasi.namaController,
                tipeInput: TextInputType.name,
                showEyes: false,
                iconInput: const Icon(Icons.person_outline),
                placeHolder: "Username",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 5),
              child: InputVersiSatu(
                warnaBgInput: const Color(0xFFF3F4F6),
                controller: apiRegistrasi.emailController,
                tipeInput: TextInputType.emailAddress,
                showEyes: false,
                iconInput: const Icon(Icons.email_rounded),
                placeHolder: "Email",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 5),
              child: InputVersiSatu(
                warnaBgInput: const Color(0xFFF3F4F6),
                controller: apiRegistrasi.phoneNumberController,
                tipeInput: TextInputType.phone,
                showEyes: false,
                iconInput: const Icon(Icons.phone),
                placeHolder: "No.Telephone",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 5),
              child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: apiRegistrasi.tanggalLahirController,
                    onTap: () {
                      _selectDate(context);
                    },
                    keyboardType: TextInputType.none,
                    style: AppColors.fontStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: IconTheme(
                        data: IconThemeData(
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                        child: const Icon(Icons.date_range),
                      ),
                      hintText: "Tanggal Lahir",
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      hintStyle: AppColors.fontStyle(
                          color: Colors.grey.shade400, fontSize: 14),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 5),
              child: InputVersiSatu(
                warnaBgInput: const Color(0xFFF3F4F6),
                // passwordTipe: true,
                controller: apiRegistrasi.passwordController,
                placeHolder: "Password",
                showEyes: true,
                passwordTipe: true,
                iconInput: const Icon(Icons.key_outlined),
                tipeInput: TextInputType.visiblePassword,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: ButtonVersiSatu(
                  aksi: () {
                    apiRegistrasi.registrasi(context);
                  },
                  lebarFull: true,
                  title: "Register",
                  bgTombol: AppColors.mainColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Center(
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun?",
                        style: AppColors.fontStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Login!",
                        style: AppColors.fontStyle(
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(2000, 1, 1);
    if (apiRegistrasi.tanggalLahirController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd')
            .parse(apiRegistrasi.tanggalLahirController.text);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal',
                          style: AppColors.fontStyle(
                              color: Colors.grey, fontWeight: FontWeight.w600)),
                    ),
                    Text('Pilih Tanggal Lahir',
                        style: AppColors.fontStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Selesai',
                          style: AppColors.fontStyle(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: import_cupertino.CupertinoDatePicker(
                  initialDateTime: initialDate,
                  minimumYear: 1950,
                  maximumYear: DateTime.now().year,
                  mode: import_cupertino.CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime pickedDate) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      apiRegistrasi.tanggalLahirController.text = formattedDate;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Membuat objek path untuk menentukan area yang akan dipotong
    var path = Path();
    // Menentukan titik awal path (pojok kiri atas)
    path.lineTo(0, size.height - 80);
    // Menentukan titik kontrol pertama untuk kurva Bezier pertama
    var firstControlPoint = Offset(size.width / 4, size.height);
    // Menentukan titik akhir kurva Bezier pertama
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    // Menambahkan kurva Bezier pertama ke path
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    // Menentukan titik kontrol kedua untuk kurva Bezier kedua
    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    // Menentukan titik akhir kurva Bezier kedua
    var secondEndPoint = Offset(size.width, size.height - 20);
    // Menambahkan kurva Bezier kedua ke path
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    // Menambahkan garis lurus ke pojok kanan bawah
    path.lineTo(size.width, size.height - 40);
    // Menambahkan garis lurus ke pojok kanan atas
    path.lineTo(size.width, 0);
    // Menutup path sehingga area yang ditentukan oleh path akan dipotong
    path.close();
    // Mengembalikan path yang telah dibuat
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Metode ini digunakan untuk menentukan apakah path perlu dipotong ulang
    // Di sini, kita mengembalikan false karena path tidak perlu diubah.
    return true;
  }
}
