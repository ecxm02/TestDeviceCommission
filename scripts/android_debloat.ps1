# Android Debloat and APK Sideload Script (Standalone)
# This script removes bloatware and installs APKs from a folder, no external dependencies

param(
    [switch]$SkipBloatwareRemoval,
    [switch]$SkipAPKInstall,
[string]$APKFolder = "..\apks",
    [switch]$Force
)

function Write-Color($Message, $Color) {
    Write-Host $Message -ForegroundColor $Color
}

function Test-ADB {
    Write-Color "Checking ADB connection..." Cyan
    $adb = Get-Command adb -ErrorAction SilentlyContinue
    if (-not $adb) {
        Write-Color "ADB is not installed or not in PATH." Red
        exit 1
    }
    $devices = adb devices 2>&1
    $deviceLines = $devices -split "`n" | Where-Object { $_ -match "device\s*$" -and $_ -notmatch "List of devices" }
    if ($deviceLines.Count -eq 0) {
        Write-Color "No Android device connected or not authorized." Red
        exit 1
    }
    Write-Color "ADB is available and device is connected." Green
}

function Get-BloatwareList {
    $defaultList = @(
        "com.facebook.katana",
        "com.facebook.appmanager",
        "com.facebook.services",
        "com.facebook.system",
        "com.amazon.kindle",
        "com.amazon.appmanager",
        "com.netflix.mediaclient"
    )
    $configPath = "..\config\bloatware_packages.txt"
    if (-not (Test-Path $configPath)) {
        if (-not (Test-Path "..\config")) {
            New-Item -ItemType Directory -Path "..\config" -Force | Out-Null
        }
        $defaultList | Set-Content $configPath
        Write-Color "Created default bloatware list at $configPath" Green
        Write-Color "Edit this file to customize which packages to remove" Cyan
    }
    Get-Content $configPath | Where-Object { $_ -and -not $_.StartsWith('#') }
}

function Remove-Bloatware {
    Write-Color "Starting bloatware removal..." Cyan
    $packages = Get-BloatwareList
    $success = 0; $fail = 0; $notfound = 0
    foreach ($pkg in $packages) {
        $pkg = $pkg.Trim()
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $result = adb shell pm uninstall --user 0 $pkg 2>&1
        if ($result -match "Success") {
            Write-Color ("  [OK] Removed: {0}" -f $pkg) Green
            $success++
        } elseif ($result -match "not installed for") {
            Write-Color ("  - Not found: {0}" -f $pkg) Yellow
            $notfound++
        } else {
            Write-Color ("  [X] Failed: {0} - {1}" -f $pkg, $result) Red
            $fail++
        }
    }
    Write-Color "Summary: $success removed, $fail failed, $notfound not found" Cyan
}

function Install-APKs {
    Write-Color "Starting APK installation..." Cyan
    if (-not (Test-Path $APKFolder)) {
        New-Item -ItemType Directory -Path $APKFolder -Force | Out-Null
        Write-Color "APK folder created at $APKFolder. Add APKs and rerun." Yellow
        return
    }
    $apks = Get-ChildItem -Path $APKFolder -Filter "*.apk"
    if ($apks.Count -eq 0) {
        Write-Color "No APK files found in $APKFolder" Yellow
        return
    }
    $success = 0; $fail = 0
    foreach ($apk in $apks) {
        Write-Color ("Installing: {0}" -f $apk.Name) Yellow
        $result = adb install -r $apk.FullName 2>&1
        if ($result -match "Success") {
            Write-Color ("  [OK] Installed: {0}" -f $apk.Name) Green
            $success++
        } else {
            Write-Color ("  [X] Failed: {0} - {1}" -f $apk.Name, $result) Red
            $fail++
        }
    }
    Write-Color "Summary: $success installed, $fail failed" Cyan
}

# Main
Write-Color "=== Android Debloat & APK Sideload ===" Cyan
Test-ADB
if (-not $SkipBloatwareRemoval) { Remove-Bloatware }
if (-not $SkipAPKInstall) { Install-APKs }
Write-Color "All done! You may want to reboot your device." Green
if (-not $Force) {
    $reboot = Read-Host "Reboot device now? (y/N)"
    if ($reboot -eq 'y' -or $reboot -eq 'Y') {
        Write-Color "Rebooting device..." Cyan
        adb reboot
    }
}
