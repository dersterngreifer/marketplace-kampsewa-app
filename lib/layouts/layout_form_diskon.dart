// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/mitra_diskon_model.dart';
import 'package:project_camp_sewa/services/api_diskon.dart';

class LayoutFormDiskon extends StatefulWidget {
  final MitraDiskonModel? promoToEdit;
  final int? idPromoToEdit;

  const LayoutFormDiskon({
    super.key,
    this.promoToEdit,
    this.idPromoToEdit,
  });

  @override
  State<LayoutFormDiskon> createState() => _LayoutFormDiskonState();
}

class _LayoutFormDiskonState extends State<LayoutFormDiskon> {
  final ApiDiskon apiDiskon = Get.find<ApiDiskon>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nilaiController = TextEditingController();
  final TextEditingController searchProductController = TextEditingController();

  String tipeDiskon = 'persen'; // 'persen' atau 'nominal'
  String cakupan = 'all_products'; // 'all_products' atau 'selected_products'
  String konflikDiskon = 'replace'; // 'replace' atau 'skip'
  bool isActive = true;

  DateTime tanggalMulai = DateTime.now();
  DateTime tanggalSelesai = DateTime.now().add(const Duration(days: 7));

  bool isLoadingAvailable = true;
  bool isSaving = false;
  AvailableProductsResponse? availableData;
  final Set<int> selectedProductIds = {};

  String selectedCategoryFilter = 'Semua';
  String searchProductQuery = '';

  bool get isEdit =>
      widget.promoToEdit != null ||
      (widget.idPromoToEdit != null && widget.idPromoToEdit! > 0);

  int? get editPromoId =>
      widget.promoToEdit?.idPromo ?? widget.idPromoToEdit;

  @override
  void initState() {
    super.initState();
    _initInitialValues();
    _fetchAvailableProducts();

    nilaiController.addListener(_onRebuild);
    searchProductController.addListener(_onSearchChanged);
  }

  void _onRebuild() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() {
    final query = searchProductController.text.trim();
    if (query != searchProductQuery && mounted) {
      setState(() {
        searchProductQuery = query;
      });
    }
  }

  void _initInitialValues() {
    if (widget.promoToEdit != null) {
      final p = widget.promoToEdit!;
      namaController.text = p.namaDiskon;
      tipeDiskon = p.tipeDiskon;
      nilaiController.text = p.nilaiDiskon.toInt().toString();
      cakupan = p.cakupan;
      konflikDiskon = p.konflikDiskon;
      isActive = p.isActive;

      if (p.tanggalMulai != null) {
        final parsed = DateTime.tryParse(p.tanggalMulai!.replaceFirst(' ', 'T'));
        if (parsed != null) tanggalMulai = parsed;
      }
      if (p.tanggalSelesai != null) {
        final parsed = DateTime.tryParse(p.tanggalSelesai!.replaceFirst(' ', 'T'));
        if (parsed != null) tanggalSelesai = parsed;
      }

      selectedProductIds.addAll(p.selectedProductIds);
    }
  }

  Future<void> _fetchAvailableProducts() async {
    setState(() => isLoadingAvailable = true);
    final res = await apiDiskon.getAvailableProducts(
      excludePromoId: editPromoId,
    );
    if (mounted) {
      setState(() {
        availableData = res;
        isLoadingAvailable = false;

        // Jika toko memiliki diskon keseluruhan aktif DAN bukan sedang mengedit diskon tersebut
        if (!isEdit && res != null && res.hasActiveStoreWidePromo) {
          // Otomatis kunci ke selected_products
          cakupan = 'selected_products';
        }
      });
    }
  }

  @override
  void dispose() {
    nilaiController.removeListener(_onRebuild);
    searchProductController.removeListener(_onSearchChanged);
    namaController.dispose();
    nilaiController.dispose();
    searchProductController.dispose();
    super.dispose();
  }

  String _formatDateDisplay(DateTime dt) {
    const namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final String day = dt.day.toString();
    final String month = namaBulan[dt.month - 1];
    final String year = dt.year.toString();
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  String _formatApiDateTime(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _pickDateTime(bool isMulai) async {
    final DateTime initial = isMulai ? tanggalMulai : tanggalSelesai;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2C4E40),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2C4E40),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null || !mounted) return;

