import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';

class OtpInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final FocusNode? previousFocusNode;
  const OtpInput(
      {super.key,
      required this.controller,
      required this.focusNode,
      this.nextFocusNode,
      this.previousFocusNode});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F4),
          border: Border.all(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: TextField(
            keyboardType: TextInputType.number,
            controller: widget.controller,
            textAlign: TextAlign.center,
            maxLength: 1,
            focusNode: widget.focusNode,
            style: AppColors.fontStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF2F2828)),
            decoration:
                const InputDecoration(counterText: '', border: InputBorder.none),
            onChanged: (value) {
              if (value.length == 1) {
                widget.focusNode.unfocus();
                if (widget.nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(widget.nextFocusNode);
                }
              } else if (value.isEmpty && widget.previousFocusNode != null) {
                widget.previousFocusNode!.requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}
