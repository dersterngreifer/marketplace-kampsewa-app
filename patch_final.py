import re

with open('lib/components/bottomsheet/bottom_sheet_produk.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('\"Tambahkan ke Keranjang\",', '\"Tambahkan - Rp \\",')

target_end = \"\"\"                  ),
                ),
              ),
            ],\"\"\"

replacement_end = \"\"\"                  ),
                ),
              ),
              ],
            ],\"\"\"

text = text.replace(target_end, replacement_end)

with open('lib/components/bottomsheet/bottom_sheet_produk.dart', 'w', encoding='utf-8') as f:
    f.write(text)