    final result = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isMulai) {
        tanggalMulai = result;
        if (tanggalSelesai.isBefore(tanggalMulai)) {
          tanggalSelesai = tanggalMulai.add(const Duration(days: 7));
        }
      } else {
        tanggalSelesai = result;
      }
    });
  }

  List<String> get _categoryList {
    final cats = <String>['Semua'];
    if (availableData != null) {
      for (final c in availableData!.categories) {
        final trimmed = c.trim();
        if (trimmed.isNotEmpty && !cats.contains(trimmed)) {
          cats.add(trimmed);
        }
      }
    }
    return cats;
  }

  int _getProductCountForCategory(String category) {
    final products = availableData?.products ?? [];
    if (category == 'Semua') return products.length;
    return products
        .where((p) => p.kategori.toLowerCase() == category.toLowerCase())
        .length;
  }

  List<AvailableProductModel> get _filteredProducts {
    final products = availableData?.products ?? [];
    return products.where((p) {
      final matchesCategory = selectedCategoryFilter == 'Semua' ||
          p.kategori.toLowerCase() == selectedCategoryFilter.toLowerCase();
      final matchesSearch = searchProductQuery.isEmpty ||
          p.namaProduk.toLowerCase().contains(searchProductQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _selectAllProductsGlobal(bool check) {
    if (availableData == null) return;
    setState(() {
      for (var p in availableData!.products) {
        if (p.canBeDiscounted) {
          if (check) {
            selectedProductIds.add(p.idProduk);
          } else {
            selectedProductIds.remove(p.idProduk);
          }
        }
      }
    });
  }

  void _selectProductsByCategory(String category, bool check) {
    if (availableData == null) return;
    setState(() {
      for (var p in availableData!.products) {
        final matches = category == 'Semua' ||
            p.kategori.toLowerCase() == category.toLowerCase();
        if (matches && p.canBeDiscounted) {
          if (check) {
            selectedProductIds.add(p.idProduk);
          } else {
            selectedProductIds.remove(p.idProduk);
          }
        }
      }
    });
  }

  void _selectVisibleProducts(bool check) {
    final visible = _filteredProducts;
    setState(() {
      for (var p in visible) {
        if (p.canBeDiscounted) {
          if (check) {
            selectedProductIds.add(p.idProduk);
          } else {
            selectedProductIds.remove(p.idProduk);
          }
        }
      }
    });
  }


  Future<void> _submitForm() async {
    final String nama = namaController.text.trim();
    if (nama.isEmpty) {
      CustomSnackBar.show(
        context,
        sukses: false,
        title: 'Perhatian',
        teks: 'Silakan isi nama program diskon',
      );
      return;
    }

    final double? nilai = double.tryParse(nilaiController.text.trim());
    if (nilai == null || nilai <= 0) {
      CustomSnackBar.show(
        context,
        sukses: false,
        title: 'Perhatian',
        teks: 'Masukkan besaran nilai diskon yang valid',
      );
      return;
    }

    if (tipeDiskon == 'persen' && (nilai < 1 || nilai > 100)) {
      CustomSnackBar.show(
        context,
        sukses: false,
        title: 'Perhatian',
        teks: 'Persentase diskon harus di antara 1% - 100%',
      );
      return;
    }

    if (cakupan == 'selected_products' && selectedProductIds.isEmpty) {
      CustomSnackBar.show(
        context,
        sukses: false,
        title: 'Perhatian',
        teks: 'Pilih minimal satu produk untuk program diskon ini',
      );
      return;
    }

    if (tanggalSelesai.isBefore(tanggalMulai)) {
      CustomSnackBar.show(
        context,
        sukses: false,
        title: 'Perhatian',
        teks: 'Tanggal selesai tidak boleh lebih awal dari tanggal mulai',
      );
      return;
    }

    setState(() => isSaving = true);

    final res = await apiDiskon.saveDiskon(
      idPromo: editPromoId,
      namaDiskon: nama,
      tipeDiskon: tipeDiskon,
      nilaiDiskon: nilai,
      cakupan: cakupan,
      konflikDiskon: konflikDiskon,
      selectedProductIds: selectedProductIds.toList(),
      tanggalMulai: _formatApiDateTime(tanggalMulai),
      tanggalSelesai: _formatApiDateTime(tanggalSelesai),
      isActive: isActive,
    );

    setState(() => isSaving = false);

    if (!mounted) return;

    if (res['success'] == true) {
      CustomSnackBar.show(
        context,
        sukses: true,
        title: 'Berhasil',
        teks: res['message'] ?? 'Program diskon berhasil disimpan',
      );
      Get.back(result: true);
    } else {
      // Penanganan Error Khusus sesuai Panduan Tindakan Bagian 6
      final String? errCode = res['code']?.toString();

      if (errCode == 'PRODUCT_DISCOUNT_CONFLICT') {
        _showProductConflictDialog(res);
      } else if (errCode == 'ACTIVE_STORE_WIDE_EXISTS') {
        _showStoreWideExistsDialog(res);
      } else {
        CustomSnackBar.show(
          context,
          sukses: false,
          title: 'Gagal Menyimpan Diskon',
          teks: res['message'] ?? 'Terjadi kesalahan saat menyimpan promo',
        );
      }
    }
  }

  void _showProductConflictDialog(Map<String, dynamic> res) {
    final List<dynamic> conflicts = res['conflicting_products'] is List
        ? res['conflicting_products']
        : [];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Konflik Diskon Produk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              res['message'] ??
                  'Beberapa produk yang dipilih sedang memiliki program diskon aktif. Produk tidak dapat didiskon ganda.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            if (conflicts.isNotEmpty) ...[
              const Text(
                'Daftar Produk Berkonflik:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: conflicts.length,
                  itemBuilder: (_, i) {
                    final item = conflicts[i];
                    final String pName = item['nama_produk']?.toString() ?? '';
                    final currentD = item['current_discount'];
                    final String dName =
                        currentD != null && currentD is Map
                            ? (currentD['nama_diskon'] ?? '')
                            : '';
                    final String dLabel =
                        currentD != null && currentD is Map
                            ? (currentD['label_diskon'] ?? '')
                            : '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_rounded,
                              size: 14, color: Colors.deepOrange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (dName.isNotEmpty)
                                  Text(
                                    'Aktif di: $dName ($dLabel)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C4E40),
              foregroundColor: Colors.white,
            ),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showStoreWideExistsDialog(Map<String, dynamic> res) {
    final Map<String, dynamic>? activePromo = res['active_store_promo'];
    final String promoName =
        activePromo != null ? (activePromo['nama_diskon'] ?? '') : '';
    final int? promoId =
        activePromo != null ? int.tryParse(activePromo['id_promo']?.toString() ?? '') : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Diskon Toko Sedang Berjalan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              res['message'] ??
                  'Toko Anda saat ini sudah memiliki program diskon keseluruhan aktif. Anda tidak dapat membuat diskon keseluruhan baru sebelum program tersebut berakhir atau dinonaktifkan.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            if (promoName.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storefront_rounded,
                        color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Program Aktif: $promoName',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          if (promoId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Tutup form saat ini
                Get.to(() => LayoutFormDiskon(idPromoToEdit: promoId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C4E40),
                foregroundColor: Colors.white,
              ),
              child: const Text('Edit Diskon Tersebut'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStoreWideConflict = !isEdit &&
        availableData != null &&
        availableData!.hasActiveStoreWidePromo;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Diskon Produk' : 'Buat Diskon Baru',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E1E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E1E1E), size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoadingAvailable
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C4E40)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Informasi Utama Diskon
                  _buildSectionCard(
                    title: 'Informasi Diskon',
                    icon: Icons.local_offer_rounded,
                    children: [
                      _buildTextField(
                        controller: namaController,
                        label: 'Nama Program Diskon',
                        hint: 'Contoh: Promo Weekend Camping 15%',
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tipe Potongan Harga',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceCard(
                              isSelected: tipeDiskon == 'persen',
                              title: 'Persentase (%)',
                              subtitle: 'Potongan nilai %',
                              onTap: () => setState(() => tipeDiskon = 'persen'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildChoiceCard(
                              isSelected: tipeDiskon == 'nominal',
                              title: 'Nominal (Rp)',
                              subtitle: 'Potongan tetap Rp',
                              onTap: () => setState(() => tipeDiskon = 'nominal'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: nilaiController,
                        label: tipeDiskon == 'persen'
                            ? 'Persentase Diskon (%)'
                            : 'Nominal Potongan (Rp)',
                        hint: tipeDiskon == 'persen' ? '15' : '20000',
                        keyboardType: TextInputType.number,
                        suffixText: tipeDiskon == 'persen' ? '%' : 'Rp',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Cakupan Produk & Strategi Konflik
                  _buildSectionCard(
                    title: 'Cakupan Produk',
                    icon: Icons.inventory_2_rounded,
                    children: [
                      // Banner peringatan jika toko sedang memiliki diskon keseluruhan aktif
                      if (hasStoreWideConflict) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lock_rounded,
                                  color: Colors.deepOrange, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Toko Anda sedang memiliki diskon keseluruhan aktif ("${availableData?.activeStoreWidePromo?.namaDiskon ?? 'Diskon Toko'}"). Opsi diskon semua produk dinonaktifkan.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade900,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Radio: Semua Produk di Toko
                      Opacity(
                        opacity: hasStoreWideConflict ? 0.45 : 1.0,
                        child: IgnorePointer(
                          ignoring: hasStoreWideConflict,
                          child: InkWell(
                            onTap: () {
                              setState(() => cakupan = 'all_products');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cakupan == 'all_products'
                                    ? const Color(0xFF2C4E40)
                                        .withValues(alpha: 0.06)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: cakupan == 'all_products'
                                      ? const Color(0xFF2C4E40)
                                      : Colors.grey.shade300,
                                  width:
                                      cakupan == 'all_products' ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'all_products',
                                    groupValue: cakupan,
                                    activeColor: const Color(0xFF2C4E40),
                                    onChanged: (val) {
                                      if (!hasStoreWideConflict && val != null) {
                                        setState(() => cakupan = val);
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Semua Produk di Toko',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1E1E1E),
                                              ),
                                            ),
                                            if (hasStoreWideConflict) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Sedang Berjalan',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.red.shade800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Berlaku otomatis ke seluruh inventaris produk',
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
                            ),
                          ),
                        ),
                      ),

                      // SUB-OPSI PENANGANAN KONFLIK (Jika all_products dipilih)
                      if (cakupan == 'all_products') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF2C4E40)
                                    .withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.tune_rounded,
                                      size: 16, color: Color(0xFF2C4E40)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Strategi Konflik Diskon Produk Lama',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2C4E40),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildKonflikRadioItem(
                                value: 'replace',
                                title:
                                    'Samaratakan ke Semua Produk (Replace Diskon Lama)',
                                description:
                                    'Diskon lama pada produk akan dilepas dan disamaratakan ke nilai diskon baru ini.',
                              ),
                              const SizedBox(height: 6),
                              _buildKonflikRadioItem(
                                value: 'skip',
                                title:
                                    'Pertahankan Diskon Lama (Lewati/Skip)',
                                description:
                                    'Produk yang sedang promo tetap memakai diskon lamanya. Diskon baru hanya berlaku untuk produk lain.',
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Radio: Produk Pilihan Tertentu
                      InkWell(
                        onTap: () {
                          setState(() => cakupan = 'selected_products');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cakupan == 'selected_products'
                                ? const Color(0xFF2C4E40)
                                    .withValues(alpha: 0.06)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cakupan == 'selected_products'
                                  ? const Color(0xFF2C4E40)
                                  : Colors.grey.shade300,
                              width:
                                  cakupan == 'selected_products' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'selected_products',
                                groupValue: cakupan,
                                activeColor: const Color(0xFF2C4E40),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => cakupan = val);
                                  }
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Produk Pilihan Tertentu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E1E1E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Pilih manual barang-barang camping yang ingin didiskon',
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
                        ),
                      ),

                      // CHECKLIST DAFTAR PRODUK (Jika selected_products dipilih)
                      if (cakupan == 'selected_products') ...[
                        const SizedBox(height: 12),
                        _buildProductChecklistSection(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Periode Tanggal & Status
                  _buildSectionCard(
                    title: 'Periode & Status',
                    icon: Icons.calendar_month_rounded,
                    children: [
                      // Tanggal Mulai
                      _buildDateSelector(
                        label: 'Tanggal Mulai',
                        date: tanggalMulai,
                        onTap: () => _pickDateTime(true),
                      ),
                      const SizedBox(height: 12),
                      // Tanggal Selesai
                      _buildDateSelector(
                        label: 'Tanggal Selesai (Batas Akhir)',
                        date: tanggalSelesai,
                        onTap: () => _pickDateTime(false),
                      ),
                      const SizedBox(height: 16),
                      // Switch Aktif
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Program Diskon',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              Text(
                                isActive ? 'Aktif dan dapat digunakan' : 'Draft / Nonaktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isActive,
                            activeColor: const Color(0xFF2C4E40),
                            onChanged: (val) => setState(() => isActive = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Tombol Submit Simpan Diskon
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C4E40),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEdit ? 'Simpan Perubahan Diskon' : 'Buat Program Diskon',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2C4E40)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C4E40),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2C4E40), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required bool isSelected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2C4E40).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C4E40) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? const Color(0xFF2C4E40)
                    : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKonflikRadioItem({
    required String value,
    required String title,
    required String description,
  }) {
    final bool isSelected = konflikDiskon == value;
    return GestureDetector(
      onTap: () => setState(() => konflikDiskon = value),
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2C4E40)
                : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: konflikDiskon,
              activeColor: const Color(0xFF2C4E40),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) setState(() => konflikDiskon = val);
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPricePreview(AvailableProductModel p) {
    final double? rawNilai = double.tryParse(nilaiController.text.trim());
    final bool hasValidDiscount = rawNilai != null && rawNilai > 0;

    int discountedPrice = p.hargaNormal;
    int hemat = 0;

    if (hasValidDiscount) {
      if (tipeDiskon == 'persen') {
        final double pct = rawNilai.clamp(0, 100);
        final int discountAmount = (p.hargaNormal * (pct / 100)).round();
        discountedPrice =
            (p.hargaNormal - discountAmount).clamp(0, p.hargaNormal);
        hemat = p.hargaNormal - discountedPrice;
      } else {
        final int discountAmount = rawNilai.toInt();
        discountedPrice =
            (p.hargaNormal - discountAmount).clamp(0, p.hargaNormal);
        hemat = p.hargaNormal - discountedPrice;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.kategori.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300, width: 0.8),
            ),
            child: Text(
              p.kategori,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 2,
          children: [
            if (hasValidDiscount && hemat > 0) ...[
              Text(
                'Rp ${formatCurrency(p.hargaNormal)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rp ${formatCurrency(discountedPrice)}/hari',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C4E40),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  tipeDiskon == 'persen'
                      ? '-${rawNilai.toInt()}%'
                      : 'Hemat Rp ${formatCurrency(hemat)}',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Rp ${formatCurrency(p.hargaNormal)} / hari',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProductChecklistSection() {
    final allProducts = availableData?.products ?? [];

    if (allProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Toko Anda belum memiliki produk untuk dipilih.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final visibleProducts = _filteredProducts;
    final eligibleVisible =
        visibleProducts.where((p) => p.canBeDiscounted).toList();
    final eligibleAll = allProducts.where((p) => p.canBeDiscounted).toList();
    final bool isFiltered =
        selectedCategoryFilter != 'Semua' || searchProductQuery.isNotEmpty;

    final bool allVisibleSelected = eligibleVisible.isNotEmpty &&
        eligibleVisible.every((p) => selectedProductIds.contains(p.idProduk));
    final bool allEligibleSelected = eligibleAll.isNotEmpty &&
        eligibleAll.every((p) => selectedProductIds.contains(p.idProduk));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Box
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: searchProductController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari nama produk...',
              hintStyle:
                  TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Color(0xFF2C4E40),
              ),
              suffixIcon: searchProductQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      color: Colors.grey.shade600,
                      onPressed: () {
                        searchProductController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 2. Horizontal Category Filter Chips
        if (_categoryList.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categoryList.map((cat) {
                final bool isSelected = selectedCategoryFilter == cat;
                final int count = _getProductCountForCategory(cat);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() => selectedCategoryFilter = cat);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2C4E40)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2C4E40)
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 3. Selection Summary & Bulk Action Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF2C4E40).withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Color(0xFF2C4E40),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${selectedProductIds.length} produk dipilih',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C4E40),
                          ),
                        ),
                      ],
                    ),
                    if (isFiltered)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Menampilkan ${visibleProducts.length} produk',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Tombol Kontekstual Pilih/Batal Visible
                  InkWell(
                    onTap: eligibleVisible.isEmpty
                        ? null
                        : () {
                            _selectVisibleProducts(!allVisibleSelected);
                          },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: eligibleVisible.isEmpty
                            ? Colors.grey.shade200
                            : const Color(0xFF2C4E40).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isFiltered
                            ? (allVisibleSelected
                                ? 'Batal (${visibleProducts.length})'
                                : 'Pilih (${eligibleVisible.length})')
                            : (allEligibleSelected
                                ? 'Batal Semua'
                                : 'Pilih Semua (${eligibleAll.length})'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: eligibleVisible.isEmpty
                              ? Colors.grey
                              : const Color(0xFF2C4E40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Popup Menu Centang Cepat per Kategori
                  PopupMenuButton<String>(
                    tooltip: 'Centang per Kategori',
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(
                        Icons.playlist_add_check_rounded,
                        size: 16,
                        color: Color(0xFF2C4E40),
                      ),
                    ),
                    onSelected: (val) {
                      if (val == 'select_all') {
                        _selectAllProductsGlobal(true);
                      } else if (val == 'deselect_all') {
                        _selectAllProductsGlobal(false);
                      } else if (val.startsWith('select_cat:')) {
                        final catName = val.substring('select_cat:'.length);
                        _selectProductsByCategory(catName, true);
                      } else if (val.startsWith('deselect_cat:')) {
                        final catName = val.substring('deselect_cat:'.length);
                        _selectProductsByCategory(catName, false);
                      }
                    },
                    itemBuilder: (ctx) {
                      final items = <PopupMenuEntry<String>>[];
                      items.add(
                        const PopupMenuItem(
                          value: 'select_all',
                          child: Row(
                            children: [
                              Icon(Icons.done_all_rounded,
                                  size: 16, color: Color(0xFF2C4E40)),
                              SizedBox(width: 8),
                              Text('Centang Semua Produk Toko',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                      items.add(
                        const PopupMenuItem(
                          value: 'deselect_all',
                          child: Row(
                            children: [
                              Icon(Icons.remove_done_rounded,
                                  size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Batal Centang Semua',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                      if (_categoryList.where((c) => c != 'Semua').isNotEmpty) {
                        items.add(const PopupMenuDivider());
                        for (final c in _categoryList) {
                          if (c == 'Semua') continue;
                          final eligibleInCat = allProducts
                              .where((p) =>
                                  p.kategori.toLowerCase() ==
                                      c.toLowerCase() &&
                                  p.canBeDiscounted)
                              .length;
                          items.add(
                            PopupMenuItem(
                              value: 'select_cat:$c',
                              child: Row(
                                children: [
                                  const Icon(Icons.check_box_outlined,
                                      size: 15, color: Color(0xFF2C4E40)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Centang $c ($eligibleInCat)',
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                      return items;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 4. List Produk atau Tampilan Kosong
        if (visibleProducts.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 38, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  searchProductQuery.isNotEmpty
                      ? 'Tidak ada produk bernama "$searchProductQuery"'
                      : 'Tidak ada produk dalam kategori "$selectedCategoryFilter"',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      searchProductController.clear();
                      selectedCategoryFilter = 'Semua';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: Color(0xFF2C4E40)),
                  ),
                  child: const Text(
                    'Reset Filter & Cari',
                    style: TextStyle(fontSize: 11, color: Color(0xFF2C4E40)),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = visibleProducts[index];
              final bool isLocked = p.isLocked;
              final bool isChecked = selectedProductIds.contains(p.idProduk);

              return Opacity(
                opacity: isLocked ? 0.6 : 1.0,
                child: InkWell(
                  onTap: isLocked
                      ? null
                      : () {
                          setState(() {
                            if (isChecked) {
                              selectedProductIds.remove(p.idProduk);
                            } else {
                              selectedProductIds.add(p.idProduk);
                            }
                          });
                        },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? const Color(0xFF2C4E40).withValues(alpha: 0.04)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isChecked
                            ? const Color(0xFF2C4E40)
                            : Colors.grey.shade200,
                        width: isChecked ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Checkbox(
                            value: isChecked,
                            activeColor: const Color(0xFF2C4E40),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: isLocked
                                ? null
                                : (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedProductIds.add(p.idProduk);
                                      } else {
                                        selectedProductIds.remove(p.idProduk);
                                      }
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Foto Produk
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: p.foto != null && p.foto!.isNotEmpty
                                ? Image.network(
                                    getImageUrl(p.foto),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 20,
                                    ),
                                  )
                                : const Icon(Icons.inventory_2_rounded,
                                    size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Detail Produk & Live Price Preview
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.namaProduk,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),

                              // Realtime Price Preview & Category Tag
                              _buildProductPricePreview(p),

                              // Badge Penguncian Produk jika aktif di promo lain
                              if (isLocked && p.currentDiscount != null) ...[
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock_rounded,
                                          size: 11,
                                          color: Colors.deepOrange),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Aktif: ${p.currentDiscount!.namaDiskon} (${p.currentDiscount!.labelDiskon})',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.orange.shade900,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateDisplay(date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
