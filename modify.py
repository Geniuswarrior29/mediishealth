import os
import re
import glob

directory = r"c:\Users\DELL\Downloads\mediishealth"

def process_html_files():
    html_files = glob.glob(os.path.join(directory, "*.html"))
    
    # Regex to match the modal block
    modal_pattern = re.compile(r'<!-- Login Modal -->.*?</div>\s*</div>', re.DOTALL)
    
    for file_path in html_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Remove modal
        content = modal_pattern.sub('', content)
        
        # Replace buttons
        if '-hi.html' in file_path:
            # Hindi files
            content = content.replace(
                '<button class="btn btn-primary" id="loginBtn">लॉगिन / साइन अप</button>',
                '<a href="book-consultation-hi.html" class="btn btn-primary">परामर्श बुक करें</a>'
            )
        else:
            # English files
            content = content.replace(
                '<button class="btn btn-primary" id="loginBtn">Login / Signup</button>',
                '<a href="book-consultation.html" class="btn btn-primary">Book Consultation</a>'
            )
            
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {file_path}")

def process_app_js():
    js_path = os.path.join(directory, "app.js")
    if os.path.exists(js_path):
        with open(js_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original_content = content
        
        # Remove loginBtn logic
        login_btn_logic = re.compile(r'// Modal logic for Login/Signup\s*const loginBtn = document\.getElementById\(\'loginBtn\'\);\s*const loginModal = document\.getElementById\(\'loginModal\'\);\s*const closeModals = document\.querySelectorAll\(\'\.close-modal\'\);\s*if\(loginBtn && loginModal\) \{\s*loginBtn\.addEventListener\(\'click\', \(e\) => \{\s*e\.preventDefault\(\);\s*loginModal\.style\.display = \'flex\';\s*\}\);\s*\}', re.DOTALL)
        
        content = login_btn_logic.sub('const closeModals = document.querySelectorAll(\'.close-modal\');', content)
        
        if content != original_content:
            with open(js_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Updated app.js")

process_html_files()
process_app_js()
