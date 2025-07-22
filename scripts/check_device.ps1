# Device Information and Compatibility Checker
# Run this before the main debloat script to understand your device

function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

Write-Info "=== Android Device Information ==="

# Check ADB connection
try {
    $devices = adb devices 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ADB is not installed or not in PATH"
        exit 1
    }
    
    $deviceLines = $devices | Select-String -Pattern "device$"
    if ($deviceLines.Count -eq 0) {
        Write-Error "No Android device connected"
        exit 1
    }
    
    Write-Success "Device connected successfully"
}
catch {
    Write-Error "Failed to check ADB: $($_.Exception.Message)"
    exit 1
}

# Get device information
Write-Info "`nDevice Information:"
Write-Host "==================="

$brand = adb shell getprop ro.product.brand 2>&1
$model = adb shell getprop ro.product.model 2>&1
$manufacturer = adb shell getprop ro.product.manufacturer 2>&1
$androidVersion = adb shell getprop ro.build.version.release 2>&1
$apiLevel = adb shell getprop ro.build.version.sdk 2>&1
$buildId = adb shell getprop ro.build.id 2>&1
$security = adb shell getprop ro.build.version.security_patch 2>&1

Write-Host "Brand: $brand"
Write-Host "Model: $model"
Write-Host "Manufacturer: $manufacturer"
Write-Host "Android Version: $androidVersion (API Level $apiLevel)"
Write-Host "Build ID: $buildId"
Write-Host "Security Patch: $security"

# Check root status
$rootCheck = adb shell su -c "echo 'rooted'" 2>&1
if ($rootCheck -match "rooted") {
    Write-Warning "Device appears to be ROOTED"
} else {
    Write-Info "Device is NOT rooted (standard)"
}

# Check developer options  
Write-Host "USB Debugging: Enabled"

# Check available storage
Write-Info "`nStorage Information:"
Write-Host "===================="
$storage = adb shell df /data 2>&1
Write-Host $storage

# Get installed package count
Write-Info "`nPackage Information:"
Write-Host "====================="
$allPackages = adb shell pm list packages 2>&1 | Measure-Object
$systemPackages = adb shell pm list packages -s 2>&1 | Measure-Object
$userPackages = adb shell pm list packages -3 2>&1 | Measure-Object

Write-Host "Total packages: $($allPackages.Count)"
Write-Host "System packages: $($systemPackages.Count)"
Write-Host "User packages: $($userPackages.Count)"

# Manufacturer-specific recommendations
Write-Info "`nRecommendations for your device:"
Write-Host "================================="

$manufacturerLower = $manufacturer.ToLower()
switch -Wildcard ($manufacturerLower) {
    "*samsung*" {
        Write-Warning "Samsung device detected"
        Write-Info "- Be careful with Samsung Pay and Knox-related apps"
        Write-Info "- Samsung bloatware section in bloatware_packages.txt is relevant"
        Write-Info "- Consider keeping Samsung Health if you use it"
    }
    "*xiaomi*" {
        Write-Warning "Xiaomi device detected"
        Write-Info "- MIUI has extensive bloatware"
        Write-Info "- Be careful with com.miui.securitycenter"
        Write-Info "- Xiaomi/MIUI section in bloatware_packages.txt is relevant"
    }
    "*huawei*" {
        Write-Warning "Huawei device detected"
        Write-Info "- Huawei devices may have HMS instead of GMS"
        Write-Info "- Be careful with Huawei-specific system apps"
        Write-Info "- Huawei section in bloatware_packages.txt is relevant"
    }
    "*google*" {
        Write-Success "Google Pixel device detected"
        Write-Info "- Minimal bloatware expected"
        Write-Info "- Focus on Google Apps section if you want privacy"
    }
    "*oneplus*" {
        Write-Success "OnePlus device detected"
        Write-Info "- Generally clean Android experience"
        Write-Info "- Minimal manufacturer bloatware"
    }
    default {
        Write-Info "Generic Android device"
        Write-Info "- Review all manufacturer sections in bloatware_packages.txt"
        Write-Info "- Test with caution"
    }
}

# Security recommendations
Write-Info "`nSecurity Recommendations:"
Write-Host "=========================="
Write-Info "- Review bloatware_packages.txt before running the main script"
Write-Info "- Start with a test run on unimportant apps"
Write-Info "- Backup important data before proceeding"
Write-Info "- Keep the restore_app.ps1 script handy"

Write-Success "`nDevice check completed! You can now run android_debloat.ps1"
