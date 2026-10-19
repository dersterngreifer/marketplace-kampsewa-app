import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/dialog/snackbar.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';
import 'package:project_camp_sewa/models/article_model.dart';
import 'package:project_camp_sewa/services/api_article.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class LayoutDetailWisata extends StatefulWidget {
  final ArticleModel? initialArticle;
  final int? articleId;

  const LayoutDetailWisata({
    super.key,
    this.initialArticle,
    this.articleId,
  });

  @override
  State<LayoutDetailWisata> createState() => _LayoutDetailWisataState();
}

class _LayoutDetailWisataState extends State<LayoutDetailWisata> {
  static const Color _green = Color(0xFF2C4E40);
  static const Color _greenDark = Color(0xFF1E352B);
  static const Color _dark = Color(0xFF2F2828);

  final ApiArticle _apiArticle = Get.isRegistered<ApiArticle>()
      ? Get.find<ApiArticle>()
      : Get.put(ApiArticle());

  ArticleModel? _article;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _article = widget.initialArticle;
    final int? targetId = widget.initialArticle?.id ?? widget.articleId;

    if (targetId != null) {
      if (_article == null) {
        _isLoading = true;
      }
      _fetchDetail(targetId);
    }
  }

  Future<void> _fetchDetail(int id) async {
    final updated = await _apiArticle.fetchDetailWisata(id);
    if (mounted && updated != null) {
      setState(() {
        _article = updated;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openSumberUrl(String? rawUrl) async {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      CustomSnackBar.show(
        context,
        title: "Tautan Tidak Tersedia",
        teks: "Tautan sumber resmi untuk rekomendasi ini belum ditambahkan.",
        sukses: false,
      );
      return;
    }

    String cleanUrl = rawUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final uri = Uri.tryParse(cleanUrl);
    if (uri == null || !uri.hasScheme) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        title: "Tautan Tidak Valid",
        teks: "Format tautan rekomendasi wisata tidak valid.",
        sukses: false,
      );
      return;
    }

    try {
      bool launched = false;
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched && mounted) {
        CustomSnackBar.show(
          context,
          title: "Gagal Membuka Tautan",
          teks: "Tidak dapat membuka link web sumber resmi di peramban Anda.",
          sukses: false,
        );
      }
    } catch (_) {
      try {
        final fallback = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (!fallback && mounted) {
          CustomSnackBar.show(
            context,
            title: "Gagal Membuka Tautan",
            teks: "Tidak dapat membuka link web sumber resmi.",
            sukses: false,
          );
        }
      } catch (err) {
        if (!mounted) return;
        CustomSnackBar.show(
          context,
          title: "Gagal Membuka Tautan",
          teks: "Terjadi kendala saat membuka browser: $err",
          sukses: false,
        );
      }
    }
  }

  void _shareArticle() {
    final String shareText =
        '${_article?.judul ?? "Rekomendasi Wisata"}\n\n'
        '${_article?.deskripsiSingkat ?? ""}\n\n'
        '${_article?.sumberUrl ?? "Temukan selengkapnya di aplikasi KampSewa!"}';

    Clipboard.setData(ClipboardData(text: shareText));
    CustomSnackBar.show(
      context,
      title: "Tautan Disalin",
      teks: "Teks rekomendasi wisata berhasil disalin ke papan klip.",
      sukses: true,
    );
  }

  Widget _buildImageBanner(String? imagePath) {
    final String resolved = getFotoWisataUrl(imagePath);

    Widget placeholder() => Container(
          color: const Color(0xFF1E352B),
          child: const Center(
            child: Icon(Icons.landscape_rounded,
                color: Colors.white24, size: 56),
          ),
        );

    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    }
    if (imagePath != null && imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    }
    return placeholder();
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _dark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 24,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 28,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 28,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _article == null) {
      return _buildLoadingSkeleton();
    }

    final article = _article;
    if (article == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _dark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                "Data wisata tidak ditemukan",
                style: AppColors.fontStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Sliver App Bar dengan Foto Cover ──
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: _greenDark,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageBanner(article.gambar),
                        // Gradient bayangan atas untuk kontras icon
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.4, 0.85, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                        ),
                        // Badge lokasi & kategori di pojok kiri bawah foto
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 18,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.explore_rounded,
                                        size: 13, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Rekomendasi Wisata",
                                      style: AppColors.fontStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (article.lokasi != null &&
                                  article.lokasi!.trim().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on_rounded,
                                          size: 13, color: Color(0xFFEE2737)),
                                      const SizedBox(width: 4),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5),
                                        child: Text(
                                          article.lokasi!.trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppColors.fontStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _dark,
                                          ),
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
                  ),
                ),

                // ── Konten Blog ──
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -12, 0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul Artikel
                          Text(
                            article.judul,
                            style: AppColors.fontStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _dark,
                              height: 1.35,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Profil Uploader / Author & Metadata Tanggal & Views
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      _green.withValues(alpha: 0.15),
                                  backgroundImage: (article.author?.foto !=
                                              null &&
                                          article.author!.foto.isNotEmpty)
                                      ? NetworkImage(getImageUrl(
                                          article.author!.foto))
                                      : null,
                                  child: (article.author?.foto == null ||
                                          article.author!.foto.isEmpty)
                                      ? const Icon(Icons.person_rounded,
                                          color: _green, size: 22)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.author?.name ?? "Admin KampSewa",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppColors.fontStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: _dark,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded,
                                              size: 11,
                                              color: Color(0xFF8E8E8E)),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              article.waktuLalu.isNotEmpty
                                                  ? article.waktuLalu
                                                  : article.tanggalUpload,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppColors.fontStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF8E8E8E),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                              Icons.visibility_outlined,
                                              size: 12,
                                              color: Color(0xFF8E8E8E)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${article.viewsCount} pembaca",
                                            style: AppColors.fontStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF8E8E8E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Deskripsi Singkat / Ringkasan (Lead Paragraph)
                          if (article.deskripsiSingkat.trim().isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: const Border(
                                  left: BorderSide(color: _green, width: 3.5),
                                ),
                              ),
                              child: Text(
                                article.deskripsiSingkat.trim(),
                                style: AppColors.fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _greenDark,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                          ],

                          // Konten Lengkap Artikel
                          _buildContentParagraphs(article.konten),
                          const SizedBox(height: 32),

                          // Informasi Tanggal Upload Lengkap
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_note_rounded,
                                    size: 16, color: _green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Diterbitkan: ${article.tanggalUpload} ${article.waktuUpload}",
                                    style: AppColors.fontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF555555),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Card Sumber Asli / Web Portal Eksternal
                          _buildSourceCard(article),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Floating Action Buttons (Back & Share) ──
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _shareArticle,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.share_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  if (article.sumberUrl != null &&
                      article.sumberUrl!.trim().isNotEmpty) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _openSumberUrl(article.sumberUrl),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.open_in_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentParagraphs(String rawContent) {
    if (rawContent.trim().isEmpty) {
      return Text(
        "Belum ada rincian artikel untuk destinasi wisata ini.",
        style: AppColors.fontStyle(
          fontSize: 14.5,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final paragraphs = rawContent
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            paragraph,
            textAlign: TextAlign.justify,
            style: AppColors.fontStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2B2B2B),
              height: 1.7,
              letterSpacing: 0.1,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSourceCard(ArticleModel article) {
    final hasSourceUrl =
        article.sumberUrl != null && article.sumberUrl!.trim().isNotEmpty;
    final sourceName = (article.sumberNama != null &&
            article.sumberNama!.trim().isNotEmpty)
        ? article.sumberNama!.trim()
        : "Portal Berita / Sumber Eksternal";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.public_rounded,
                    size: 18, color: _green),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sumber Referensi Wisata",
                      style: AppColors.fontStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    Text(
                      sourceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppColors.fontStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasSourceUrl) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openSumberUrl(article.sumberUrl),
                icon: const Icon(Icons.open_in_browser_rounded,
                    color: Colors.white, size: 18),
                label: Text(
                  "Kunjungi Website Sumber",
                  style: AppColors.fontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
