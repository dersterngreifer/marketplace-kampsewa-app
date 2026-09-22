import os

filepath = r'D:\Projects\Marketplace KampSewa\marketplace-kampsewa-app\lib\layouts\layout_detail_product.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    text = f.read()

store_ui = """
            // Store Info Container
            if (namaToko != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: fotoToko != null 
                          ? Image.network(
                              fotoToko!.startsWith('http') 
                                ? fotoToko! 
                                : '${ApiEndpoints.baseUrl}${ApiEndpoints.authendpoints.getFotoProfile}${fotoToko!}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.store, color: Colors.grey),
                            )
                          : const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaToko!,
                            style: AppColors.fontStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2F2828),
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (ratingToko != null && ratingToko! > 0)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFED6723)),
                                const SizedBox(width: 4),
                                Text(
                                  ratingToko!.toStringAsFixed(1),
                                  style: AppColors.fontStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF616161),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              "Belum ada rating",
                              style: AppColors.fontStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
"""

import re
text = re.sub(
    r'\s*// Description',
    '\n' + store_ui + '\n            // Description',
    text
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(text)
