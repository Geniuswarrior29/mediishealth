$files = Get-ChildItem -Path "c:\Users\DELL\Downloads\mediishealth" -Filter *.html
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Base64 strings for Hindi
# "हिन्दी"
$hiLang = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("4KS54KS/4KSo4KWN4KSm4KWA"))
# "परामर्श बुक करें"
$hiBookBtn = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("4KSq4KSw4KS+4KSu4KSw4KWN4KS2IOCkqOClgeCklSDgkrXgkrDgpYfgpII="))

$headerActionsEn = @"
                <div class="header-actions">
                    <select id="langSelect" style="padding: 0.5rem; border:1px solid var(--border); border-radius:4px; outline:none;">
                        <option value="en">Eng</option>
                        <option value="hi">$hiLang</option>
                    </select>
                    <a href="book-consultation.html" class="btn btn-primary" style="color: white !important;">Book Consultation</a>
                </div>
"@

$headerActionsHi = @"
                <div class="header-actions">
                    <select id="langSelect" style="padding: 0.5rem; border:1px solid var(--border); border-radius:4px; outline:none;">
                        <option value="en">Eng</option>
                        <option value="hi" selected>$hiLang</option>
                    </select>
                    <a href="book-consultation-hi.html" class="btn btn-primary" style="color: white !important;">$hiBookBtn</a>
                </div>
"@

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    
    # 1. Remove existing header-actions and mobile button
    $content = $content -replace '(?s)<div class="header-actions">.*?</div>', ''
    $content = $content -replace '<button class="mobile-menu-btn">&#9776;</button>', ''

    # 2. Insert new header-actions inside <nav> before </nav>
    $actions = if ($file.Name -match '-hi\.html') { $headerActionsHi } else { $headerActionsEn }
    $content = $content -replace '(?s)(</nav>)', "$actions`r`n            `$1`r`n            <button class=`"mobile-menu-btn`">&#9776;</button>"
    
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
}

# 3. Fix CSS for header and footer responsiveness
$cssPath = "c:\Users\DELL\Downloads\mediishealth\styles.css"
$css = [System.IO.File]::ReadAllText($cssPath, $utf8NoBom)

# Add media query for footer if it doesn't exist
if ($css -notmatch '@media \(max-width: 768px\) \{\s*\.footer-grid') {
    $css += @"

@media (max-width: 768px) {
  .footer-grid {
    grid-template-columns: 1fr;
    gap: 2rem;
  }
}
"@
}

# Ensure nav-links header-actions CSS is removed since it's now handled organically by flexbox
# The header-actions was modified to be block/column on mobile, but inside .nav-links it will naturally inherit flex-direction: column from .nav-links on mobile.
# I'll just remove the specific header-actions media queries to avoid conflicts.
$css = $css -replace '(?s)\.header-actions \{[^}]+\}', ''
$css = $css -replace '(?s)@media \(max-width: 500px\) \{[^}]+\.header-actions[^}]+\}', ''

[System.IO.File]::WriteAllText($cssPath, $css, $utf8NoBom)

Write-Host "Headers and Footers fixed."
