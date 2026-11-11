# ==============================================================================
# VPN One - iOS IPA Packaging Script for Windows
# ==============================================================================
# Note: On Windows, Apple Xcode is not available, so this script packages
# the Payload structure and creates a .ipa archive using Windows PowerShell.
# For a production compiled & signed IPA, use the included GitHub Actions workflow.
# ==============================================================================

$ProjectRoot = "C:\Users\PC\Desktop\VPN"
$IpaOutputDir = "$ProjectRoot\build\ios\ipa"
$PayloadDir = "$IpaOutputDir\Payload"
$AppDir = "$PayloadDir\Runner.app"
$OutputFile = "$IpaOutputDir\VPN_One_Release.ipa"

Write-Host "=== Setting up iOS IPA Payload Structure ===" -ForegroundColor Cyan

# 1. Clean previous build folder
if (Test-Path $IpaOutputDir) {
    Remove-Item -Recurse -Force $IpaOutputDir
}
New-Item -ItemType Directory -Force -Path $AppDir | Out-Null

# 2. Copy iOS Assets and Info.plist into Runner.app
Write-Host "=== Bundling iOS App Payload ===" -ForegroundColor Cyan
Copy-Item "$ProjectRoot\ios\Runner\Info.plist" "$AppDir\Info.plist" -Force
if (Test-Path "$ProjectRoot\ios\Runner\Assets.xcassets") {
    Copy-Item -Recurse "$ProjectRoot\ios\Runner\Assets.xcassets" "$AppDir\Assets.xcassets" -Force
}

# 3. Create .ipa (Windows Compress-Archive)
Write-Host "=== Compressing Payload into VPN_One_Release.ipa ===" -ForegroundColor Cyan
Set-Location $IpaOutputDir

Compress-Archive -Path "Payload" -DestinationPath "$IpaOutputDir\VPN_One_Release.zip" -Force
Rename-Item "$IpaOutputDir\VPN_One_Release.zip" "VPN_One_Release.ipa" -Force

Set-Location $ProjectRoot

Write-Host ""
Write-Host "[SUCCESS] IPA Package Created!" -ForegroundColor Green
Write-Host "Location: $OutputFile" -ForegroundColor Yellow

