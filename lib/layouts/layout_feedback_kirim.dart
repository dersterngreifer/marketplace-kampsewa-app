// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:project_camp_sewa/models/feedback_model.dart';
import 'package:project_camp_sewa/services/feedback_chat_service.dart';
import 'package:project_camp_sewa/theme_colors.dart';

/// Halaman form kirim feedback baru.
/// Setelah submit berhasil, halaman di-pop dengan mengembalikan [FeedbackItem]
/// agar caller bisa langsung push ke halaman chat.
class LayoutFeedbackKirim extends StatefulWidget {
  const LayoutFeedbackKirim({super.key});

  @override
  State<LayoutFeedbackKirim> createState() => _LayoutFeedbackKirimState();
}

class _LayoutFeedbackKirimState extends State<LayoutFeedbackKirim> {
  final TextEditingController _deskripsiCtrl = TextEditingController();
  String? _selectedKriteria;
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> _kriteriaOptions = [
    {
      'value': 'Sangat Baik',
      'label': 'Sangat Baik',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': Color(0xFF43A047),
    },
    {
      'value': 'Baik',
      'label': 'Baik',
      'icon': Icons.sentiment_satisfied_rounded,
      'color': Color(0xFF66BB6A),
    },
    {
      'value': 'Cukup',
      'label': 'Cukup',
      'icon': Icons.sentiment_neutral_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'value': 'Kurang',
      'label': 'Kurang',
      'icon': Icons.sentiment_dissatisfied_rounded,
      'color': Color(0xFFEF6C00),
    },
    {
      'value': 'Sangat Kurang',
      'label': 'Sangat\nKurang',
      'icon': Icons.sentiment_very_dissatisfied_rounded,
      'color': Color(0xFFEE2737),
    },
  ];

  @override
  void dispose() {
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedKriteria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih rating terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_deskripsiCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tuliskan keluhan atau masukan Anda'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final service =
        Get.put(FeedbackChatService(), tag: 'submit_${DateTime.now()}');
    final result = await service.submitFeedback(
      context: context,
      deskripsi: _deskripsiCtrl.text.trim(),
      kriteria: _selectedKriteria!,
    );
    Get.delete<FeedbackChatService>(
        tag: 'submit_${DateTime.now().millisecondsSinceEpoch}');
    setState(() => _isSubmitting = false);

    if (result != null && mounted) {
      Get.back(result: result); // kembalikan FeedbackItem ke caller
    }
  }

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildKriteriaSection(),
                    const SizedBox(height: 20),
                    _buildDeskripsiSection(),
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              Text(
                'Kirim Masukan',
                style: AppColors.fontStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(MdiIcons.informationOutline,
              color: Color(0xFF2C4E40), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Masukan Anda akan langsung dibaca oleh Admin KampSewa. Setelah terkirim, Anda bisa langsung chat untuk tindak lanjut.',
              style: AppColors.fontStyle(
                fontSize: 13,
                color: const Color(0xFF2C4E40),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKriteriaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Pengalaman',
          style: AppColors.fontStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F2828),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bagaimana pengalaman Anda menggunakan KampSewa?',
          style: AppColors.fontStyle(
            fontSize: 13,
            color: const Color(0xFF8A8A8E),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _kriteriaOptions.map((opt) {
            final isSelected = _selectedKriteria == opt['value'];
            final color = opt['color'] as Color;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedKriteria = opt['value'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      color: isSelected ? color : const Color(0xFFBDBDBD),
                      size: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt['label'] as String,
                      textAlign: TextAlign.center,
                      style: AppColors.fontStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? color : const Color(0xFF8A8A8E),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeskripsiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keluhan / Masukan',
          style: AppColors.fontStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F2828),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ceritakan kendala atau saran Anda (maks. 1000 karakter)',
          style: AppColors.fontStyle(
            fontSize: 13,
            color: const Color(0xFF8A8A8E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _deskripsiCtrl,
            maxLines: 6,
            minLines: 4,
            maxLength: 1000,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'Contoh: Proses pengiriman tenda lambat, mohon diperbaiki...',
              hintStyle: AppColors.fontStyle(
                fontSize: 14,
                color: const Color(0xFFBDBDBD),
                height: 1.4,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: AppColors.fontStyle(
                fontSize: 12,
                color: const Color(0xFF8A8A8E),
              ),
            ),
            style: AppColors.fontStyle(
              fontSize: 14,
              color: const Color(0xFF2F2828),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit =
        _selectedKriteria != null && _deskripsiCtrl.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: (canSubmit && !_isSubmitting) ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C4E40),
            disabledBackgroundColor: const Color(0xFFBDBDBD),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: canSubmit ? 2 : 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(MdiIcons.send, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Kirim & Mulai Chat',
                      style: AppColors.fontStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
