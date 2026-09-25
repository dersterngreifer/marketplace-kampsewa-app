import 'package:dio/dio.dart';
import 'package:project_camp_sewa/layouts/layout_informasi_toko.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/layouts/layout_instruksi_kyc.dart';
import 'package:project_camp_sewa/layouts/layout_input_kyc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/layouts/layout_alamat.dart';
import 'package:project_camp_sewa/layouts/layout_edit_profile.dart';
import 'package:project_camp_sewa/layouts/layout_lupa_password_new_pass.dart';
import 'package:project_camp_sewa/layouts/layout_tambah_data_toko.dart';
import 'package:project_camp_sewa/layouts/layout_user_products.dart';
import 'package:project_camp_sewa/screens/screen_login.dart';
import 'package:project_camp_sewa/services/authorization_token.dart';
import 'package:project_camp_sewa/services/controller_dashboard.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/layouts/layout_public_store_profile.dart';

class LayoutProfile extends StatefulWidget {
  const LayoutProfile({super.key});

  @override
  State<LayoutProfile> createState() => _LayoutProfileState();
}

class _LayoutProfileState extends State<LayoutProfile> {
  final DashboardController pageController = Get.put(DashboardController());
  final ApiDataUser apiDataUser = Get.put(ApiDataUser());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiDataUser.getDataUser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Obx(() {
          final user = apiDataUser.dataUser.value;
          if (user == null) {
            return _buildShimmerLoading();
          }
          return RefreshIndicator(
            color: const Color(0xFF2C4E40),
            backgroundColor: Colors.white,
            displacement: 30,
            strokeWidth: 3,
            onRefresh: () async {
              await apiDataUser.getDataUser(context);
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Stack(
                children: [
                  // Hero Background
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF2C4E40),
                          Color(0xFF2C4E40),
                          Color(0xFF2C4E40),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  // Decorative Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  // Content
                  Column(
                    children: [
                      const SizedBox(height: 70),
                      _buildHeaderInfo(user),
                      const SizedBox(height: 25),
                      _buildStatsCard(user),
                      const SizedBox(height: 25),
                      _buildMenuSection(user),
                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Stack(
        children: [
          // Hero Background
          Container(
            height: 280,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF2C4E40),
                  Color(0xFF2C4E40),
                  Color(0xFF2C4E40),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          // Decorative Circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              const SizedBox(height: 70),
              // Header Info Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.white.withValues(alpha: 0.4),
                      highlightColor: Colors.white.withValues(alpha: 0.8),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.4),
                            highlightColor: Colors.white.withValues(alpha: 0.8),
                            child: Container(
                              width: 150,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.4),
                            highlightColor: Colors.white.withValues(alpha: 0.8),
                            child: Container(
                              width: 200,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.4),
                            highlightColor: Colors.white.withValues(alpha: 0.8),
                            child: Container(
                              width: 120,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.white.withValues(alpha: 0.4),
                      highlightColor: Colors.white.withValues(alpha: 0.8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Stats Card Shimmer
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 35,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: const Color(0xFF2C4E40).withValues(alpha: 0.08),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 15,
                  runSpacing: 20,
                  children: List.generate(
                    4,
                    (index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 30,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Menu Section Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, bottom: 12),
                        width: 120,
                        height: 16,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: List.generate(4, (index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Row(
                                  children: [
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: Container(
                                              width: 120,
                                              height: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: Container(
                                              width: 180,
                                              height: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index < 3) _buildDivider(),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(dynamic user) {
    String name = user.name ?? 'Unknown';
    String email = user.email ?? '';
    String phone = user.nomorTelephone ?? '';
    String avatarUrl = user.image ?? '';
    String jenisKelamin = user.jenisKelamin ?? 'Belum diisi';

    String getInitials(String str) {
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

    Widget fallbackAvatar() {
      return Container(
        width: 80,
        height: 80,
        color: AppColors.mainColor,
        alignment: Alignment.center,
        child: Text(
          getInitials(name),
          style: AppColors.fontStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget buildAvatarImage() {
      if (avatarUrl.isEmpty) {
        return fallbackAvatar();
      }
      final fullUrl = avatarUrl.startsWith('http')
          ? avatarUrl
          : ApiEndpoints.baseUrl +
              ApiEndpoints.authendpoints.getFotoProfile +
              avatarUrl;

      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (_, __, ___) => fallbackAvatar(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            ),
            child: ClipOval(child: buildAvatarImage()),
          ),
          const SizedBox(width: 16),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppColors.fontStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jenisKelamin,
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Edit Button
          Material(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Get.to(() => const LayoutEditProfile()),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(dynamic user) {
    bool isMitra = user != null && user.isToko == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 35,
            spreadRadius: 5,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: const Color(0xFF2C4E40).withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 15,
        runSpacing: 20,
        children: [
          _buildStatItem(
              apiDataUser.totalSemuaPesanan.value.toString(),
              'Total\nPesanan',
              Icons.shopping_bag_rounded,
              const Color(0xFF3B82F6)),
          _buildStatItem(
              apiDataUser.totalBelumDikonfirmasi.value.toString(),
              'Pesanan\nPending',
              Icons.pending_actions_rounded,
              const Color(0xFFF59E0B)), // Amber
          _buildStatItem(
              apiDataUser.totalSedangDisewa.value.toString(),
              'Sedang\nDisewa',
              Icons.local_shipping_rounded,
              const Color(0xFF10B981)),
          _buildStatItem(
              apiDataUser.totalProdukBelumDikonfirmasi.value.toString(),
              'Produk\nPending',
              Icons.inventory_2_rounded,
              const Color(0xFF8B5CF6)), // Purple
          if (isMitra) ...[
            _buildStatItem(
                user.ratingToko.toStringAsFixed(1),
                'Rating\n(${user.totalUlasanToko} Ulasan)',
                Icons.star_rounded,
                const Color(0xFFED6723)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: AppColors.fontStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2F2828),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppColors.fontStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFBDBDBD),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildKYCBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        children: [
          const Icon(MdiIcons.alertCircleOutline,
              color: Color(0xFFF57C00), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Identitas Belum Dilengkapi",
                    style: AppColors.fontStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF57C00))),
                const SizedBox(height: 4),
                Text("Lengkapi NIK KTP untuk membuka akses transaksi.",
                    style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE65100))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.to(() => const LayoutInstruksiKYC()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Isi"),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(dynamic user) {
    bool needsKYC = user.type == 0 &&
        (user.nomorIdentitas == null ||
            user.nomorIdentitas.toString().isEmpty ||
            user.fotoIdentitas == null ||
            user.fotoIdentitas.toString().isEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (needsKYC) _buildKYCBanner(),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              "Pengaturan Akun",
              style: AppColors.fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2F2828),
              ),
            ),
          ),
          if (needsKYC)
            _buildMenuItem(
              icon: MdiIcons.shieldLockOutline,
              title: 'Lengkapi Identitas',
              subtitle: 'Verifikasi NIK KTP Anda',
              iconColor: const Color(0xFF2C4E40),
              iconBgColor: const Color(0xFFE8F5E9), // Hijau muda
              onTap: () {
                Get.to(() => const LayoutInputKYC())?.then((_) {
                  if (mounted) apiDataUser.getDataUser(context);
                });
              },
            ),
          _buildMenuItem(
            icon: MdiIcons.packageVariantClosed,
            title: 'Produk Saya',
            subtitle: 'Lihat daftar produk Anda',
            iconColor: const Color(0xFF407BFF),
            iconBgColor: const Color(0xFFE3EFFF), // Biru muda
            onTap: () {
              if (user.isToko == true) {
                Get.to(() => const LayoutUserProducts());
              } else {
                CustomSnackBar.show(
                  context,
                  sukses: false,
                  title: "Perhatian",
                  teks:
                      "Lengkapi data di menu 'Mulai Menyewakan', lalu upload produk di website melalui tombol 'Dashboard Web'.",
                );
              }
            },
          ),
          _buildMenuItem(
            icon: MdiIcons.mapMarkerOutline,
            title: 'Alamat',
            subtitle: 'Atur alamat pengiriman',
            iconColor: const Color(0xFFFF9800),
            iconBgColor: const Color(0xFFFFF3E0), // Orange muda
            onTap: () {
              Get.to(() => const LayoutAlamat());
            },
          ),
          _buildMenuItem(
            icon: MdiIcons.lockOutline,
            title: 'Ubah Password',
            subtitle: 'Amankan akun Anda',
            iconColor: const Color(0xFF9C27B0),
            iconBgColor: const Color(0xFFF3E5F5), // Ungu muda
            onTap: () {
              Get.to(
                () => const LayoutLupaPasswordNewPass(),
                arguments: {
                  'nomor_telephone': user.nomorTelephone ?? '',
                  'lupa_password': false,
                },
              );
            },
          ),
          if (user.isToko == true) ...[
            _buildMenuItem(
              icon: MdiIcons.storeSearchOutline,
              title: 'Lihat Toko Publik',
              subtitle: 'Tampilan profil toko untuk pelanggan',
              iconColor: const Color(0xFF2196F3),
              iconBgColor: const Color(0xFFE3F2FD), // Biru muda
              onTap: () {
                Get.to(() => LayoutPublicStoreProfile(
                  idUser: user.id ?? 0, 
                  initialStoreName: user.namaStore,
                ));
              },
            ),
            _buildMenuItem(
              icon: MdiIcons.storeEditOutline,
              title: 'Informasi Toko',
              subtitle: 'Atur profil & banner toko Anda',
              iconColor: const Color(0xFF009688),
              iconBgColor: const Color(0xFFE0F2F1), // Teal muda
              onTap: () {
                Get.to(() => const LayoutInformasiToko());
              },
            ),
            _buildMenuItem(
              icon: MdiIcons.openInNew,
              title: 'Dashboard Web',
              subtitle: user.namaStore ?? 'Manajemen Toko Anda',
              iconColor: const Color(0xFF009688),
              iconBgColor: const Color(0xFFE0F2F1), // Teal muda
              onTap: () async {
                final Uri url = Uri.parse(ApiEndpoints.baseUrl);
                if (!await launchUrl(url)) {
                  Get.snackbar("Error", "Gagal membuka web browser");
                }
              },
            )
          ] else
            _buildMenuItem(
              icon: MdiIcons.storefrontOutline,
              title: 'Mulai Menyewakan',
              subtitle: 'Buka peluang baru hari ini',
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF407BFF), // Biru solid agar standout
              isHighlighted: true, // Custom flag
              onTap: () {
                if (needsKYC) {
                  CustomSnackBar.show(
                    context,
                    sukses: false,
                    title: "Perhatian",
                    teks:
                        "Harap lengkapi identitas (KTP) Anda sebelum membuka layanan penyewaan.",
                  );
                  Get.to(() => const LayoutInstruksiKYC());
                } else {
                  Get.to(() => const LayoutTambahDataToko())?.then((_) {
                    if (mounted) {
                      apiDataUser.getDataUser(context);
                    }
                  });
                }
              },
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              "Lainnya",
              style: AppColors.fontStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2F2828),
              ),
            ),
          ),
          _buildMenuItem(
            icon: MdiIcons.logout,
            title: 'Keluar',
            subtitle: 'Akhiri sesi saat ini',
            textColor: const Color(0xFFEE2737),
            iconColor: const Color(0xFFEE2737),
            iconBgColor: const Color(0xFFFEF2F2),
            onTap: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.5),
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  backgroundColor: Colors
                      .transparent, // Transparan agar bayangan bisa dari Container
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              MdiIcons.logout,
                              color: Color(0xFFEE2737),
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Keluar dari Akun?",
                            textAlign: TextAlign.center,
                            style: AppColors.fontStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2F2828),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Anda akan mengakhiri sesi saat ini.",
                            textAlign: TextAlign.center,
                            style: AppColors.fontStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8A8A8E),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: const Color(0xFFF0F1F3),
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () =>
                                        Navigator.of(context).pop(false),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: Text(
                                        "Batal",
                                        textAlign: TextAlign.center,
                                        style: AppColors.fontStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2F2828),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Material(
                                  color: const Color(0xFFEE2737),
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () =>
                                        Navigator.of(context).pop(true),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: Text(
                                        "Keluar",
                                        textAlign: TextAlign.center,
                                        style: AppColors.fontStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              if (confirm == true) {
                try {
                  Authorization auth = Authorization();
                  String? token = await auth.getToken();
                  if (token != null) {
                    final dio = Dio();
                    var url = ApiEndpoints.baseUrl +
                        ApiEndpoints.authendpoints.logout;
                    await dio.post(url,
                        options: Options(
                          headers: {
                            'Accept': 'application/json',
                            'Authorization': 'Bearer $token',
                          },
                          validateStatus: (_) => true,
                        ));
                  }
                } catch (_) {}
                Authorization auth = Authorization();
                await auth.clearAll();
                Get.offAll(() => const LoginScreen());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    Color? iconBgColor,
    bool isHighlighted = false,
  }) {
    final Color actualIconColor = iconColor ?? const Color(0xFF2C4E40);
    final Color actualIconBgColor = iconBgColor ?? const Color(0xFFE8F5E9);
    final Color actualTextColor =
        isHighlighted ? Colors.white : (textColor ?? const Color(0xFF2F2828));
    final Color subtitleColor = isHighlighted
        ? Colors.white.withValues(alpha: 0.8)
        : const Color(0xFF8A8A8E);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF407BFF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: const Color(0xFF407BFF).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 0,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.2)
                        : actualIconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon,
                      color: isHighlighted ? Colors.white : actualIconColor,
                      size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppColors.fontStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: actualTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppColors.fontStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  MdiIcons.chevronRight,
                  color: isHighlighted ? Colors.white : const Color(0xFFBDBDBD),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72, right: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFBDBDBD),
      ),
    );
  }
}
