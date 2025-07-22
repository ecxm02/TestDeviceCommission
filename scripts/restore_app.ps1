# Quick Restore Script for Accidentally Removed Apps
# Use this if you accidentally removed something important

param(
    [string]$PackageName,
    [switch]$ListDisabled
)

function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

if ($ListDisabled) {
    Write-Info "Listing disabled packages..."
    adb shell pm list packages -d
    exit 0
}

if (-not $PackageName) {
    Write-Error "Please provide a package name to restore"
    Write-Info "Usage: .\restore_app.ps1 -PackageName com.example.app"
    Write-Info "Or list disabled packages: .\restore_app.ps1 -ListDisabled"
    exit 1
}

Write-Info "Attempting to restore package: $PackageName"

# Try to enable the package
$result = adb shell pm enable $PackageName 2>&1

if ($result -match "enabled") {
    Write-Success "Successfully restored: $PackageName"
} else {
    Write-Warning "Could not enable package. Trying to install from system..."
    
    # Try to install from system partition
    $installResult = adb shell cmd package install-existing $PackageName 2>&1
    
    if ($installResult -match "Success") {
        Write-Success "Successfully reinstalled: $PackageName"
    } else {
        Write-Error "Failed to restore package: $PackageName"
        Write-Info "You may need to reinstall from APK or factory reset"
    }
}

Write-Info "Checking if package is now available..."
$check = adb shell pm list packages $PackageName
if ($check) {
    Write-Success "Package is now available: $check"
} else {
    Write-Error "Package is still not available"
}
