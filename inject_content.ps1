$indexPath = "c:\Users\DELL\Downloads\mediishealth\index.html"
$indexHiPath = "c:\Users\DELL\Downloads\mediishealth\index-hi.html"

$contentEnPath = "C:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_en.html"
$contentHiPath = "C:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_hi.html"

$contentEn = Get-Content -Path $contentEnPath -Raw
$contentHi = Get-Content -Path $contentHiPath -Raw

$indexHtml = Get-Content -Path $indexPath -Raw
$indexHiHtml = Get-Content -Path $indexHiPath -Raw

$oldImg = "https://images.unsplash.com/photo-1579684385127-1ef15d508118\?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"
$newImg = "https://i.pinimg.com/736x/66/55/7f/66557f44772f819559d88dba6adfd519.jpg"

# Replace hero image
$indexHtml = $indexHtml -replace $oldImg, $newImg
$indexHiHtml = $indexHiHtml -replace $oldImg, $newImg

# Inject content before <!-- Footer --> if not already injected
if ($indexHtml -notmatch "The Power of Ayurveda Section") {
    $indexHtml = $indexHtml -replace '<!-- Footer -->', "$contentEn`n    <!-- Footer -->"
}
if ($indexHiHtml -notmatch "आयुर्वेद की शक्ति") {
    $indexHiHtml = $indexHiHtml -replace '<!-- Footer -->', "$contentHi`n    <!-- Footer -->"
}

Set-Content -Path $indexPath -Value $indexHtml -Encoding UTF8
Set-Content -Path $indexHiPath -Value $indexHiHtml -Encoding UTF8

Write-Output "Injected content successfully."
