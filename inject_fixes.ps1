$files = Get-ChildItem -Path "c:\Users\DELL\Downloads\mediishealth" -Filter *.html
$utf8 = New-Object System.Text.UTF8Encoding $false

# 1. Inject English Content
$indexPath = "c:\Users\DELL\Downloads\mediishealth\index.html"
$enContent = [System.IO.File]::ReadAllText("c:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_en.html", $utf8)
$indexHtml = [System.IO.File]::ReadAllText($indexPath, $utf8)
if ($indexHtml -notmatch "<!-- Power of Ayurveda Section -->") {
    $indexHtml = $indexHtml -replace '(?s)    <!-- Footer -->', "$enContent`r`n`r`n    <!-- Footer -->"
    [System.IO.File]::WriteAllText($indexPath, $indexHtml, $utf8)
}

# 2. Inject Hindi Content and fix index-hi.html
$indexHiPath = "c:\Users\DELL\Downloads\mediishealth\index-hi.html"
$hiContent = [System.IO.File]::ReadAllText("c:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_hi.html", $utf8)
$indexHiHtml = [System.IO.File]::ReadAllText($indexHiPath, $utf8)

# Apply fixes to index-hi.html manually as regex
$indexHiHtml = $indexHiHtml -replace '(?s)            <nav class="nav-links">.*?<a href="contact-hi.html">संपर्क करें</a>\s*</nav>\s*<div class="header-actions">', @"
            <nav class="nav-links">
                <a href="index-hi.html" class="active">मुख्य पृष्ठ</a>
                <a href="services-hi.html">सेवाएं</a>
                <a href="about-hi.html">हमारे बारे में</a>
                <a href="blog-hi.html">ब्लॉग</a>
                <a href="contact-hi.html">संपर्क करें</a>
                <div class="header-actions">
"@

$indexHiHtml = $indexHiHtml -replace '(?s)                <a href="book-consultation-hi.html" class="btn btn-primary">परामर्श बुक करें</a>\s*</div>\s*</div>\s*</header>', @"
                    <select id="langSelect" style="padding: 0.5rem; border:1px solid var(--border); border-radius:4px; outline:none;">
                        <option value="en">Eng</option>
                        <option value="hi" selected>हिन्दी</option>
                    </select>
                    <a href="book-consultation-hi.html" class="btn btn-primary">परामर्श बुक करें</a>
                </div>
            </nav>
            <button class="mobile-menu-btn">&#9776;</button>
        </div>
    </header>
"@

$indexHiHtml = $indexHiHtml -replace '(?s)<div class="hero-image fade-in-up" style="animation-delay: 0.2s;">\s*<img src="https://images.unsplash.com[^"]+" alt="Doctor Consultation">\s*</div>', '<div class="hero-image" style="animation-delay: 0.2s;">
                <img src="https://i.pinimg.com/1200x/77/5b/4c/775b4c9b555ba7ec342f55829dbedeac.jpg" alt="Ayurvedic Herbs" class="hero-banner-img">
            </div>'

if ($indexHiHtml -notmatch "<!-- Power of Ayurveda Section -->") {
    $indexHiHtml = $indexHiHtml -replace '(?s)    <!-- Footer -->', "$hiContent`r`n`r`n    <!-- Footer -->"
}
[System.IO.File]::WriteAllText($indexHiPath, $indexHiHtml, $utf8)

# 3. Clean all files of old modal logic, SVG logic, login buttons
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8)

    # login/signup buttons
    $content = $content -replace '(?s)<button class="btn btn-primary" id="loginBtn">.*?</button>', ''
    # login modal
    $content = $content -replace '(?s)<div id="loginModal" class="modal">.*?</div>\s*</div>', ''
    # svg replace
    $content = $content -replace '(?s)<svg.*?</svg>', '<img src="logo.png" alt="Logo" style="height: 40px; margin-right: 10px; vertical-align: middle;">'
    $content = $content -replace '(?s)<!-- SVG Logo Mockup -->.*?<img', '<img'

    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8)
}

# 4. Clean app.js
$appJsPath = "c:\Users\DELL\Downloads\mediishealth\app.js"
if (Test-Path $appJsPath) {
    $appJs = [System.IO.File]::ReadAllText($appJsPath, $utf8)
    $appJs = $appJs -replace '(?s)// Modal logic for Login/Signup.*?(?=\s*// Dummy form submissions)', ''
    [System.IO.File]::WriteAllText($appJsPath, $appJs, $utf8)
}

Write-Output "Completed successfully"
