import os
import glob
import re

directory = r"c:\Users\DELL\Downloads\mediishealth"

html_files = glob.glob(os.path.join(directory, "*.html"))

for file_path in html_files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 1. Update Title and references
    content = content.replace("Mediis Health Ayurveda", "Mediis Health and Lab")
    
    # In case there are remaining "Mediis Health" without "Ayurveda" and without "and Lab"
    # We will use regex to replace it safely, ignoring if it's already "Mediis Health and Lab"
    # Be careful not to replace it if it's part of a URL or class name, but we know it's mostly text
    content = re.sub(r'Mediis Health(?!\s+and Lab)', 'Mediis Health and Lab', content)
    
    # 2. Update Header Logo SVG to img
    # The svg looks like:
    # <svg width="32" height="32" viewBox="0 0 24 24" fill="var(--primary)"><path d="M11 2v4c0 1.1-.9 2-2 2H5v4h4c1.1 0 2 .9 2 2v4h2v-4c0-1.1.9-2 2-2h4v-4h-4c-1.1 0-2-.9-2-2V2h-2z"/></svg>
    svg_regex = r'<svg width="32" height="32" viewBox="0 0 24 24" fill="var\(--primary\)"><path d="M11 2v4c0 1.1-.9 2-2 2H5v4h4c1.1 0 2 .9 2 2v4h2v-4c0-1.1.9-2 2-2h4v-4h-4c-1.1 0-2-.9-2-2V2h-2z"/></svg>'
    img_tag = '<img src="logo.jpg" alt="Mediis Health and Lab Logo" style="height: 40px; margin-right: 10px; vertical-align: middle;">'
    content = re.sub(svg_regex, img_tag, content)
    
    # 3. Update Footer Logo
    # Example: <a href="index.html" class="logo" style="color: white;">Mediis Health and Lab</a>
    # We want to add the image before the text.
    # Note: we already replaced Mediis Health with Mediis Health and Lab above.
    footer_logo_regex = r'(<a[^>]*class="logo"[^>]*>)\s*Mediis Health and Lab\s*</a>'
    footer_logo_replacement = r'\1<img src="logo.jpg" alt="Mediis Health and Lab Logo" style="height: 30px; margin-right: 10px; vertical-align: middle;">Mediis Health and Lab</a>'
    
    # But wait, the header logo ALSO has class="logo" and might match this if we aren't careful.
    # Let's see: header logo has the img tag inside it now (because we replaced the SVG).
    # Oh wait, if we replaced SVG with img_tag, it looks like:
    # <a href="..." class="logo">
    #     <img ...>
    #     Mediis Health and Lab
    # </a>
    # This won't match footer_logo_regex if we make footer_logo_regex strict.
    content = re.sub(footer_logo_regex, footer_logo_replacement, content)
    
    # 4. Remove accept="image/*"
    content = content.replace('accept="image/*"', '')

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {os.path.basename(file_path)}")

print("Done")
