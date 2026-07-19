import os
import glob
import re

files = glob.glob('*.html')

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix corrupted Hindi button text
    content = content.replace('परामर्श नुक ें', 'परामर्श बुक करें')
    
    # Fix logo text
    if '-hi.html' in filepath:
        content = re.sub(
            r'(<img src="logo\.png" alt="Logo" style="height: 40px; margin-right: 10px; vertical-align: middle;">\s*)मेडीस हेल्थ\b',
            r'\1मेडीस हेल्थ एंड लैब',
            content
        )
    else:
        content = re.sub(
            r'(<img src="logo\.png" alt="Logo" style="height: 40px; margin-right: 10px; vertical-align: middle;">\s*)Mediis Health\b',
            r'\1Mediis Health and Lab',
            content
        )
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("All fixes applied successfully.")
