# Android Device Commission Script
# This script removes bloatware and sideloads essential APKs

param(
    [switch]$SkipBloatwareRemoval,
    [switch]$SkipAPKInstall,
    [string]$APKFolder = "..\apks",
    [switch]$Force
)

# Color functions for better output
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

# Check if ADB is available
function Test-ADBConnection {
    Write-Info "Checking ADB connection..."
    
    try {
        $devices = adb devices 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ADB is not installed or not in PATH"
            Write-Info "Please install Android SDK Platform Tools and add to PATH"
            exit 1
        }
        
        $deviceLines = $devices | Select-String -Pattern "device$"
        if ($deviceLines.Count -eq 0) {
            Write-Error "No Android device connected or device not authorized"
            Write-Info "Please:"
            Write-Info "1. Connect your Android device via USB"
            Write-Info "2. Enable USB Debugging in Developer Options"
            Write-Info "3. Authorize the computer when prompted"
            exit 1
        }
        
        Write-Success "Found $($deviceLines.Count) connected device(s)"
        return $true
    }
    catch {
        Write-Error "Failed to check ADB connection: $($_.Exception.Message)"
        exit 1
    }
}

# Enable Developer Options and USB Debugging reminder
function Show-DeveloperOptionsReminder {
    Write-Warning "IMPORTANT: Before running this script, ensure:"
    Write-Info "1. Developer Options are enabled (Settings > About Phone > tap Build Number 7 times)"
    Write-Info "2. USB Debugging is enabled (Settings > Developer Options > USB Debugging)"
    Write-Info "3. Device is connected via USB and authorized"
    Write-Info ""
    
    if (-not $Force) {
        $response = Read-Host "Press Enter to continue or 'q' to quit"
        if ($response -eq 'q') {
            Write-Info "Script cancelled by user"
            exit 0
        }
    }
}

