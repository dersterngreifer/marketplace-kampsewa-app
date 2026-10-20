// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/theme_colors.dart';

/// Bottom sheet khusus untuk membagikan profil toko ke berbagai platform.
class BottomSheetShareToko {
  static Future<void> show({
    required String namaToko,
    String? emailPemilik,
    String? logoUrl,
  }) {
    final BuildContext? ctx = Get.context;
    if (ctx == null) return Future<void>.value();

    return showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareTokoSheet(
        namaToko: namaToko,
        emailPemilik: emailPemilik,
        logoUrl: logoUrl,
      ),
    );
  }
}

class ShareTokoSheet extends StatelessWidget {
  final String namaToko;
  final String? emailPemilik;
  final String? logoUrl;

  const ShareTokoSheet({
    super.key,
    required this.namaToko,
    this.emailPemilik,
    this.logoUrl,
  });

  /// URL profil toko yang dibagikan, contoh:
  /// `https://abbmamarketplacekampsewa.com/emailuser`
  String get shareUrl => getShareProfileTokoUrl(
        emailPemilik != null && emailPemilik!.isNotEmpty
            ? emailPemilik
            : namaToko,
      );

  String get _pesan =>
      'Lihat profil toko "$namaToko" di KampSewa Marketplace: $shareUrl';

  Uri _buildShareUri(_ShareTarget target) {
    switch (target) {
      case _ShareTarget.whatsapp:
        return Uri.https('wa.me', '/', {'text': _pesan});
      case _ShareTarget.facebook:
        return Uri.https('www.facebook.com', '/sharer/sharer.php', {
          'u': shareUrl,
        });
      case _ShareTarget.twitter:
        return Uri.https('twitter.com', '/intent/tweet', {
          'text': 'Lihat profil toko $namaToko di KampSewa Marketplace',
          'url': shareUrl,
        });
      case _ShareTarget.telegram:
        return Uri.https('t.me', '/share/url', {
          'url': shareUrl,
          'text': 'Lihat profil toko $namaToko',
        });
      case _ShareTarget.email:
        return Uri(
          scheme: 'mailto',
          queryParameters: {
            'subject': 'Profil Toko $namaToko',
            'body': _pesan,
          },
        );
    }
  }

  Future<void> _share(BuildContext context, _ShareTarget target) async {
    Navigator.of(context).pop();

    final Uri uri = _buildShareUri(target);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      _tSnack(context, 'Gagal membuka aplikasi untuk share');
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: shareUrl));
    if (!context.mounted) return;
    Navigator.of(context).pop();
    _tSnack(context, 'Link profil toko berhasil disalin');
  }

  void _tSnack(BuildContext context, String teks) {
    final BuildContext? safeCtx = context.mounted ? context : Get.context;
    if (safeCtx == null) return;
    CustomSnackBar.show(safeCtx, sukses: true, teks: teks);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Judul
              const Text(
                "Bagikan Profil Toko",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F2828),
                ),
              ),
              const SizedBox(height: 16),

              // Kartu pratinjau link
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _buildLogo(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaToko.isEmpty ? 'Profil Toko' : namaToko,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2F2828),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shareUrl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Opsi share
              _buildShareOption(
                context,
                icon: MdiIcons.whatsapp,
                iconColor: const Color(0xFF25D366),
                label: "WhatsApp",
                onTap: () => _share(context, _ShareTarget.whatsapp),
              ),
              _buildShareOption(
                context,
                icon: MdiIcons.facebook,
                iconColor: const Color(0xFF1877F2),
                label: "Facebook",
                onTap: () => _share(context, _ShareTarget.facebook),
              ),
              _buildShareOption(
                context,
                icon: MdiIcons.twitter,
                iconColor: const Color(0xFF1DA1F2),
                label: "X (Twitter)",
                onTap: () => _share(context, _ShareTarget.twitter),
              ),
              _buildShareOption(
                context,
                icon: MdiIcons.send,
                iconColor: const Color(0xFF2AABEE),
                label: "Telegram",
                onTap: () => _share(context, _ShareTarget.telegram),
              ),
              _buildShareOption(
                context,
                icon: MdiIcons.emailOutline,
                iconColor: const Color(0xFFEA4335),
                label: "Email",
                onTap: () => _share(context, _ShareTarget.email),
              ),

              const SizedBox(height: 12),

              // Salin link
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _copyLink(context),
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text("Salin Link Profil"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final String url = getFotoTokoUrl(logoUrl);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mainColor.withValues(alpha: 0.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(Icons.storefront_rounded,
              color: AppColors.mainColor, size: 22)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.storefront_rounded,
                color: AppColors.mainColor,
                size: 22,
              ),
            ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2828),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}

enum _ShareTarget { whatsapp, facebook, twitter, telegram, email }
