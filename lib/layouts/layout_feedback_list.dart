// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/layouts/layout_feedback_chat.dart';
import 'package:project_camp_sewa/layouts/layout_feedback_kirim.dart';
import 'package:project_camp_sewa/models/feedback_model.dart';
import 'package:project_camp_sewa/services/feedback_chat_service.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:intl/intl.dart';

/// Halaman daftar percakapan/feedback Customer.
class LayoutFeedbackList extends StatefulWidget {
  const LayoutFeedbackList({super.key});

  @override
  State<LayoutFeedbackList> createState() => _LayoutFeedbackListState();
}

class _LayoutFeedbackListState extends State<LayoutFeedbackList>
    with SingleTickerProviderStateMixin {
  late final FeedbackChatService _service;
  late final TabController _tabCtrl;
  final ScrollController _scrollCtrl = ScrollController();

  static const _tabs = ['Semua', 'Belum Dibalas', 'Dibalas'];
  static const _tabFilters = ['', 'Belum Dibalas', 'Dibalas'];

  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _service = Get.put(FeedbackChatService(), tag: 'list');
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeTab = _tabCtrl.index);
        _service.loadFeedbackList(statusFilter: _tabFilters[_tabCtrl.index]);
        _service.startListPolling(statusFilter: _tabFilters[_tabCtrl.index]);
      }
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _service.loadMoreFeedback(statusFilter: _tabFilters[_activeTab]);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service.loadFeedbackList();
      _service.startListPolling();
    });
  }

  @override
  void dispose() {
    _service.stopListPolling();
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    Get.delete<FeedbackChatService>(tag: 'list');
    super.dispose();
  }

  // ── Format tanggal ISO-8601 ──────────────────────────────────────────────
  String _formatListDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);
      if (msgDay == today) return DateFormat('HH:mm').format(dt);
      if (today.difference(msgDay).inDays == 1) return 'Kemarin';
      if (today.difference(msgDay).inDays < 7) {
        return DateFormat('EEEE', 'id').format(dt);
      }
      return DateFormat('d MMM', 'id').format(dt);
    } catch (_) {
      return '';
    }
  }



  // ── Avatar di card list ──────────────────────────────────────────────────
  /// Tampilkan foto admin terakhir jika ada. Jika belum dibalas → ikon jam.
  Widget _buildListAvatar(FeedbackItem item) {
    final fotoUrl = item.adminFotoUrl;
    final initials = item.adminInitials;
    final isBelumDibalas = !item.sudahDibalas;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isBelumDibalas
            ? const Color(0xFFFFF3E0)
            : const Color(0xFF2C4E40).withValues(alpha: 0.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: isBelumDibalas
          // Belum ada pembalas → ikon jam pasir / tunggu
          ? const Icon(MdiIcons.clockOutline,
              color: Color(0xFFF57C00), size: 26)
          : fotoUrl.isNotEmpty
              ? Image.network(
                  fotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildInitialsAvatarSmall(initials),
                )
              : _buildInitialsAvatarSmall(initials),
    );
  }

  Widget _buildInitialsAvatarSmall(String initials) {
    return Container(
      color: const Color(0xFF2C4E40).withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppColors.fontStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2C4E40),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2C4E40),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F3),
        body: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(child: _buildBody()),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFF2C4E40),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masukan & Chat',
                      style: AppColors.fontStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Percakapan dengan Admin KampSewa',
                      style: AppColors.fontStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge total unread
              Obx(() {
                final unread = _service.totalUnread.value;
                if (unread == 0) return const SizedBox.shrink();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : unread.toString(),
                    style: AppColors.fontStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF2C4E40),
      child: TabBar(
        controller: _tabCtrl,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
        labelStyle: AppColors.fontStyle(
            fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppColors.fontStyle(
            fontSize: 13, fontWeight: FontWeight.w500),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_service.isLoadingList.value && _service.feedbackList.isEmpty) {
        return _buildShimmer();
      }
      if (_service.feedbackList.isEmpty) return _buildEmptyState();
      return RefreshIndicator(
        color: const Color(0xFF2C4E40),
        backgroundColor: Colors.white,
        onRefresh: () =>
            _service.loadFeedbackList(statusFilter: _tabFilters[_activeTab]),
        child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: _service.feedbackList.length +
              (_service.hasMorePages.value ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= _service.feedbackList.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF2C4E40), strokeWidth: 2)),
              );
            }
            return _buildFeedbackCard(_service.feedbackList[i]);
          },
        ),
      );
    });
  }

  // ── Card percakapan ───────────────────────────────────────────────────────
  Widget _buildFeedbackCard(FeedbackItem item) {
    final unread = item.unreadAdminMessagesCount;
    final latestMsg = item.latestMessage;
    final lastText = latestMsg?.message ?? item.deskripsi;
    final lastTime = latestMsg?.createdAt ?? item.createdAt;
    final isBelumDibalas = !item.sudahDibalas;

    // Label pengirim pesan terakhir
    final String lastSenderLabel;
    if (latestMsg == null) {
      lastSenderLabel = '';
    } else if (latestMsg.senderType == 'customer') {
      lastSenderLabel = 'Kamu: ';
    } else {
      // Tampilkan nama admin yang membalas
      final adminName = latestMsg.sender?.name;
      lastSenderLabel =
          adminName != null && adminName.isNotEmpty ? '$adminName: ' : 'Admin: ';
    }

    final chipColor = isBelumDibalas
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE8F5E9);
    final chipTextColor = isBelumDibalas
        ? const Color(0xFFF57C00)
        : const Color(0xFF2C4E40);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => LayoutFeedbackChat(
                  feedbackId: item.id,
                  adminId: item.adminId,
                  initialKriteria: item.kriteria,
                ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar dinamis
                _buildListAvatar(item),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Nama + waktu
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama admin (atau "Menunggu pembalas")
                                Text(
                                  isBelumDibalas
                                      ? 'Menunggu Admin Pembalas'
                                      : item.displayName,
                                  style: AppColors.fontStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isBelumDibalas
                                        ? const Color(0xFFF57C00)
                                        : const Color(0xFF2F2828),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatListDate(lastTime),
                            style: AppColors.fontStyle(
                              fontSize: 11,
                              color: unread > 0
                                  ? const Color(0xFF2C4E40)
                                  : const Color(0xFF8A8A8E),
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Baris 2: Preview pesan terakhir + badge unread
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (lastSenderLabel.isNotEmpty)
                                    TextSpan(
                                      text: lastSenderLabel,
                                      style: AppColors.fontStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: unread > 0
                                            ? const Color(0xFF2C4E40)
                                            : const Color(0xFF8A8A8E),
                                      ),
                                    ),
                                  TextSpan(
                                    text: lastText,
                                    style: AppColors.fontStyle(
                                      fontSize: 13,
                                      color: unread > 0
                                          ? const Color(0xFF2F2828)
                                          : const Color(0xFF8A8A8E),
                                      fontWeight: unread > 0
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unread > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C4E40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : unread.toString(),
                                style: AppColors.fontStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Chip kriteria + status
                      Row(
                        children: [
                          _buildChip(item.kriteria, const Color(0xFFF3E5F5),
                              const Color(0xFF9C27B0)),
                          const SizedBox(width: 6),
                          _buildChip(item.status, chipColor, chipTextColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppColors.fontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Get.to(() => const LayoutFeedbackKirim());
        if (result != null && result is FeedbackItem) {
          Get.to(() => LayoutFeedbackChat(
                feedbackId: result.id,
                initialKriteria: result.kriteria,
              ));
          _service.loadFeedbackList();
        }
      },
      backgroundColor: const Color(0xFF2C4E40),
      foregroundColor: Colors.white,
      icon: const Icon(MdiIcons.plus),
      label: Text(
        'Kirim Masukan',
        style: AppColors.fontStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _activeTab != 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C4E40).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? MdiIcons.filterRemoveOutline
                    : MdiIcons.chatOutline,
                size: 52,
                color: const Color(0xFF2C4E40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? 'Tidak ada percakapan di tab ini'
                  : 'Belum Ada Masukan',
              style: AppColors.fontStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F2828),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Coba pilih tab lain atau kirim masukan baru.'
                  : 'Kirim masukan pertamamu dan mulai percakapan dengan Admin KampSewa.',
              style: AppColors.fontStyle(
                fontSize: 13,
                color: const Color(0xFF8A8A8E),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!isFiltered)
              ElevatedButton.icon(
                onPressed: () async {
                  final result =
                      await Get.to(() => const LayoutFeedbackKirim());
                  if (result != null && result is FeedbackItem) {
                    Get.to(() => LayoutFeedbackChat(
                          feedbackId: result.id,
                          initialKriteria: result.kriteria,
                        ));
                    _service.loadFeedbackList();
                  }
                },
                icon: const Icon(MdiIcons.plus),
                label: const Text('Kirim Masukan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C4E40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 14, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Container(
                      width: double.infinity,
                      height: 12,
                      color: Colors.grey.shade200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
