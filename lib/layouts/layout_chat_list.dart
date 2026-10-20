import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/models/chat_room_model.dart';
import 'package:project_camp_sewa/services/api_chat.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/layouts/layout_chat_room.dart';
import 'package:shimmer/shimmer.dart';

class LayoutChatList extends StatefulWidget {
  const LayoutChatList({super.key});

  @override
  State<LayoutChatList> createState() => _LayoutChatListState();
}

class _LayoutChatListState extends State<LayoutChatList>
    with SingleTickerProviderStateMixin {
  final ApiChat apiChat = Get.put(ApiChat());
  final TextEditingController _searchCtrl = TextEditingController();
  TabController? _tabController;

  String _query = '';

  // Warna turunan dari mainColor
  Color get _main => AppColors.mainColor;
  Color get _mainDark {
    final hsl = HSLColor.fromColor(_main);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }

  // Latar body: abu muda dengan sentuhan warna utama
  Color get _bg =>
      Color.alphaBlend(_main.withValues(alpha: 0.06), const Color(0xFFF6F7F9));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiChat.getChatRooms();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

  String _displayName(ChatRoomModel chat) {
    return (chat.user?.namaToko?.isNotEmpty == true)
        ? chat.user!.namaToko!
        : (chat.user?.name ?? 'Pengguna');
  }

  String _formatTime(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(day).inDays;

      if (diff == 0) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (diff == 1) {
        return 'Kemarin';
      } else {
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${(dt.year % 100).toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return '';
    }
  }

  List<ChatRoomModel> _applyFilter(List<ChatRoomModel> all,
      {required bool onlyUnread}) {
    final q = _query.trim().toLowerCase();
    return all.where((c) {
      // Pastikan pesan admin tidak masuk ke list chat room antar pengguna
      if (c.user?.type == 1) return false;
      if (onlyUnread && c.unreadCount <= 0) return false;
      if (q.isEmpty) return true;
      return _displayName(c).toLowerCase().contains(q) ||
          (c.lastMessage ?? '').toLowerCase().contains(q);
    }).toList();
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTabContent(onlyUnread: false),
                  _buildTabContent(onlyUnread: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header berwarna: judul + search + tab bar (satu blok gradient)
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_main, _mainDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _main.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pesan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() {
                          final n = apiChat.chatRooms
                              .where((c) => c.user?.type != 1 && c.unreadCount > 0)
                              .length;
                          return Text(
                            n > 0
                                ? '$n percakapan belum dibaca'
                                : 'Semua pesan sudah dibaca',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12.5,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.forum_rounded,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 6),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari nama atau pesan',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _main),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: Colors.grey.shade600),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }

  /// Tab bar gaya underline (bukan tombol): teks + garis indikator di bawah
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: false,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.white, width: 3.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        insets: EdgeInsets.symmetric(horizontal: 2),
      ),
      overlayColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.1)),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
      tabs: [
        const Tab(height: 44, text: 'Semua'),
        Tab(
          height: 44,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Belum dibaca'),
              Obx(() {
                final n =
                    apiChat.chatRooms.where((c) => c.user?.type != 1 && c.unreadCount > 0).length;
                if (n == 0) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    n > 99 ? '99+' : '$n',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: _mainDark,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent({required bool onlyUnread}) {
    return Obx(() {
      if (apiChat.isLoadingRooms.value && apiChat.chatRooms.isEmpty) {
        return _buildShimmer();
      }
      final chats =
          _applyFilter(apiChat.chatRooms.toList(), onlyUnread: onlyUnread);
      return _buildChatList(chats, onlyUnread: onlyUnread);
    });
  }

  Widget _buildChatList(List<ChatRoomModel> chats, {required bool onlyUnread}) {
    if (chats.isEmpty) {
      return RefreshIndicator(
        color: _main,
        onRefresh: () async => await apiChat.getChatRooms(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: _main.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _query.isNotEmpty
                      ? Icons.search_off_rounded
                      : onlyUnread
                          ? Icons.mark_chat_read_rounded
                          : Icons.chat_bubble_outline_rounded,
                  size: 52,
                  color: _main.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _query.isNotEmpty
                  ? 'Tidak ada hasil untuk "$_query"'
                  : onlyUnread
                      ? 'Semua pesan sudah dibaca'
                      : 'Belum ada pesan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _main,
      onRefresh: () async => await apiChat.getChatRooms(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildChatTile(chats[index]),
      ),
    );
  }

  Widget _buildChatTile(ChatRoomModel chat) {
    final unread = chat.unreadCount;
    final hasUnread = unread > 0;
    final name = _displayName(chat);
    final time = _formatTime(chat.updatedAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: hasUnread 
            ? Border.all(color: _main, width: 1.5) 
            : null,
        boxShadow: hasUnread
            ? [
                BoxShadow(
                  color: _main.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  spreadRadius: 1,
                  blurRadius: 0,
                  offset: Offset.zero,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.to(() => LayoutChatRoom(chatRoom: chat))?.then((_) {
                apiChat.getChatRooms();
              });
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _buildAvatar(name, chat.user?.fotoProfile),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: hasUnread
                                              ? FontWeight.w800
                                              : FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (time.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: hasUnread
                                              ? _main
                                              : Colors.grey.shade500,
                                          fontWeight: hasUnread
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (!hasUnread)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: chat.isReadLast == 1
                                            ? const Icon(Icons.done_all_rounded,
                                                size: 16,
                                                color: Colors.blueAccent)
                                            : const Icon(Icons.done_rounded,
                                                size: 16,
                                                color: Colors.black87),
                                      ),
                                    Expanded(
                                      child: Text(
                                        (chat.lastMessage?.isNotEmpty == true)
                                            ? chat.lastMessage!
                                            : 'Mulai percakapan',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.black87,
                                          fontWeight: hasUnread
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (hasUnread) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        constraints: const BoxConstraints(
                                            minWidth: 22, minHeight: 22),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _main,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          unread > 99 ? '99+' : '$unread',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, String? url) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    // Fallback inisial dengan gradient, bukan abu-abu polos
    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _main.withValues(alpha: 0.85),
            _mainDark,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return SizedBox(
      width: 54,
      height: 54,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
              )
            : fallback,
      ),
    );
  }
  Widget _buildShimmer() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 82, // Tinggi kasar dari chat tile
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 150, height: 14, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 12, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
