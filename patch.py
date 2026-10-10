
import re
with open('lib/layouts/layout_feedback_list.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
'''                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C4E40),
                                  borderRadius: BorderRadius.circular(20),
                                ),''',
'''                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),'''
)

with open('lib/layouts/layout_feedback_list.dart', 'w', encoding='utf-8') as f:
    f.write(text)

