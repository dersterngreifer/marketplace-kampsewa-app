import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter/services.dart';
import 'package:project_camp_sewa/layouts/layout_riwayat.dart';
import 'package:project_camp_sewa/models/api_response.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Belum Bayar'),
    Tab(text: 'Pengambilan'),
    Tab(text: 'Berlangsung'),
    Tab(text: 'Selesai'),
    Tab(text: 'Dibatalkan'),
  ];

  final List<Widget> _bodyTabs = [
    LayoutRiwayat(riwayatData: DummyProductApiResponse.getRiwayatBelumBayar()),
    LayoutRiwayat(
        riwayatData: DummyProductApiResponse.getRiwayatPengambilanData()),
    LayoutRiwayat(riwayatData: DummyProductApiResponse.getRiwayatBerlangsung()),
    LayoutRiwayat(riwayatData: DummyProductApiResponse.getRiwayatSelesai()),
    const LayoutRiwayat(riwayatData: []),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
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
        backgroundColor: const Color(0xFFFFFFFF),
        body: Column(
          children: [
            // Premium Header extending under system bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C4E40).withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // App Bar Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Color(0xFF2C4E40),
                              ),
                            ),
                          ),
                          Text(
                            "Riwayat",
                            style: AppColors.fontStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2F2828),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                MdiIcons.magnify,
                                size: 20,
                                color: Color(0xFF2C4E40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Banner Text/Info
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2C4E40), Color(0xFF2C4E40)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2C4E40)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pesanan Anda",
                                  style: AppColors.fontStyle(
                                    color: const Color(0xFF2F2828),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Pantau status pesanan dan transaksi",
                                  style: AppColors.fontStyle(
                                    color: const Color(0xFFBDBDBD),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ), // end SafeArea
            ), // end Container

            const SizedBox(height: 16),

            // Custom TabBar - separate scrollable chips
            TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFFBDBDBD),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C4E40), Color(0xFF2C4E40)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C4E40).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              dividerColor: Colors.transparent,
              isScrollable: true,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              labelStyle: AppColors.fontStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: AppColors.fontStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _bodyTabs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
