$files = Get-ChildItem -Path "c:\Users\DELL\Downloads\mediishealth" -Filter *.html

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

foreach ($file in $files) {
    # Safe read
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    $originalContent = $content

    # 1. Add mobile-menu-btn if missing
    if ($content -notmatch 'class="mobile-menu-btn"') {
        $content = $content -replace '(</nav>)', "`$1`n            <button class=`"mobile-menu-btn`">&#9776;</button>"
    }

    # 2. Remove all Login/Signup buttons
    $content = $content -replace '<button class="btn btn-primary" id="loginBtn">.*?</button>', ''
    
    # 3. Remove login modals
    $content = $content -replace '(?s)<div id="loginModal" class="modal">.*?</div>\s*</div>', ''

    # 4. Replace SVG Logo with logo.png
    $content = $content -replace '(?s)<svg.*?</svg>', '<img src="logo.png" alt="Logo" style="height: 40px; margin-right: 10px; vertical-align: middle;">'
    $content = $content -replace '(?s)<!-- SVG Logo Mockup -->.*?<img', '<img'

    # 5. Fix icons (replace corrupted emojis with images)
    $content = $content -replace '<div class="card-icon">🌿</div>', '<div class="card-icon"><img src="icon_teleconsultation.png" alt="Tele-consultation" style="width: 100%; height: 100%; border-radius: inherit; object-fit: cover;"></div>'
    $content = $content -replace '<div class="card-icon">💳</div>', '<div class="card-icon"><img src="icon_ayushman.png" alt="Ayushman Card" style="width: 100%; height: 100%; border-radius: inherit; object-fit: cover;"></div>'
    $content = $content -replace '<div class="card-icon">🏥</div>', '<div class="card-icon"><img src="icon_surgery.png" alt="Surgery Guidance" style="width: 100%; height: 100%; border-radius: inherit; object-fit: cover;"></div>'
    $content = $content -replace '<div class="card-icon">🤝</div>', '<div class="card-icon"><img src="icon_cm_fund.png" alt="CM Fund Assistance" style="width: 100%; height: 100%; border-radius: inherit; object-fit: cover;"></div>'

    if ($content -cne $originalContent) {
        # Safe write
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        Write-Output "Updated $($file.Name)"
    }
}

# Update app.js to remove login modal logic
$appJsPath = "c:\Users\DELL\Downloads\mediishealth\app.js"
if (Test-Path $appJsPath) {
    $appJs = [System.IO.File]::ReadAllText($appJsPath, $utf8NoBom)
    $appJs = $appJs -replace '(?s)// Modal logic for Login/Signup.*?// Dummy form submissions', '// Dummy form submissions'
    [System.IO.File]::WriteAllText($appJsPath, $appJs, $utf8NoBom)
    Write-Output "Updated app.js"
}

Write-Output "Done"
