import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';

class CustomSnackBar extends StatefulWidget {
  final String? teks;
  final String? title;
  final bool sukses;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback? onDismissed;

  const CustomSnackBar({
    super.key,
    this.title,
    this.teks,
    this.sukses = true,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(milliseconds: 3500),
    this.onDismissed,
  });

  static OverlayEntry? _current;

  /// Tampilkan snackbar dari atas layar.
  static void show(
    BuildContext context, {
    String? title,
    required String teks,
    bool sukses = true,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    // Hapus snackbar sebelumnya kalau masih tampil
    _current?.remove();
    _current = null;

    final safeContext = context.mounted ? context : Get.overlayContext;
    if (safeContext == null) return;
    
    final overlay = Overlay.maybeOf(safeContext, rootOverlay: true) ?? Overlay.maybeOf(safeContext);
    if (overlay == null) return;
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: CustomSnackBar(
              title: title,
              teks: teks,
              sukses: sukses,
              actionLabel: actionLabel,
              onAction: onAction,
              duration: duration,
              onDismissed: () {
                entry.remove();
                if (_current == entry) _current = null;
              },
            ),
          ),
        ),
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  @override
  State<CustomSnackBar> createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _timer;
  late final Animation<Offset> _slide;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      reverseDuration: const Duration(milliseconds: 500),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // muncul + memantul/bergoyang
        reverseCurve: Curves.easeOutBack, // turun sedikit lalu meluncur ke atas
      ),
    );

    _timer = AnimationController(vsync: this, duration: widget.duration);

    _controller.forward().then((_) {
      if (!mounted) return;
      _timer.forward();
    });

    _timer.addStatusListener((status) {
      if (status == AnimationStatus.completed) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _timer.stop();
    await _controller.reverse();
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool ok = widget.sukses;
    final List<Color> gradient = ok
        ? const [Color(0xFF2C4E40), Color(0xFF3F7A5F)]
        : const [Color(0xFFC81E2D), Color(0xFFEE2737)];
    final Color accent = ok ? const Color(0xFF2C4E40) : const Color(0xFFEE2737);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Goyangan kecil saat muncul (hanya saat forward)
        final t = _controller.value;
        final angle = _controller.status == AnimationStatus.reverse
            ? 0.0
            : math.sin(t * math.pi * 5) * (1 - t) * 0.03;
        return Transform.rotate(
          angle: angle,
          alignment: Alignment.topCenter,
          child: SlideTransition(position: _slide, child: child),
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: _dismiss,
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) < -100) _dismiss(); // swipe ke atas
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Dekorasi lingkaran transparan
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Ikon besar
                            Container(
                              width: 54,
                              height: 54,
                              padding: const EdgeInsets.all(11),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                ok
                                    ? "assets/images/sukses-logo.png"
                                    : "assets/images/error-logo.png",
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  ok
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  color: accent,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title ?? (ok ? "Berhasil" : "Gagal"),
                                    style: AppColors.fontStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (widget.teks != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.teks!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppColors.fontStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (widget.actionLabel != null &&
                                widget.onAction != null) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  _dismiss();
                                  widget.onAction!();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    widget.actionLabel!,
                                    style: AppColors.fontStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Progress bar sisa waktu
                      AnimatedBuilder(
                        animation: _timer,
                        builder: (_, __) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 1 - _timer.value,
                            child: Container(
                              height: 4,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




