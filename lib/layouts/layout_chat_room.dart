import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/chat_message_model.dart';
import 'package:project_camp_sewa/models/chat_room_model.dart';
import 'package:project_camp_sewa/services/api_chat.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:shimmer/shimmer.dart';

class LayoutChatRoom extends StatefulWidget {
  final ChatRoomModel? chatRoom;
  final Map<String, dynamic>? chatData;
  final int? targetUserId;

  const LayoutChatRoom(
      {super.key, this.chatRoom, this.chatData, this.targetUserId});

  @override
  State<LayoutChatRoom> createState() => _LayoutChatRoomState();
}

class _LayoutChatRoomState extends State<LayoutChatRoom> {
  final ApiChat apiChat = Get.find<ApiChat>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _showScrollDown = ValueNotifier(false);

  late String targetName;
  String? targetAvatarUrl; // full URL, siap pakai
  int? receiverId;

  // ─── Warna turunan dari mainColor (selaras dengan halaman daftar chat) ─────

  Color get _main => AppColors.mainColor;
  Color get _mainDark {
    final hsl = HSLColor.fromColor(_main);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }

  Color get _bg =>
      Color.alphaBlend(_main.withValues(alpha: 0.06), const Color(0xFFF6F7F9));

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Resolve foto ke full URL dengan pola yang sama seperti layout_profile.dart
  String? _resolveAvatar(String rawFoto, bool isToko) {
    if (rawFoto.isEmpty) return null;
    if (rawFoto.startsWith('http')) return rawFoto;
    if (isToko) return getFotoTokoUrl(rawFoto);
    return ApiEndpoints.baseUrl +
        ApiEndpoints.authendpoints.getFotoProfile +
        rawFoto;
  }

