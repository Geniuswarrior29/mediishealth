$files = Get-ChildItem -Path "c:\Users\DELL\Downloads\mediishealth" -Filter *.html
$utf8 = New-Object System.Text.UTF8Encoding $false

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8)

    # 1. Remove login modal and button (safe ASCII regex)
    $content = $content -replace '(?s)<div id="loginModal" class="modal">.*?</div>\s*</div>', ''
    $content = $content -replace '<button class="btn btn-primary" id="loginBtn">.*?</button>', ''

    # 2. Add mobile menu button (safe ASCII regex)
    if ($content -notmatch 'class="mobile-menu-btn"') {
        $content = $content -replace '(</nav>)', "`$1`r`n            <button class=`"mobile-menu-btn`">&#9776;</button>"
    }

    # 3. Replace SVG Logo with image (safe ASCII regex)
    $content = $content -replace '(?s)<svg.*?</svg>', '<img src="logo.png" alt="Logo" style="height: 40px; margin-right: 10px; vertical-align: middle;">'
    $content = $content -replace '(?s)<!-- SVG Logo Mockup -->.*?<img', '<img'
    
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8)
}

# 4. Clean app.js of login logic
$appJsPath = "c:\Users\DELL\Downloads\mediishealth\app.js"
if (Test-Path $appJsPath) {
    $appJs = [System.IO.File]::ReadAllText($appJsPath, $utf8)
    $appJs = $appJs -replace '(?s)// Modal logic for Login/Signup.*?(?=\s*// Dummy form submissions)', ''
    [System.IO.File]::WriteAllText($appJsPath, $appJs, $utf8)
}

Write-Host "Done global ASCII replacements"
