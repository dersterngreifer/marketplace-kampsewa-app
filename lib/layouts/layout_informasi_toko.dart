import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/components/dialog/loading_dialog.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';

class LayoutInformasiToko extends StatefulWidget {
  const LayoutInformasiToko({super.key});

  @override
  State<LayoutInformasiToko> createState() => _LayoutInformasiTokoState();
}

class _LayoutInformasiTokoState extends State<LayoutInformasiToko> {
  final ApiDataUser apiDataUser = Get.find<ApiDataUser>();
  final LoadingDialog loading = Get.find<LoadingDialog>();

  bool isEditingName = false;
  bool isEditingDesc = false;

  late TextEditingController nameController;
  late TextEditingController descController;
  File? localBannerFile;
  File? localFotoFile;

  @override
  void initState() {
    super.initState();
    final user = apiDataUser.dataUser.value!;
    nameController = TextEditingController(text: user.namaStore ?? '');
    descController = TextEditingController(text: user.deskripsiToko ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBanner) async {
    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (image != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle:
                  isBanner ? 'Edit Banner Toko' : 'Edit Foto Profil Toko',
              toolbarColor: const Color(0xFF2C4E40),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: isBanner
                  ? CropAspectRatioPreset.ratio16x9
                  : CropAspectRatioPreset.square,
              lockAspectRatio: false,
              aspectRatioPresets: isBanner
                  ? [
                      CropAspectRatioPreset.ratio16x9,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.original,
                    ]
                  : [
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.original,
                    ],
            ),
            IOSUiSettings(
              title: isBanner ? 'Edit Banner Toko' : 'Edit Foto Profil Toko',
              aspectRatioPresets: isBanner
                  ? [
                      CropAspectRatioPreset.ratio16x9,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.original,
                    ]
                  : [
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.original,
                    ],
            ),
          ],
        );

