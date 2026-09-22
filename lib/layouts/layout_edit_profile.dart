import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as import_cupertino;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:project_camp_sewa/components/input/input_versi1.dart';
import 'package:project_camp_sewa/layouts/layout_input_kyc.dart';
import 'package:project_camp_sewa/models/user.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';

class LayoutEditProfile extends StatefulWidget {
  const LayoutEditProfile({super.key});

  @override
  State<LayoutEditProfile> createState() => _LayoutEditProfileState();
}

class _LayoutEditProfileState extends State<LayoutEditProfile> {
  final ApiDataUser apiDataUser = Get.put(ApiDataUser());

  XFile? pickedPhotoProfile;

  static const Color _darkGreen = Color(0xFF1B332B);
  static const Color _mediumGreen = Color(0xFF2C4E40);
  static const Color _lightGreen = Color(0xFF3E6B58);
  static const Color _background = Color(0xFFF7F8FA);

  @override
  void initState() {
    super.initState();
    apiDataUser.getDataUser(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(2000, 1, 1);
    if (apiDataUser.tanggalLahirController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd')
            .parse(apiDataUser.tanggalLahirController.text);
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
                      apiDataUser.tanggalLahirController.text = formattedDate;
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Status bar menyatu dengan header.
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,

        // Navigation bar bawah juga tetap hijau.
        systemNavigationBarColor: _darkGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _background,
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            _buildHeader(context),

            // SafeArea hanya untuk konten.
            Expanded(
              child: SafeArea(
                top: false,
                bottom: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    children: [
                      Obx(() {
                        final User? dataUser = apiDataUser.dataUser.value;

                        return _buildAvatarSection(dataUser);
                      }),
                      const SizedBox(height: 24),
                      _buildFormCard(),
                      const SizedBox(height: 20),
                      Obx(() {
                        final User? dataUser = apiDataUser.dataUser.value;
                        if (dataUser == null) return const SizedBox.shrink();
                        return _buildKYCSection(dataUser);
                      }),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                      const SizedBox(height: 8),
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 8,
        left: 8,
        right: 16,
        bottom: 18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darkGreen,
            _mediumGreen,
            _lightGreen,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(14),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: AppColors.fontStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Perbarui informasi profil kamu',
                  style: AppColors.fontStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),

          // Profile icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  String _getInitials(String str) {
    if (str.trim().isEmpty) return "US";
    List<String> words = str.trim().split(RegExp(r'\s+'));
    String initials = "";
    for (var i = 0; i < words.length && i < 3; i++) {
      if (words[i].isNotEmpty) {
        initials += words[i][0].toUpperCase();
      }
    }
    return initials.isNotEmpty ? initials : "US";
  }

  Widget _buildAvatarSection(User? dataUser) {
    String name = dataUser?.name ?? "US";

    Widget fallbackAvatar() {
      return Container(
        width: 116,
        height: 116,
        decoration: const BoxDecoration(
          color: AppColors.mainColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          _getInitials(name),
          style: AppColors.fontStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget buildAvatarImage() {
      if (pickedPhotoProfile != null) {
        return ClipOval(
          child: Image.file(
            File(pickedPhotoProfile!.path),
            fit: BoxFit.cover,
            width: 116,
            height: 116,
          ),
        );
      }

      if (dataUser == null ||
          dataUser.image == null ||
          dataUser.image!.isEmpty ||
          dataUser.image!.contains('ui-avatars.com')) {
        return fallbackAvatar();
      }

      final fullUrl = dataUser.image!.startsWith('http')
          ? dataUser.image!
          : ApiEndpoints.baseUrl +
              ApiEndpoints.authendpoints.getFotoProfile +
              dataUser.image!;

      return ClipOval(
        child: Image.network(
          fullUrl,
          fit: BoxFit.cover,
          width: 116,
          height: 116,
          errorBuilder: (_, __, ___) => fallbackAvatar(),
        ),
      );
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Outer ring
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: _mediumGreen.withValues(alpha: 0.18),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _darkGreen.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: buildAvatarImage(),
            ),

            // Camera button
            Positioned(
              right: -2,
              bottom: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: pickedImage,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _mediumGreen,
                          _lightGreen,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _darkGreen.withValues(alpha: 0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      MdiIcons.camera,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Foto Profil',
          style: AppColors.fontStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF272B29),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Ketuk ikon kamera untuk mengganti foto',
          style: AppColors.fontStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8A918D),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM CARD
  // ============================================================

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEDEFEF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _mediumGreen.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: _mediumGreen,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                'Informasi Pribadi',
                style: AppColors.fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF242826),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _buildLabel('Nama'),

          InputVersiSatu(
            controller: apiDataUser.namaController,
            tipeInput: TextInputType.text,
            showEyes: false,
            iconInput: const Icon(
              Icons.person_outline_rounded,
            ),
            placeHolder: 'Username',
            border: true,
          ),

          const SizedBox(height: 16),

          _buildLabel('Email'),

          InputVersiSatu(
            controller: apiDataUser.emailController,
            tipeInput: TextInputType.emailAddress,
            showEyes: false,
            iconInput: const Icon(
              Icons.email_outlined,
            ),
            placeHolder: 'Email',
            border: true,
          ),

          const SizedBox(height: 16),

          _buildLabel('Nomor Telephone'),

          InputVersiSatu(
            controller: apiDataUser.phoneNumberController,
            tipeInput: TextInputType.phone,
            showEyes: false,
            iconInput: const Icon(
              Icons.phone_outlined,
            ),
            placeHolder: 'No.Telephone',
            border: true,
          ),

          const SizedBox(height: 16),

          _buildLabel('Tanggal Lahir'),

          _buildDateField(),

          const SizedBox(height: 16),

          _buildLabel('Jenis Kelamin'),

          _buildJenisKelaminField(),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.2,
            color: const Color(0xFFE1E3E8),
          ),
        ),
        child: IgnorePointer(
          child: TextField(
            controller: apiDataUser.tanggalLahirController,
            enabled: false,
            keyboardType: TextInputType.none,
            style: AppColors.fontStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              prefixIcon: const Icon(
                Icons.date_range_rounded,
                size: 22,
                color: Color(0xFF8E9691),
              ),
              hintText: 'Tanggal Lahir',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintStyle: AppColors.fontStyle(
                color: const Color(0xFF8A8A8E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJenisKelaminField() {
    return InkWell(
      onTap: () => _selectJenisKelamin(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.2,
            color: const Color(0xFFE1E3E8),
          ),
        ),
        child: IgnorePointer(
          child: TextField(
            controller: apiDataUser.jenisKelaminController,
            enabled: false,
            keyboardType: TextInputType.none,
            style: AppColors.fontStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              prefixIcon: const Icon(
                Icons.wc_rounded,
                size: 22,
                color: Color(0xFF8E9691),
              ),
              hintText: 'Pilih Jenis Kelamin',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintStyle: AppColors.fontStyle(
                color: const Color(0xFF8A8A8E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectJenisKelamin(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 220,
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
                    const SizedBox(width: 50),
                    Text('Pilih Jenis Kelamin',
                        style: AppColors.fontStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Tutup',
                          style: AppColors.fontStyle(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.male, color: Colors.blue.shade600),
                      ),
                      title: Text('Laki-Laki',
                          style: AppColors.fontStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      onTap: () {
                        setState(() {
                          apiDataUser.jenisKelaminController.text = 'Laki-Laki';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.female, color: Colors.pink.shade600),
                      ),
                      title: Text('Perempuan',
                          style: AppColors.fontStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      onTap: () {
                        setState(() {
                          apiDataUser.jenisKelaminController.text = 'Perempuan';
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 8,
      ),
      child: Text(
        text,
        style: AppColors.fontStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF343936),
        ),
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                _darkGreen,
                _mediumGreen,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _darkGreen.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              apiDataUser.updateProfile(
                context,
                pickedPhotoProfile,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Text(
                  'Simpan Perubahan',
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
    );
  }

  // ============================================================
  // KYC SECTION
  // ============================================================

  Widget _buildKYCSection(User user) {
    bool hasNIK = user.nomorIdentitas != null &&
        user.nomorIdentitas.toString().isNotEmpty &&
        user.fotoIdentitas != null &&
        user.fotoIdentitas.toString().isNotEmpty;
    bool isVerified = user.isVerified == true;
    String maskedNIK = '';

    if (hasNIK) {
      String nik = user.nomorIdentitas!;
      if (nik.length >= 8) {
        maskedNIK =
            '${nik.substring(0, 3)}${'*' * (nik.length - 7)}${nik.substring(nik.length - 4)}';
      } else {
        maskedNIK = nik;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEDEFEF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: hasNIK
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.09)
                      : const Color(0xFFF57C00).withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasNIK
                      ? Icons.verified_user_rounded
                      : MdiIcons.shieldAlertOutline,
                  color: hasNIK
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFF57C00),
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Verifikasi Identitas',
                  style: AppColors.fontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF242826),
                  ),
                ),
              ),
              if (hasNIK && isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Terverifikasi',
                    style: AppColors.fontStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasNIK)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NIK',
                  style: AppColors.fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A918D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  maskedNIK,
                  style: AppColors.fontStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2828),
                    letterSpacing: 2,
                  ),
                ),
                if (!isVerified) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFF57C00),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Verifikasi identitas masih dalam proses',
                            style: AppColors.fontStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF6C00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anda belum mengisi NIK KTP',
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A918D),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: const Color(0xFFF57C00),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Get.to(() => const LayoutInputKYC())?.then((_) {
                          if (mounted) {
                            apiDataUser.getDataUser(context);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              MdiIcons.cardAccountDetailsOutline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Isi Sekarang',
                              style: AppColors.fontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PERMISSION & PICKER
  // ============================================================

  bool _isPickingImage = false;

  Future<void> pickedImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        // CROP IMAGE
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Edit Foto Profile',
                toolbarColor: const Color(0xFF2C4E40),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: false,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
            ),
            IOSUiSettings(
              title: 'Edit Foto Profile',
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            pickedPhotoProfile = XFile(croppedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      _isPickingImage = false;
    }
  }
}
