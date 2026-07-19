$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# 1. Inject English Content
$indexPath = "c:\Users\DELL\Downloads\mediishealth\index.html"
$enContent = [System.IO.File]::ReadAllText("c:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_en.html", $utf8NoBom)
$indexHtml = [System.IO.File]::ReadAllText($indexPath, $utf8NoBom)
if ($indexHtml -notmatch "<!-- Power of Ayurveda Section -->") {
    $indexHtml = $indexHtml -replace '(?s)    <!-- Footer -->', "$enContent`r`n`r`n    <!-- Footer -->"
    [System.IO.File]::WriteAllText($indexPath, $indexHtml, $utf8NoBom)
}

# 2. Fix index-hi.html structure and Inject Hindi Content
$indexHiPath = "c:\Users\DELL\Downloads\mediishealth\index-hi.html"
$hiContent = [System.IO.File]::ReadAllText("c:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_hi.html", $utf8NoBom)
$indexHiHtml = [System.IO.File]::ReadAllText($indexHiPath, $utf8NoBom)

# Reformat the header so it matches the mobile-friendly index.html
$indexHiHtml = $indexHiHtml -replace '(?s)            <nav class="nav-links">.*?</div>\s*</div>\s*</header>', @"
            <nav class="nav-links">
                <a href="index-hi.html" class="active">मुख्य पृष्ठ</a>
                <a href="services-hi.html">सेवाएं</a>
                <a href="about-hi.html">हमारे बारे में</a>
                <a href="blog-hi.html">ब्लॉग</a>
                <a href="contact-hi.html">संपर्क करें</a>
                <div class="header-actions">
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

# Fix the hero image
$indexHiHtml = $indexHiHtml -replace '(?s)<div class="hero-image fade-in-up" style="animation-delay: 0.2s;">\s*<img src="[^"]+" alt="[^"]+">\s*</div>', '<div class="hero-image" style="animation-delay: 0.2s;">
                <img src="https://i.pinimg.com/1200x/77/5b/4c/775b4c9b555ba7ec342f55829dbedeac.jpg" alt="Ayurvedic Herbs" class="hero-banner-img">
            </div>'

if ($indexHiHtml -notmatch "<!-- Power of Ayurveda Section -->") {
    $indexHiHtml = $indexHiHtml -replace '(?s)    <!-- Footer -->', "$hiContent`r`n`r`n    <!-- Footer -->"
}
[System.IO.File]::WriteAllText($indexHiPath, $indexHiHtml, $utf8NoBom)

Write-Host "Injection and structure fixing complete."
