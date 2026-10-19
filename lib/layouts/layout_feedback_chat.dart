// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/models/feedback_model.dart';
import 'package:project_camp_sewa/services/feedback_chat_service.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:intl/intl.dart';

/// Halaman chat detail — 1 sesi = 1 admin tertentu.
///
/// [feedbackId]  : ID feedback di tabel feedback
/// [adminId]     : ID admin lawan bicara (feedback_admin_sessions.id / admin_id).
///                 null = belum ada admin yang membalas (fresh / menunggu).
/// [initialKriteria] : Tampilan awal sebelum thread di-load dari API.
class LayoutFeedbackChat extends StatefulWidget {
  final int feedbackId;
  final int? adminId;       // null = belum ada sesi / menunggu
  final String? initialKriteria;

  const LayoutFeedbackChat({
    super.key,
    required this.feedbackId,
    this.adminId,
    this.initialKriteria,
  });

  @override
  State<LayoutFeedbackChat> createState() => _LayoutFeedbackChatState();
}

class _LayoutFeedbackChatState extends State<LayoutFeedbackChat> {
  late final FeedbackChatService _service;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int _charCount = 0;

  String get _serviceTag => 'chat_${widget.feedbackId}_${widget.adminId ?? "new"}';

  @override
  void initState() {
    super.initState();
    _service = Get.put(FeedbackChatService(), tag: _serviceTag);
    _msgCtrl.addListener(() => setState(() => _charCount = _msgCtrl.text.length));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _service.loadMessages(
        widget.feedbackId,
        adminId: widget.adminId,
      );
      _scrollToBottom(animated: false);
      final resolvedAdminId = (_service.currentThread.value?.admin?.id != null && _service.currentThread.value!.admin!.id > 0)
          ? _service.currentThread.value!.admin!.id
          : widget.adminId;
      _service.startPolling(widget.feedbackId, adminId: resolvedAdminId);
    });

    _service.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _service.clearChatRoom();
    Get.delete<FeedbackChatService>(tag: _serviceTag);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent + 100;
    if (animated) {
      _scrollCtrl.animateTo(max,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _scrollCtrl.jumpTo(max);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _charCount = 0);
    final resolvedAdminId = (_service.currentThread.value?.admin?.id != null && _service.currentThread.value!.admin!.id > 0)
        ? _service.currentThread.value!.admin!.id
        : widget.adminId;
    final ok = await _service.sendMessage(
      context: context,
      feedbackId: widget.feedbackId,
      message: text,
      adminId: resolvedAdminId,
    );
    if (ok) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  // ── Format tanggal ────────────────────────────────────────────────────────
  String _formatTime(String raw) {
    try {
      return DateFormat('HH:mm')
          .format(DateTime.parse(raw.trim().replaceFirst(' ', 'T')).toLocal());
    } catch (_) {
      return '';
    }
  }

  String _formatDateSeparator(String raw) {
    try {
      final dt = DateTime.parse(raw.trim().replaceFirst(' ', 'T'));
      final today = DateTime.now();
      final d = DateTime(dt.year, dt.month, dt.day);
      final t = DateTime(today.year, today.month, today.day);
      if (d == t) return 'Hari Ini';
      if (t.difference(d).inDays == 1) return 'Kemarin';
      return DateFormat('d MMMM yyyy', 'id').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _dayKey(String raw) {
    try {
      return DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(raw.trim().replaceFirst(' ', 'T')));
    } catch (_) {
      return raw;
    }
  }

  // ── Avatar admin per-pesan ────────────────────────────────────────────────
  Widget _buildMsgAvatar(FeedbackMessage msg, {double size = 32}) {
    final url = msg.resolvedFotoUrl;
    final initials = msg.senderInitials;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x1A2C4E40),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialsBox(initials, size))
          : _initialsBox(initials, size),
    );
  }

  Widget _initialsBox(String initials, double size) {
    return Container(
      color: const Color(0x2A2C4E40),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppColors.fontStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2C4E40),
        ),
      ),
    );
  }

  // ── Avatar AppBar ─────────────────────────────────────────────────────────
  Widget _buildAppBarAvatar(FeedbackThread? thread, FeedbackMessage? adminMsg) {
    final isMenunggu = (thread == null || thread.isMenunggu) && adminMsg == null;
    final url = thread?.appBarFotoUrl ?? adminMsg?.resolvedFotoUrl ?? '';
    final initials = (thread != null && !thread.isMenunggu) 
        ? thread.appBarInitials 
        : (adminMsg?.senderInitials ?? 'A');

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: isMenunggu
          ? const Icon(MdiIcons.clockOutline, color: Colors.white70, size: 22)
          : url.isNotEmpty
              ? Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(initials,
                        style: AppColors.fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ))
              : Center(
                  child: Text(initials,
                      style: AppColors.fontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
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
            Expanded(child: _buildMessageList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Obx(() {
      final thread = _service.currentThread.value;
      final adminMsg = _service.messages.cast<FeedbackMessage?>().lastWhere(
        (m) => m?.isFromAdmin == true, 
        orElse: () => null,
      );
      
      final isMenunggu = (thread == null || thread.isMenunggu) && adminMsg == null;
      
      String appBarName = 'Menunggu Admin Pembalas';
      if (thread?.admin != null && thread!.admin!.name.trim().isNotEmpty) {
        appBarName = thread.admin!.name;
      } else if (adminMsg != null && adminMsg.senderName.trim().isNotEmpty) {
        appBarName = adminMsg.senderName;
      } else if (thread != null && !thread.isMenunggu) {
        appBarName = thread.appBarName;
      }

      final kriteria = thread?.kriteria ?? widget.initialKriteria ?? '';
      final status = thread?.status ?? '';

      return Container(
        decoration: const BoxDecoration(color: Color(0xFF2C4E40)),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 24),
                ),
                _buildAppBarAvatar(thread, adminMsg),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appBarName,
                        style: AppColors.fontStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isMenunggu
                            ? 'Pesan Anda akan segera dibalas'
                            : [
                                if (kriteria.isNotEmpty) kriteria,
                                if (status.isNotEmpty) status,
                              ].join(' · '),
                        style: AppColors.fontStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isMenunggu)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Menunggu',
                        style: AppColors.fontStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (_service.isLoadingMessages.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2C4E40)));
      }
      if (_service.messages.isEmpty) return _buildEmptyState();

      final msgs = _service.messages;
      final Set<String> renderedDays = {};

      return ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        itemCount: msgs.length,
        itemBuilder: (ctx, i) {
          final msg = msgs[i];
          final dayKey = _dayKey(msg.createdAt);
          final showSep = renderedDays.add(dayKey);
          return Column(
            children: [
              if (showSep) _buildDaySep(msg.createdAt),
              _buildBubble(msg),
            ],
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C4E40).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(MdiIcons.chatOutline,
                size: 48, color: Color(0xFF2C4E40)),
          ),
          const SizedBox(height: 16),
          Text('Belum ada pesan',
              style: AppColors.fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F2828))),
          const SizedBox(height: 6),
          Text('Kirim pesan pertamamu di bawah',
              style: AppColors.fontStyle(
                  fontSize: 13, color: const Color(0xFF8A8A8E))),
        ],
      ),
    );
  }

  Widget _buildDaySep(String rawDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFCED4DA))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE7E4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_formatDateSeparator(rawDate),
                  style: AppColors.fontStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C4E40))),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFCED4DA))),
        ],
      ),
    );
  }

  Widget _buildBubble(FeedbackMessage msg) {
    final isMe = !msg.isFromAdmin;
    final time = _formatTime(msg.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildMsgAvatar(msg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Nama admin di atas bubble
                if (!isMe && msg.senderName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(msg.senderName,
                        style: AppColors.fontStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C4E40))),
                  ),
                // Bubble
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF2C4E40) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (msg.isInitial)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.2)
                                : const Color(0xFF2C4E40).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('📝 Feedback Awal',
                              style: AppColors.fontStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isMe
                                      ? Colors.white70
                                      : const Color(0xFF2C4E40))),
                        ),
                      Text(msg.message,
                          style: AppColors.fontStyle(
                              fontSize: 14,
                              color: isMe
                                  ? Colors.white
                                  : const Color(0xFF2F2828),
                              height: 1.4)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(time,
                              style: AppColors.fontStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white.withValues(alpha: 0.65)
                                      : const Color(0xFF8A8A8E))),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              msg.readAt != null
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                              size: 14,
                              color: msg.readAt != null
                                  ? Colors.lightBlueAccent
                                  : Colors.white.withValues(alpha: 0.65),
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
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        focusNode: _focusNode,
                        maxLines: 5,
                        minLines: 1,
                        maxLength: 1000,
                        textInputAction: TextInputAction.newline,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: AppColors.fontStyle(
                              fontSize: 14,
                              color: const Color(0xFFBDBDBD)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        style: AppColors.fontStyle(
                            fontSize: 14,
                            color: const Color(0xFF2F2828)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => GestureDetector(
                        onTap:
                            _service.isSending.value ? null : _sendMessage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _charCount > 0
                                ? const Color(0xFF2C4E40)
                                : const Color(0xFFBDBDBD),
                            shape: BoxShape.circle,
                          ),
                          child: _service.isSending.value
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                        ),
                      )),
                ],
              ),
              if (_charCount > 900)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 60),
                  child: Text('$_charCount/1000',
                      style: AppColors.fontStyle(
                          fontSize: 11,
                          color: _charCount >= 1000
                              ? Colors.red
                              : const Color(0xFF8A8A8E))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
