import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_camp_sewa/constants/api_endpoint.dart';

class CheckoutProdukCard extends StatefulWidget {
  final String? image;
  final String? namaProduk;
  final String variasiWarna;
  final String variasiUkuran;
  final String? hargaProduk;
  final String? qtyProduk;
  const CheckoutProdukCard(
      {super.key,
      this.image,
      this.namaProduk,
      this.variasiWarna = "",
      this.variasiUkuran = "",
      this.hargaProduk,
      this.qtyProduk});

  @override
  State<CheckoutProdukCard> createState() => _CheckoutProdukCardState();
}

class _CheckoutProdukCardState extends State<CheckoutProdukCard> {
  String formatCurrency(String numberString) {
    final number = int.parse(numberString);
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.image == null
                  ? Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 40)
                  : widget.image!.startsWith('assets/')
                      ? Image.asset(widget.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.grey.shade400))
                      : Image.network(
                          resolveFullUrl(widget.image!, ApiEndpoints.authendpoints.getImageProduk),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.grey.shade400),
                        ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaProduk ?? "Nama Produk",
                  style: AppColors.fontStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (widget.variasiUkuran.isNotEmpty || widget.variasiWarna.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.variasiUkuran.isNotEmpty && widget.variasiWarna.isNotEmpty
                          ? "${widget.variasiUkuran} / ${widget.variasiWarna}"
                          : widget.variasiUkuran.isNotEmpty
                              ? widget.variasiUkuran
                              : widget.variasiWarna,
                      style: AppColors.fontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${formatCurrency(widget.hargaProduk ?? '0')}",
                      style: AppColors.fontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEE2737)),
                    ),
                    Text(
                      "x${widget.qtyProduk ?? '1'}",
                      style: AppColors.fontStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