# Function to uninstall bloatware
function Remove-Bloatware {
    Write-Info "Starting bloatware removal..."
    
    # Load bloatware list
    $bloatwareFile = "..\config\bloatware_packages.txt"
    if (-not (Test-Path $bloatwareFile)) {
        Write-Warning "Bloatware list file not found: $bloatwareFile"
        Write-Info "Creating default bloatware list..."
        Create-DefaultBloatwareList
    }
    
    $packages = Get-Content $bloatwareFile | Where-Object { $_ -and -not $_.StartsWith('#') }
    
    Write-Info "Found $($packages.Count) packages to remove"
    
    $successCount = 0
    $failCount = 0
    $notFoundCount = 0
    
    foreach ($package in $packages) {
        $package = $package.Trim()
        if ([string]::IsNullOrWhiteSpace($package)) { continue }
        
            
            if ($result -match "Success") {
                $disableResult = adb shell pm disable-user --user 0 $package 2>&1
                if ($disableResult -match "disabled") {
                else {
                    Write-Error "  ✗ Failed: $package - $result"
        else {
            Write-Host "  - Not found: $package" -ForegroundColor Gray
    Write-Info ""
    Write-Info "Bloatware removal summary:"
    Write-Success "  Successfully removed/disabled: $successCount"
    Write-Error "  Failed: $failCount"
    Write-Host "  Not found: $notFoundCount" -ForegroundColor Gray
}

# Function to install APKs
function Install-APKs {
    Write-Info "Starting APK installation..."
    
    if (-not (Test-Path $APKFolder)) {
        Write-Warning "APK folder not found: $APKFolder"
        Write-Info "Creating APK folder and example list..."
        New-Item -ItemType Directory -Path $APKFolder -Force | Out-Null
        Create-APKList
        Write-Info "Please place your APK files in the '$APKFolder' folder and run the script again"
        return
    }
    
    $apkFiles = Get-ChildItem -Path $APKFolder -Filter "*.apk"
    
    if ($apkFiles.Count -eq 0) {
        Write-Warning "No APK files found in $APKFolder"
        Create-APKList
        return
    }
    
    Write-Info "Found $($apkFiles.Count) APK files to install"
    
    $successCount = 0
    $failCount = 0
    
    foreach ($apk in $apkFiles) {
        Write-Host "Installing: $($apk.Name)" -ForegroundColor Yellow
        
        $result = adb install -r $apk.FullName 2>&1
        
        if ($result -match "Success") {
            Write-Success "  ✓ Installed: $($apk.Name)"
            $successCount++
        }
        else {
            Write-Error "  ✗ Failed: $($apk.Name) - $result"
            $failCount++
        }
    }
    
    Write-Info ""
    Write-Info "APK installation summary:"
    Write-Success "  Successfully installed: $successCount"
    Write-Error "  Failed: $failCount"
}

# Create default bloatware list
function Create-DefaultBloatwareList {
    $bloatwareContent = @"
# Android Bloatware Removal List
# Lines starting with # are comments
# Add one package name per line
# Common bloatware packages (customize as needed)

# Google Apps (remove if you don't use)
com.google.android.apps.books
com.google.android.apps.magazines
com.google.android.apps.movies
com.google.android.apps.photos
com.google.android.apps.plus
com.google.android.apps.docs
com.google.android.apps.maps
com.google.android.music
com.google.android.videos
com.google.android.youtube
com.google.android.talk
com.google.android.apps.tachyon

# Samsung Bloatware (if Samsung device)
com.samsung.android.bixby.agent
com.samsung.android.app.spage
com.samsung.android.bixby.wakeup
com.samsung.android.visionintelligence
com.samsung.android.app.episodes
com.samsung.android.app.music
com.samsung.android.app.notes
com.samsung.android.email.provider
com.samsung.android.samsungpass
com.samsung.android.spay
com.samsung.android.pay.framework
com.samsung.android.app.soundpicker
com.samsung.android.app.simplesharing
com.samsung.android.app.sharelive
com.samsung.android.app.social
com.samsung.android.game.gamehome
com.samsung.android.game.gametools
com.samsung.android.livestickers
com.samsung.android.app.camera.sticker.facearavatar.preload
com.samsung.storyservice
com.samsung.android.themestore
com.samsung.android.wellbeing

# Facebook/Meta Apps
com.facebook.katana
com.facebook.system
com.facebook.appmanager
com.facebook.services
com.instagram.android
com.whatsapp

# Microsoft Apps (remove if not needed)
com.microsoft.skydrive
com.microsoft.office.word
com.microsoft.office.excel
com.microsoft.office.powerpoint
com.skype.raider

# Other Common Bloatware
com.netflix.mediaclient
com.spotify.music
com.amazon.mShop.android.shopping
com.booking
com.ubercab
com.twitter.android
com.linkedin.android
com.snapchat.android
com.pinterest


    $bloatwareContent | Out-File -FilePath "..\config\bloatware_packages.txt" -Encoding UTF8
    Write-Success "Created default bloatware list: ..\config\bloatware_packages.txt"
    Write-Info "Edit this file to customize which packages to remove"
}

# Create APK installation list
function Create-APKList {
    $apkListContent = @"
# Essential APKs to Install
# Place your APK files in the 'apks' folder
# Recommended apps:

Essential Apps:
- F-Droid (open source app store)
- Firefox or Chrome
- Signal (secure messaging)
- VLC Media Player
- 7-Zip
- Simple Gallery Pro
- Simple Calendar Pro

Privacy/Security:
- ProtonMail
- ProtonVPN
- Bitwarden
- AdGuard
- Tor Browser

Development/Technical:
- Termux
- SSH/SFTP client
- Network analyzer

Productivity:
- LibreOffice Viewer
- Simple Notes
- Simple File Manager
- K-9 Mail

Note: Download APKs from official sources or trusted repositories like:
- APKMirror
- F-Droid
- APKPure
- Official websites


    $apkListContent | Out-File -FilePath "..\config\recommended_apps.txt" -Encoding UTF8
    Write-Success "Created recommended apps list: ..\config\recommended_apps.txt"
}

# Main execution
function Main {
    Write-Info "=== Android Device Commission Script ==="
    Write-Info "This script will debloat your Android device and install essential APKs"
    Write-Info ""
    
    Show-DeveloperOptionsReminder
    Test-ADBConnection
    
    # Get device info
    $deviceInfo = adb shell getprop ro.product.model 2>&1
    $androidVersion = adb shell getprop ro.build.version.release 2>&1
    Write-Info "Device: $deviceInfo (Android $androidVersion)"
    Write-Info ""
    
    if (-not $SkipBloatwareRemoval) {
        Remove-Bloatware
        Write-Info ""
    }
    
    if (-not $SkipAPKInstall) {
        Install-APKs
        Write-Info ""
    }
    
    Write-Success "Device commissioning completed!"
    Write-Info "You may want to reboot your device to ensure all changes take effect"
    
    if (-not $Force) {
        $reboot = Read-Host "Reboot device now? (y/N)"
        if ($reboot -eq 'y' -or $reboot -eq 'Y') {
            Write-Info "Rebooting device..."
            adb reboot
        }
    }
}

# Run the main function
Main
"@
