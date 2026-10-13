import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/layouts/layout_form_diskon.dart';
import 'package:project_camp_sewa/models/mitra_diskon_model.dart';
import 'package:project_camp_sewa/services/api_diskon.dart';
import 'package:project_camp_sewa/theme_colors.dart';

class LayoutKelolaDiskon extends StatefulWidget {
  const LayoutKelolaDiskon({super.key});

  @override
  State<LayoutKelolaDiskon> createState() => _LayoutKelolaDiskonState();
}

class _LayoutKelolaDiskonState extends State<LayoutKelolaDiskon> {
  final ApiDiskon apiDiskon = Get.put(ApiDiskon());
  String filterStatus = 'semua'; // 'semua', 'aktif', 'tidak_aktif'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await apiDiskon.getDiskonList();
  }

  String _formatTanggalIndonesia(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.trim().replaceFirst(' ', 'T'));
      const namaBulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${namaBulan[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _formatPeriode(String? mulai, String? selesai) {
    final strM = _formatTanggalIndonesia(mulai);
    final strS = _formatTanggalIndonesia(selesai);
    if (strM.isNotEmpty && strS.isNotEmpty) return '$strM - $strS';
    if (strS.isNotEmpty) return 'Hingga $strS';
    if (strM.isNotEmpty) return 'Mulai $strM';
    return 'Periode Terbatas';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.mainColor,
                  onRefresh: _loadData,
                  child: Obx(() {
                    if (apiDiskon.isLoading.value &&
                        apiDiskon.listDiskon.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2C4E40),
                        ),
                      );
                    }

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // Banner promo toko keseluruhan jika aktif
                        if (apiDiskon.hasActiveStoreWide.value &&
                            apiDiskon.activeStoreWide.value != null)
                          SliverToBoxAdapter(
                            child: _buildStoreWideBanner(
                                apiDiskon.activeStoreWide.value!),
                          ),

                        // Filter status chips
                        SliverToBoxAdapter(
                          child: _buildFilterChips(),
                        ),

                        // List promo diskon
                        _buildPromoList(),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => const LayoutFormDiskon())?.then((_) => _loadData());
          },
          backgroundColor: const Color(0xFF2C4E40),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Buat Diskon',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C4E40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => Get.back(),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diskon Produk Toko',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  'Kelola katalog promo & potongan harga',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreWideBanner(ActiveStoreWidePromoModel promo) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C4E40), Color(0xFF1E352B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C4E40).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_rounded,
                        size: 12, color: Color(0xFF2F2828)),
                    SizedBox(width: 4),
                    Text(
                      'DISKON TOKO AKTIF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2F2828),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Berlaku untuk Semua Produk (${promo.konflikDiskon == 'replace' ? 'Samaratakan' : 'Pertahankan Diskon Lama'})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            promo.namaDiskon,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Potongan harga ${promo.labelDiskon} untuk katalog toko Anda',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 13, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTanggalIndonesia(promo.tanggalSelesai).isNotEmpty
                        ? 'Berakhir ${_formatTanggalIndonesia(promo.tanggalSelesai)}'
                        : 'Masa Aktif Berjalan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  // Temukan model diskon lengkap jika ada di listDiskon
                  final match = apiDiskon.listDiskon.firstWhereOrNull(
                      (item) => item.idPromo == promo.idPromo);
                  if (match != null) {
                    Get.to(() => LayoutFormDiskon(promoToEdit: match))
                        ?.then((_) => _loadData());
                  } else {
                    Get.to(() => LayoutFormDiskon(idPromoToEdit: promo.idPromo))
                        ?.then((_) => _loadData());
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit Diskon Toko',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2F2828),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.edit_rounded,
                          size: 12, color: Color(0xFF2F2828)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildChip('semua', 'Semua (${apiDiskon.listDiskon.length})'),
          const SizedBox(width: 8),
          _buildChip(
            'aktif',
            'Aktif (${apiDiskon.listDiskon.where((p) => p.isCurrentlyActive).length})',
          ),
          const SizedBox(width: 8),
          _buildChip(
            'tidak_aktif',
            'Berakhir / Nonaktif (${apiDiskon.listDiskon.where((p) => !p.isCurrentlyActive).length})',
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String key, String label) {
    final bool isSelected = filterStatus == key;
    return GestureDetector(
      onTap: () => setState(() => filterStatus = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C4E40) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2C4E40)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoList() {
    var filteredList = apiDiskon.listDiskon.toList();
    if (filterStatus == 'aktif') {
      filteredList = filteredList.where((p) => p.isCurrentlyActive).toList();
    } else if (filterStatus == 'tidak_aktif') {
      filteredList = filteredList.where((p) => !p.isCurrentlyActive).toList();
    }

    if (filteredList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Program Diskon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tingkatkan transaksi sewa peralatan toko Anda dengan membuat program diskon harga.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const LayoutFormDiskon())
                        ?.then((_) => _loadData());
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Buat Diskon Pertama'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C4E40),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final promo = filteredList[index];
            return _buildPromoCard(promo);
          },
          childCount: filteredList.length,
        ),
      ),
    );
  }

  Widget _buildPromoCard(MitraDiskonModel promo) {
    final bool isAktif = promo.isCurrentlyActive;
    final String periodeStr =
        _formatPeriode(promo.tanggalMulai, promo.tanggalSelesai);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAktif
              ? const Color(0xFF2C4E40).withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Top: Label Diskon, Status, dan Menu Aksi
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAktif
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.labelDiskon,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isAktif
                          ? const Color(0xFF2F2828)
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAktif
                        ? const Color(0xFFE8F5E9)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isAktif
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAktif ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isAktif
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      size: 20, color: Colors.grey.shade600),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(() => LayoutFormDiskon(promoToEdit: promo))
                          ?.then((_) => _loadData());
                    } else if (value == 'delete') {
                      _confirmDelete(promo);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: Color(0xFF2C4E40)),
                          SizedBox(width: 8),
                          Text('Edit Diskon'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Nama Diskon
            Text(
              promo.namaDiskon,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 6),

            // Cakupan
            Row(
              children: [
                Icon(
                  promo.isSemuaProduk
                      ? Icons.store_rounded
                      : Icons.category_rounded,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    promo.isSemuaProduk
                        ? 'Semua Produk Toko • ${promo.konflikDiskon == 'replace' ? 'Samaratakan' : 'Pertahankan Diskon Lama'}'
                        : '${promo.totalProduk} Produk Pilihan Tertentu',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Tanggal Periode
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 5),
                Text(
                  periodeStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MitraDiskonModel promo) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Program Diskon?'),
        content: Text(
          'Program promo "${promo.namaDiskon}" akan dihapus. Potongan harga pada produk terkait akan dinonaktifkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await apiDiskon.deleteDiskon(promo.idPromo);
              if (mounted) {
                if (success) {
                  CustomSnackBar.show(
                    context,
                    sukses: true,
                    title: 'Berhasil',
                    teks: 'Program diskon telah dihapus',
                  );
                } else {
                  CustomSnackBar.show(
                    context,
                    sukses: false,
                    title: 'Gagal',
                    teks: 'Tidak dapat menghapus program diskon',
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
