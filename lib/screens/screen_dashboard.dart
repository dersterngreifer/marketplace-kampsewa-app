import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Wajib ditambahkan untuk Cupertino Icons
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/layouts/layout_chat_list.dart';
import 'package:project_camp_sewa/layouts/layout_dashboard.dart';
import 'package:project_camp_sewa/layouts/layout_product.dart';
import 'package:project_camp_sewa/layouts/layout_profile.dart';
import 'package:project_camp_sewa/screens/screen_riwayat.dart';
import 'package:project_camp_sewa/services/api_chat.dart';
import 'package:project_camp_sewa/services/controller_dashboard.dart';

class ScreenDashboard extends StatefulWidget {
  const ScreenDashboard({super.key});

  @override
  State<ScreenDashboard> createState() => _ScreenDashboardState();
}

class _ScreenDashboardState extends State<ScreenDashboard> {
  final DashboardController pageController = Get.put(DashboardController());
  final ApiChat apiChat = Get.put(ApiChat());

  final List<Widget> _pages = const [
    LayoutDashboard(),
    LayoutProduct(),
    LayoutChatList(),
    RiwayatScreen(),
    LayoutProfile(),
  ];

  static const Color _activeColor = Color(0xFF2C4E40);
  static const Color _inactiveColor = Colors.black;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiChat.getUnreadSummary();
    });
  }

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
        backgroundColor: Colors.white,
        body: Obx(() => _pages[pageController.pageIndex.value]),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── BOTTOM NAVIGATION BAR NORMAL ──
  Widget _buildBottomNav() {
    return Obx(() {
      final int selected = pageController.pageIndex.value;
      // Menambahkan padding bawah untuk perangkat dengan safe area (misal: iPhone dengan garis gestur)
      final double bottomPadding = MediaQuery.of(context).padding.bottom;

      return Container(
        height: 64 + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  0.06), // Shadow tipis agar tidak menyatu dengan background
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
                0, CupertinoIcons.house, CupertinoIcons.house_fill, selected),
            _buildNavItem(1, CupertinoIcons.square_grid_2x2,
                CupertinoIcons.square_grid_2x2_fill, selected),

            // Menu Chat (Index 2) dengan penanda isChat = true untuk menampilkan Badge Unread
            _buildNavItem(2, CupertinoIcons.chat_bubble_2,
                CupertinoIcons.chat_bubble_2_fill, selected,
                isChat: true),

            _buildNavItem(3, CupertinoIcons.doc_plaintext,
                CupertinoIcons.doc_text_fill, selected),
            _buildNavItem(
                4, CupertinoIcons.person, CupertinoIcons.person_fill, selected),
          ],
        ),
      );
    });
  }

  // ── MENU ITEM DENGAN CUPERTINO ICONS ──
  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    int selected, {
    bool isChat = false,
  }) {
    final bool isActive = selected == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => pageController.setPageIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Background lingkaran sempurna saat aktif
              color: isActive
                  ? _activeColor.withOpacity(0.12)
                  : Colors.transparent,
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    color: isActive ? _activeColor : _inactiveColor,
                    size:
                        26, // Ukuran sedikit diperkecil agar terlihat lebih modern/rapi
                  ),
                ),

                // Menampilkan Badge Merah HANYA jika ini adalah menu Chat dan ada pesan belum dibaca
                if (isChat)
                  Obx(() {
                    final int count = apiChat.totalUnread.value;
                    if (count <= 0) return const SizedBox.shrink();

                    return Positioned(
                      top: 6,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