  /// Label pemisah tanggal gaya WhatsApp
  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _timeLabel(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  bool _isDifferentDay(ChatMessageModel a, ChatMessageModel b) {
    try {
      final da = DateTime.parse(a.createdAt!).toLocal();
      final db = DateTime.parse(b.createdAt!).toLocal();
      return da.year != db.year || da.month != db.month || da.day != db.day;
    } catch (_) {
      return false;
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    if (widget.chatRoom != null) {
      final room = widget.chatRoom!;
      targetName = room.user?.namaToko?.isNotEmpty == true
          ? room.user!.namaToko!
          : (room.user?.name ?? 'Pengguna');
      receiverId = room.user?.id;
      targetAvatarUrl = room.user?.fotoProfile;
    } else {
      final data = widget.chatData ?? {};
      targetName = data['name'] ?? 'Pengguna';
      receiverId = widget.targetUserId ?? (data['targetUserId'] as int?);
      final rawFoto = (data['avatar'] ?? '').toString();
      final isToko = data['isToko'] == true;
      targetAvatarUrl = _resolveAvatar(rawFoto, isToko);
    }

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      // list reversed: offset 0 = paling bawah (pesan terbaru)
      final shouldShow = _scrollController.offset > 400;
      if (_showScrollDown.value != shouldShow) {
        _showScrollDown.value = shouldShow;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiChat.chatMessages.clear();
      if (widget.chatRoom?.roomId != null) {
        apiChat.getChatMessages(widget.chatRoom!.roomId!);
      } else if (receiverId != null) {
        apiChat.getChatMessagesByUser(receiverId!);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _showScrollDown.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || receiverId == null) return;
    _messageController.clear();
    _focusNode.requestFocus();
    final success = await apiChat.sendMessage(receiverId!, text);
    if (success) _scrollToBottom();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final int currentUserId = Get.find<ApiDataUser>().dataUser.value?.id ?? 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildMessages(currentUserId),
                  Positioned(
                    right: 16,
                    bottom: 12,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _showScrollDown,
                      builder: (_, show, __) => AnimatedScale(
                        scale: show ? 1 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Material(
                          color: Colors.white,
                          elevation: 3,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _scrollToBottom,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: _main, size: 26),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_main, _mainDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _main.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 16, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              _buildAvatar(targetName, targetAvatarUrl, size: 44, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chat langsung',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Daftar pesan ──────────────────────────────────────────────────────────

  Widget _buildMessages(int currentUserId) {
    return Obx(() {
      if (apiChat.isLoadingMessages.value && apiChat.chatMessages.isEmpty) {
        return _buildShimmer();
      }
      if (apiChat.chatMessages.isEmpty) {
        return _buildEmptyState();
      }

      final messages = apiChat.chatMessages;

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          // reversed: index 0 = pesan terbaru
          final realIndex = messages.length - 1 - index;
          final message = messages[realIndex];
          final bool isMe = message.senderId == currentUserId;

          final ChatMessageModel? older =
              realIndex > 0 ? messages[realIndex - 1] : null;
          final ChatMessageModel? newer =
              realIndex < messages.length - 1 ? messages[realIndex + 1] : null;

          final bool showDateSeparator =
              older == null || _isDifferentDay(message, older);

          // Grouping: pesan beruntun dari pengirim yang sama dalam hari yang sama
          final bool isFirstInGroup = older == null ||
              older.senderId != message.senderId ||
              showDateSeparator;
          final bool isLastInGroup = newer == null ||
              newer.senderId != message.senderId ||
              _isDifferentDay(newer, message);

          return Column(
            children: [
              if (showDateSeparator) _buildDateSeparator(message.createdAt),
              Padding(
                padding: EdgeInsets.only(top: isFirstInGroup ? 10 : 2),
                child: _buildMessageRow(message, isMe, isLastInGroup),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: _main.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.waving_hand_rounded,
                  size: 50, color: _main.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 18),
            Text(
              'Mulai percakapan dengan $targetName',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kirim pesan pertamamu di bawah.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageRow(
      ChatMessageModel message, bool isMe, bool isLastInGroup) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: _buildBubble(message, isMe, isLastInGroup),
    );

    if (isMe) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    // Lawan bicara: avatar kecil di bubble terakhir tiap grup
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 30,
          child: isLastInGroup
              ? _buildAvatar(targetName, targetAvatarUrl,
                  size: 30, radius: 10, fontSize: 13)
              : null,
        ),
        const SizedBox(width: 6),
        bubble,
      ],
    );
  }

  Widget _buildBubble(ChatMessageModel message, bool isMe, bool isLastInGroup) {
    const big = Radius.circular(18);
    const tail = Radius.circular(5);

    final radius = BorderRadius.only(
      topLeft: big,
      topRight: big,
      bottomLeft: (!isMe && isLastInGroup) ? tail : big,
      bottomRight: (isMe && isLastInGroup) ? tail : big,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 9, 12, 7),
      decoration: BoxDecoration(
        gradient: isMe
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_main, _mainDark],
              )
            : null,
        color: isMe ? null : Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: (isMe ? _main : Colors.black).withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              message.messageText ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14.5,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timeLabel(message.createdAt),
                style: TextStyle(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                _buildReadStatus(message.isRead),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Input pesan ───────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                style: const TextStyle(fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14.5),
                  filled: true,
                  fillColor: _main.withValues(alpha: 0.07),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: _main.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Tombol kirim: aktif (gradient) hanya kalau ada teks
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (_, value, __) {
                final canSend = value.text.trim().isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: canSend
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_main, _mainDark],
                          )
                        : null,
                    color: canSend ? null : Colors.grey.shade300,
                    boxShadow: canSend
                        ? [
                            BoxShadow(
                              color: _main.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: canSend ? _sendMessage : null,
                      child: const Center(
                        child: Icon(Icons.send_rounded,
                            color: Colors.white, size: 21),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildAvatar(
    String name,
    String? url, {
    required double size,
    required double radius,
    double fontSize = 18,
  }) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_main.withValues(alpha: 0.85), _mainDark],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
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

  Widget _buildDateSeparator(String? isoString) {
    String label = '';
    if (isoString != null) {
      try {
        label = _dateLabel(DateTime.parse(isoString).toLocal());
      } catch (_) {}
    }
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _main.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: _mainDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// Centang satu = terkirim, centang dua biru muda = dibaca
  Widget _buildReadStatus(int isRead) {
    if (isRead == 1) {
      return Icon(Icons.done_all_rounded,
          size: 14, color: Colors.lightBlueAccent.shade100);
    }
    return Icon(Icons.done_rounded,
        size: 14, color: Colors.white.withValues(alpha: 0.7));
  }

  Widget _buildShimmer() {
    return ListView.builder(
      reverse: true, // Karena chat biasanya dari bawah
      itemCount: 7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, index) {
        // Bergantian pola bubble kiri dan kanan
        final isMe = index % 2 == 0;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              width: isMe ? 220 : 180,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
