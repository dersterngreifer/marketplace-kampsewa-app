import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter/services.dart';
import 'package:project_camp_sewa/layouts/layout_riwayat.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  static const Color _green = Color(0xFF2C4E40);
  static const Color _dark = Color(0xFF2F2828);
  static const Color _grey = Color(0xFF8E8E8E);
  static const Color _bg = Color(0xFFF7F8F7);

  late TabController _tabController;

  // Label + icon supaya lebih scannable
  final List<Map<String, dynamic>> _tabsData = const [
    {'label': 'Pembayaran', 'icon': MdiIcons.walletOutline},
    {'label': 'Pengambilan', 'icon': MdiIcons.packageVariantClosed},
    {'label': 'Berlangsung', 'icon': MdiIcons.truckDeliveryOutline},
    {'label': 'Selesai', 'icon': MdiIcons.checkCircleOutline},
    {'label': 'Denda Belum Lunas', 'icon': MdiIcons.alertCircleOutline},
    {'label': 'Dibatalkan', 'icon': MdiIcons.closeCircleOutline},
  ];

  final List<Widget> _bodyTabs = const [
    LayoutRiwayat(status: 'belum-bayar'),
    LayoutRiwayat(status: 'Pengambilan'),
    LayoutRiwayat(status: 'Berlangsung'),
    LayoutRiwayat(status: 'Selesai'),
    LayoutRiwayat(status: 'Denda Belum Lunas'),
    LayoutRiwayat(status: 'Dibatalkan'),
  ];

  @override
  void initState() {
    _tabController = TabController(length: _tabsData.length, vsync: this);
    _tabController.addListener(() {
      // Rebuild chip saat tab berubah (untuk animasi active state)
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildTabChips(),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: _bodyTabs,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Riwayat",
                  style: AppColors.fontStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),

            // Banner info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C4E40), Color(0xFF1E352B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pesanan Anda",
                            style: AppColors.fontStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Pantau status pesanan & transaksi",
                            style: AppColors.fontStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Chips (pill-style) ──────────────────────────────
  Widget _buildTabChips() {
    return SizedBox(
      height: 52,
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return ListView.separated(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.fromLTRB(20, 3, 20, 7),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _tabsData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final data = _tabsData[index];
              final label = data['label'] as String;
              final icon = data['icon'] as IconData;
              final isActive = _tabController.index == index;

              return GestureDetector(
                onTap: () {
                  _tabController.animateTo(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? _green : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isActive ? _green : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isActive
                            ? _green.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: isActive ? 8 : 4,
                        offset: Offset(0, isActive ? 3 : 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 15,
                        color: isActive ? Colors.white : _grey,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        label,
                        style: AppColors.fontStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w600,
                          color:
                              isActive ? Colors.white : const Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
