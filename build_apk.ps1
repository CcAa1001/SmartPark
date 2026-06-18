# Automation build script for SmartPark release APK

Write-Host "Building release APK..." -ForegroundColor Blue
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build Succeeded!" -ForegroundColor Green
    
    # Create docs folder if it doesn't exist
    if (!(Test-Path "docs")) {
        New-Item -ItemType Directory -Path "docs" | Out-Null
    }
    
    # Copy build output to docs directory
    Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "docs\app-release.apk" -Force
    Write-Host "Copied release APK to: docs\app-release.apk" -ForegroundColor Green
    Write-Host "You can now upload the 'docs' folder to your host or commit it to GitHub!" -ForegroundColor Yellow
} else {
    Write-Host "Build Failed. Please check the compiler errors above." -ForegroundColor Red
}
