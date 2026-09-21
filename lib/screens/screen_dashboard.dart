import 'package:flutter/services.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/layouts/layout_dashboard.dart';
import 'package:project_camp_sewa/layouts/layout_product.dart';
import 'package:project_camp_sewa/layouts/layout_profile.dart';
import 'package:project_camp_sewa/screens/screen_riwayat.dart';
import 'package:project_camp_sewa/services/controller_dashboard.dart';

class ScreenDashboard extends StatefulWidget {
  const ScreenDashboard({super.key});

  @override
  State<ScreenDashboard> createState() => _ScreenDashboardState();
}

class _ScreenDashboardState extends State<ScreenDashboard> {
  DashboardController pageController = Get.put(DashboardController());
  List pages = const [
    LayoutDashboard(),
    LayoutProduct(),
    RiwayatScreen(),
    LayoutProfile()
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.grid_view_rounded, label: 'Produk'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Riwayat'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        bottomNavigationBar: _buildBottomNav(),
        body: Obx(() => pages[pageController.pageIndex.value]),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(() {
            final selectedIndex = pageController.pageIndex.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () =>
                      setState(() => pageController.setPageIndex(index)),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dot indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2C4E40)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        item.icon,
                        color: isSelected
                            ? const Color(0xFF2C4E40)
                            : const Color(0xFFBDBDBD),
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppColors.fontStyle(
                          color: isSelected
                              ? const Color(0xFF2C4E40)
                              : const Color(0xFFBDBDBD),
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

