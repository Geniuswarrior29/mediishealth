$files = Get-ChildItem -Path "c:\Users\DELL\Downloads\mediishealth" -Filter *.html

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw

    $originalContent = $content

    $buttonHtml = '<button class="mobile-menu-btn">&#9776;</button>'
    
    # Check if button already exists to avoid duplication
    if ($content -notmatch 'class="mobile-menu-btn"') {
        # Insert button just before the closing </div> of the header container
        # Since it's inside <header class="header"> -> <div class="container flex-between">
        # Let's just insert it after the nav-links closing tag </nav>
        $content = $content -replace '(</nav>)', "`$1`n            $buttonHtml"
    }

    if ($content -cne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Output "Updated $($file.Name)"
    }
}
Write-Output "Done"
