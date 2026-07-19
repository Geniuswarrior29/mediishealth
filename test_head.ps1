$files = Get-ChildItem -Path "c:\Users\DELL\Downloads\mediishealth" -Filter *.html
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

$headerActionsEn = @"
                <div class="header-actions">
                    <select id="langSelect" style="padding: 0.5rem; border:1px solid var(--border); border-radius:4px; outline:none;">
                        <option value="en">Eng</option>
                        <option value="hi">हिन्दी</option>
                    </select>
                    <a href="book-consultation.html" class="btn btn-primary" style="color: white !important;">Book Consultation</a>
                </div>
"@

$headerActionsHi = @"
                <div class="header-actions">
                    <select id="langSelect" style="padding: 0.5rem; border:1px solid var(--border); border-radius:4px; outline:none;">
                        <option value="en">Eng</option>
                        <option value="hi" selected>हिन्दी</option>
                    </select>
                    <a href="book-consultation-hi.html" class="btn btn-primary" style="color: white !important;">परामर्श बुक करें</a>
                </div>
"@

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    
    # First, strip out any existing <div class="header-actions">...</div> inside the header
    $content = $content -replace '(?s)<div class="header-actions">.*?</div>', ''
    
    # Strip out any existing hamburger menu button
    $content = $content -replace '<button class="mobile-menu-btn">&#9776;</button>', ''

    # Now, inject the new header actions inside the <nav> right before </nav>
    $actions = if ($file.Name -match '-hi\.html') { $headerActionsHi } else { $headerActionsEn }
    
    $content = $content -replace '(?s)(</nav>\s*</div>\s*</header>)', "$actions`r`n            `$1"
    
    # Add the hamburger button AFTER the </nav>
    $content = $content -replace '(?s)(</nav>)', "`$1`r`n            <button class=`"mobile-menu-btn`">&#9776;</button>"
    
    # Wait, the first replace might not work if there's no </div> after </nav>. 
    # Let's do it safer: 
    # Find </nav> and replace it with $actions + </nav>
    # Actually, I'll rewrite the replacement to be guaranteed.
}