        if (croppedFile != null) {
          loading.showLoadingDialog();
          bool success = await apiDataUser.updateInformasiToko(
            context,
            bannerPath: isBanner ? croppedFile.path : null,
            fotoTokoPath: !isBanner ? croppedFile.path : null,
          );
          loading.hideLoadingDialog();
          if (success) {
            CustomSnackBar.show(context,
                sukses: true,
                title: "Berhasil",
                teks: "Foto berhasil diupdate");
            setState(() {
              if (isBanner) {
                localBannerFile = File(croppedFile.path);
              } else {
                localFotoFile = File(croppedFile.path);
              }
            });
          } else {
            CustomSnackBar.show(context,
                sukses: false, title: "Gagal", teks: "Gagal mengupdate foto");
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveText(String field) async {
    loading.showLoadingDialog();
    bool success = await apiDataUser.updateInformasiToko(
      context,
      nameStore: field == 'name' ? nameController.text : null,
      deskripsiToko: field == 'desc' ? descController.text : null,
    );
    loading.hideLoadingDialog();
    if (success) {
      setState(() {
        if (field == 'name') isEditingName = false;
        if (field == 'desc') isEditingDesc = false;
      });
      CustomSnackBar.show(context,
          sukses: true, title: "Berhasil", teks: "Informasi berhasil diupdate");
    } else {
      CustomSnackBar.show(context,
          sukses: false, title: "Gagal", teks: "Gagal mengupdate informasi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat muda
      appBar: AppBar(
        title: Text('Informasi Toko',
            style:
                AppColors.fontStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors
            .transparent, // Mencegah warna berubah jadi pink saat di-scroll
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2F2828)),
      ),
      body: Obx(() {
        final user = apiDataUser.dataUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();

        // ── Banner toko ──
        // getBannerTokoUrl() sudah menangani: filename kosong -> '', filename
        // sudah berupa URL http -> dipakai apa adanya, selain itu dirangkai
        // dengan folder "assets/image/customers/banner/" + baseUrl.
        final String bannerUrl =
            (user.bannerToko != null && user.bannerToko!.isNotEmpty)
                ? '${getBannerTokoUrl(user.bannerToko)}?v=$timestamp'
                : '';

        // ── Foto profil toko ──
        // Backend (tambahStore() di UserController.php) menyimpan file foto_toko
        // ke folder public/assets/image/customers/logo_toko/ — jadi folder yang
        // dipakai di sini harus sama persis. Kalau fotoToko null/kosong, fotoUrl
        // dibiarkan '' (tidak memaksa null-assertion).
        const String fotoTokoPrefix = '/assets/image/customers/logo_toko/';
        final String fotoUrl = (user.fotoToko != null &&
                user.fotoToko!.isNotEmpty)
            ? '${resolveFullUrl(user.fotoToko!, fotoTokoPrefix)}?v=$timestamp'
            : '';

        return SingleChildScrollView(
          child: Column(
            children: [
              // 1. HEADER (Banner + Avatar Center)
              _buildProfileHeader(bannerUrl, fotoUrl),

              // Jarak kompensasi
              const SizedBox(height: 16),

              // 2. FORM INPUTS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildEditableCard(
                      label: "Nama Toko",
                      value: user.namaStore ?? '',
                      isEditing: isEditingName,
                      controller: nameController,
                      maxLines: 1,
                      onEdit: () {
                        setState(() {
                          isEditingName = true;
                          nameController.text = user.namaStore ?? '';
                        });
                      },
                      onCancel: () => setState(() => isEditingName = false),
                      onSave: () => _saveText('name'),
                    ),
                    const SizedBox(height: 16),
                    _buildEditableCard(
                      label: "Deskripsi Toko",
                      value: user.deskripsiToko ?? '',
                      isEditing: isEditingDesc,
                      controller: descController,
                      maxLines: 4,
                      onEdit: () {
                        setState(() {
                          isEditingDesc = true;
                          descController.text = user.deskripsiToko ?? '';
                        });
                      },
                      onCancel: () => setState(() => isEditingDesc = false),
                      onSave: () => _saveText('desc'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // WIDGET: Header Profil (Banner & Avatar)
  Widget _buildProfileHeader(String bannerUrl, String fotoUrl) {
    return SizedBox(
      height: 205,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // --- BANNER ---
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              image: localBannerFile != null
                  ? DecorationImage(
                      image: FileImage(localBannerFile!), fit: BoxFit.cover)
                  : (bannerUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(bannerUrl),
                          fit: BoxFit.cover,
                        )
                      : null),
            ),
            child: bannerUrl.isEmpty && localBannerFile == null
                ? const Icon(Icons.store, size: 50, color: Colors.grey)
                : null,
          ),

          // Tombol Edit Banner
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _pickImage(true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Ubah Sampul",
                      style: AppColors.fontStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            ),
          ),

          // --- AVATAR ---
          Positioned(
            bottom: 0,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFF8F9FA),
                        width: 4), // Warna sama dengan background scaffold
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                    image: localFotoFile != null
                        ? DecorationImage(
                            image: FileImage(localFotoFile!), fit: BoxFit.cover)
                        : (fotoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(fotoUrl),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: fotoUrl.isEmpty && localFotoFile == null
                      ? const Icon(Icons.storefront_rounded,
                          size: 40, color: Colors.grey)
                      : null,
                ),
                // Tombol Edit Avatar
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Card Edit Dinamis (Read Mode vs Edit Mode)
  Widget _buildEditableCard({
    required String label,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isEditing
                ? AppColors.mainColor.withValues(alpha: 0.3)
                : Colors.grey.shade200),
        boxShadow: [
          if (isEditing)
            BoxShadow(
              color: AppColors.mainColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Label & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppColors.fontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF757575),
                ),
              ),
              if (!isEditing)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 14, color: AppColors.mainColor),
                        const SizedBox(width: 4),
                        Text(
                          "Ubah",
                          style: AppColors.fontStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Tampilan Berdasarkan State (View or Edit)
          if (!isEditing)
            Text(
              value.isEmpty ? 'Belum diatur' : value,
              style: AppColors.fontStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: value.isEmpty
                    ? Colors.grey.shade400
                    : const Color(0xFF2F2828),
                height: 1.5,
              ),
            )
          else
            Column(
              children: [
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  style: AppColors.fontStyle(
                      fontSize: 14, color: const Color(0xFF2F2828)),
                  decoration: InputDecoration(
                    hintText: "Masukkan $label",
                    hintStyle: AppColors.fontStyle(
                        color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.mainColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: Text("Batal",
                          style:
                              AppColors.fontStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Simpan",
                          style:
                              AppColors.fontStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
