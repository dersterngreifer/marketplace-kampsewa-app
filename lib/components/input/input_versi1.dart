import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';

class InputVersiSatu extends StatefulWidget {
  final TextInputType tipeInput;
  final String placeHolder;
  final double ukuranFontPlaceHolder;
  final double ketebalanBorder;
  final Color warnaBgInput;
  final Icon iconInput;
  final bool border;
  final bool passwordTipe;
  final bool showEyes;
  final TextEditingController controller;
  const InputVersiSatu(
      {super.key,
      required this.tipeInput,
      required this.controller,
      this.placeHolder = "Masukkan Tipe",
      this.warnaBgInput = Colors.white,
      this.ketebalanBorder = 1,
      this.border = false,
      this.showEyes = false,
      this.passwordTipe = false,
      this.iconInput = const Icon(Icons.email_outlined),
      this.ukuranFontPlaceHolder = 14});

  @override
  State<InputVersiSatu> createState() => _InputVersiSatuState();
}

class _InputVersiSatuState extends State<InputVersiSatu> {
  bool _obscureText = true;
  bool _isFocused = false;
  late FocusNode _focusNode;

  // Warna dasar yang aman & kontras tinggi — tidak bergantung pada AppColors
  // supaya kontras tetap terjamin apa pun isi theme_colors.dart.
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _hintColor = Color(0xFF8A8A8E);
  static const Color _idleIconColor = Color(0xFF9AA0A6);
  static const Color _idleBorderColor = Color(0xFFE1E3E8);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = AppColors.mainColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: widget.warnaBgInput,
        borderRadius: BorderRadius.circular(16),
        // Border SELALU ada (bukan transparan) supaya input tidak "hilang"
        // di atas background putih — hanya warnanya yang berubah saat fokus.
        border: Border.all(
          color: _isFocused
              ? accentColor
              : widget.border
                  ? Colors.black45
                  : _idleBorderColor,
          width:
              _isFocused ? 1.6 : (widget.border ? widget.ketebalanBorder : 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? accentColor.withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: _isFocused ? 16 : 8,
            spreadRadius: _isFocused ? 0.5 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        focusNode: _focusNode,
        obscureText: widget.passwordTipe ? _obscureText : false,
        keyboardType: widget.tipeInput,
        controller: widget.controller,
        cursorColor: accentColor,
        style: AppColors.fontStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          hintText: widget.placeHolder,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintStyle: AppColors.fontStyle(
            color: _hintColor,
            fontWeight: FontWeight.w500,
            fontSize: widget.ukuranFontPlaceHolder,
          ),
          suffixIcon: widget.showEyes
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: _isFocused ? accentColor : _idleIconColor,
                    size: 20,
                  ),
                )
              : null,
          prefixIcon: IconTheme(
            data: IconThemeData(
              color: _isFocused ? accentColor : _idleIconColor,
              size: 22,
            ),
            child: widget.iconInput,
          ),
        ),
      ),
    );
  }
}
