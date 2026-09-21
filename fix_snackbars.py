import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern 1: inline SnackBar
    # ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(... content: CustomSnackBar(sukses: X, teks: Y)))
    p1 = re.compile(r'ScaffoldMessenger\.of\([^)]+\)\s*\.\.hideCurrentSnackBar\(\)\s*\.\.showSnackBar\(\s*(?:const\s*)?SnackBar\([^)]*content\s*:\s*(?:const\s*)?CustomSnackBar\((.*?)\),?\s*\)\s*\);', re.DOTALL)
    
    def r1(m):
        return f"CustomSnackBar.show(context, {m.group(1).strip()});"
    
    content = p1.sub(r1, content)
    
    # Pattern 2: variable snackbar
    # const snackBar = SnackBar(... content: CustomSnackBar( args ));
    # ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
    p2 = re.compile(r'(?:const\s+|final\s+|var\s+)?([a-zA-Z0-9_]+)\s*=\s*(?:const\s*)?SnackBar\([^)]*content\s*:\s*(?:const\s*)?CustomSnackBar\((.*?)\),?\s*\);(?:(?!\b\1\b).)*ScaffoldMessenger\.of\([^)]+\)\s*\.\.hideCurrentSnackBar\(\)\s*\.\.showSnackBar\(\s*\1\s*\);', re.DOTALL)
    
    def r2(m):
        return f"CustomSnackBar.show(context, {m.group(2).strip()});"
    
    content = p2.sub(r2, content)
    
    # Pattern 3: same as 2 but without hideCurrentSnackBar
    p3 = re.compile(r'(?:const\s+|final\s+|var\s+)?([a-zA-Z0-9_]+)\s*=\s*(?:const\s*)?SnackBar\([^)]*content\s*:\s*(?:const\s*)?CustomSnackBar\((.*?)\),?\s*\);(?:(?!\b\1\b).)*ScaffoldMessenger\.of\([^)]+\)\s*\.\.showSnackBar\(\s*\1\s*\);', re.DOTALL)
    
    content = p3.sub(r2, content)

    # Pattern 4: Inline without hideCurrentSnackBar
    p4 = re.compile(r'ScaffoldMessenger\.of\([^)]+\)\s*\.\.showSnackBar\(\s*(?:const\s*)?SnackBar\([^)]*content\s*:\s*(?:const\s*)?CustomSnackBar\((.*?)\),?\s*\)\s*\);', re.DOTALL)
    
    content = p4.sub(r1, content)
    
    # Pattern 5: ScaffoldMessenger.of(context).showSnackBar( ... CustomSnackBar(...) )
    p5 = re.compile(r'ScaffoldMessenger\.of\([^)]+\)\.showSnackBar\(\s*(?:const\s*)?SnackBar\([^)]*content\s*:\s*(?:const\s*)?CustomSnackBar\((.*?)\),?\s*\)\s*\);', re.DOTALL)
    
    content = p5.sub(r1, content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
