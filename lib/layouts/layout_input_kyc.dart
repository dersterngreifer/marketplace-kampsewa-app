// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class LayoutInputKYC extends StatefulWidget {
  const LayoutInputKYC({super.key});

  @override
  State<LayoutInputKYC> createState() => _LayoutInputKYCState();
}

class _LayoutInputKYCState extends State<LayoutInputKYC> {
  final ApiDataUser apiDataUser = Get.put(ApiDataUser());
  final TextEditingController nikController = TextEditingController();
  XFile? pickedFotoIdentitas;
  bool _isSubmitting = false;

  static const Color _darkGreen = Color(0xFF1B332B);
  static const Color _mediumGreen = Color(0xFF2C4E40);
  static const Color _lightGreen = Color(0xFF3E6B58);

  @override
  void dispose() {
    nikController.dispose();
    super.dispose();
  }

  void _submitKYC() {
    String nik = nikController.text.trim();

    if (nik.isEmpty) {
      _showError('NIK tidak boleh kosong');
      return;
    }

    if (nik.length != 16) {
      _showError('NIK harus 16 digit angka');
      return;
    }

    if (!RegExp(r'^\d{16}$').hasMatch(nik)) {
      _showError('NIK harus berisi angka saja');
      return;
    }

    if (pickedFotoIdentitas == null) {
      _showError('Foto KTP wajib dipilih');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    apiDataUser.inputKYC(context, nik, pickedFotoIdentitas).then((_) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
  }

  void _showError(String message) {
    CustomSnackBar.show(context, sukses: false,
          teks: message,);
  }

  Future<void> _pickFotoIdentitas(ImageSource source) async {
    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    final status = await permission.request();

    if (source == ImageSource.camera && !status.isGranted) {
      return;
    }

    if (source == ImageSource.gallery &&
        !status.isGranted &&
        status.isPermanentlyDenied) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Edit Foto KTP',
              toolbarColor: const Color(0xFF2C4E40),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio3x2,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio16x9
              ],
          ),
          IOSUiSettings(
            title: 'Edit Foto KTP',
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        XFile finalFile = XFile(croppedFile.path);
        
        // Panggil endpoint /api/user/verify-ktp sebagai gatekeeper AI
        bool isValid = await apiDataUser.verifyKTP(context, finalFile.path);
        
        if (isValid) {
          setState(() {
            pickedFotoIdentitas = finalFile;
          });
        } else {
          // Jika tidak valid, kosongkan foto
          setState(() {
            pickedFotoIdentitas = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNIKSection(),
                    const SizedBox(height: 24),
                    _buildFotoSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          colors: [_darkGreen, _mediumGreen, _lightGreen],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi Identitas',
                  style: AppColors.fontStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Isi data NIK dan foto KTP Anda',
                  style: AppColors.fontStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNIKSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Nomor Induk Kependudukan (NIK)',
            style: AppColors.fontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2F2828),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE1E3E8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: nikController,
            keyboardType: TextInputType.number,
            maxLength: 16,
            style: AppColors.fontStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              counterText: '',
              prefixIcon: const Icon(
                MdiIcons.cardAccountDetailsOutline,
                color: Color(0xFF8E9691),
                size: 22,
              ),
              hintText: 'Masukkan 16 digit NIK',
              hintStyle: AppColors.fontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFBDBDBD),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '${nikController.text.length}/16 digit',
            style: AppColors.fontStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: nikController.text.length == 16
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFBDBDBD),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Foto KTP',
            style: AppColors.fontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2F2828),
            ),
          ),
        ),
        if (pickedFotoIdentitas != null)
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE1E3E8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(pickedFotoIdentitas!.path),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        pickedFotoIdentitas = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () => _showImageSourceDialog(),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE1E3E8),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _mediumGreen.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      MdiIcons.cameraOutline,
                      color: _mediumGreen,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Ambil Foto KTP',
                    style: AppColors.fontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F2828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ketuk untuk memilih foto',
                    style: AppColors.fontStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pilih Sumber Foto',
                style: AppColors.fontStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2F2828),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _mediumGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  MdiIcons.cameraOutline,
                  color: _mediumGreen,
                  size: 22,
                ),
              ),
              title: Text(
                'Kamera',
                style: AppColors.fontStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F2828),
                ),
              ),
              subtitle: Text(
                'Ambil foto KTP dari kamera',
                style: AppColors.fontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFotoIdentitas(ImageSource.camera);
              },
            ),
            const Divider(height: 1, indent: 72, endIndent: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _mediumGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  MdiIcons.imageOutline,
                  color: _mediumGreen,
                  size: 22,
                ),
              ),
              title: Text(
                'Galeri',
                style: AppColors.fontStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F2828),
                ),
              ),
              subtitle: Text(
                'Pilih foto KTP dari galeri',
                style: AppColors.fontStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFotoIdentitas(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: _isSubmitting
                  ? [
                      Colors.grey.shade400,
                      Colors.grey.shade500,
                    ]
                  : [
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
            onTap: _isSubmitting ? null : _submitKYC,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 10),
                Text(
                  _isSubmitting ? 'Mengirim...' : 'Kirim Verifikasi',
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
}
