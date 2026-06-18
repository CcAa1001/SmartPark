# Automation build script for SmartPark release APK

Write-Host "Building release APK..." -ForegroundColor Blue
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build Succeeded!" -ForegroundColor Green
    
    # Create web_deploy folder if it doesn't exist
    if (!(Test-Path "web_deploy")) {
        New-Item -ItemType Directory -Path "web_deploy" | Out-Null
    }
    
    # Copy build output to web_deploy directory
    Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "web_deploy\app-release.apk" -Force
    Write-Host "Copied release APK to: web_deploy\app-release.apk" -ForegroundColor Green
    Write-Host "You can now upload the 'web_deploy' folder to your host or commit it to GitHub!" -ForegroundColor Yellow
} else {
    Write-Host "Build Failed. Please check the compiler errors above." -ForegroundColor Red
}
