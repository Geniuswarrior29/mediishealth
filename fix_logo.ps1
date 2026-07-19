$files = Get-ChildItem -Path "c:\Users\DELL\Downloads\mediishealth" -Filter *.html
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Base64 string for "मेडीस हेल्थ एंड लैब"
$hiText = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("4KSu4KWH4KOh4KWA4KS4IOCkueClh+CksuCljeCkpCDgpo/§gpoHgpKEg4KSy4KWM4KSc"))
# Wait, "एंड" in hindi is "4KSP4KSC4KOh". Let me just use pure text with UTF-8 encoding. I know my powershell script will execute it correctly.

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    
    if ($file.Name -match "-hi\.html") {
        # Replace the SVG OR logo.png block with Mediis Health with the new logo and text
        $content = $content -replace '(?s)(<a href="[^"]+" class="logo">\s*)(<svg[^>]+>.*?</svg>|<img[^>]+>)\s*Mediis Health\s*(</a>)', "`$1<img src=`"logo.png`" alt=`"Logo`" style=`"height: 40px; margin-right: 10px; vertical-align: middle;`">`r`n                मेडीस हेल्थ एंड लैब`r`n            </a>"
        $content = $content -replace '(?s)(<a href="[^"]+" class="logo">\s*)(<svg[^>]+>.*?</svg>|<img[^>]+>)\s*मेडीस हेल्थ\s*(</a>)', "`$1<img src=`"logo.png`" alt=`"Logo`" style=`"height: 40px; margin-right: 10px; vertical-align: middle;`">`r`n                मेडीस हेल्थ एंड लैब`r`n            </a>"
    } else {
        $content = $content -replace '(?s)(<a href="[^"]+" class="logo">\s*)(<svg[^>]+>.*?</svg>|<img[^>]+>)\s*Mediis Health\s*(</a>)', "`$1<img src=`"logo.png`" alt=`"Logo`" style=`"height: 40px; margin-right: 10px; vertical-align: middle;`">`r`n                Mediis Health and Lab`r`n            </a>"
    }
    
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
}
Write-Host "Logo replaced globally."
