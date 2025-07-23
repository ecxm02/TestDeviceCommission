# Quick Restore Script for Accidentally Removed Apps
# Use this if you accidentally removed something important

param(
    [string]$PackageName,
    [switch]$ListDisabled,
    [switch]$AllBloatware
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

if ($AllBloatware) {
    $bloatwareFile = "..\config\bloatware_packages.txt"
    if (-not (Test-Path $bloatwareFile)) {
        Write-Error "Bloatware list not found: $bloatwareFile"
        exit 1
    }
    $packages = Get-Content $bloatwareFile | Where-Object { $_ -and -not $_.StartsWith('#') }
    if ($packages.Count -eq 0) {
        Write-Error "No packages found in bloatware list."
        exit 1
    }
    $enabled = 0
    $installed = 0
    $failed = 0
    foreach ($pkg in $packages) {
        $pkg = $pkg.Trim()
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        Write-Info "Restoring: $pkg"
        $result = adb shell pm enable $pkg 2>&1
        if ($result -match "enabled") {
            Write-Success "  ✓ Enabled: $pkg"
            $enabled++
        } else {
            Write-Warning "  ~ Could not enable, trying install-existing: $pkg"
            $installResult = adb shell cmd package install-existing $pkg 2>&1
            if ($installResult -match "Success") {
                Write-Success "  ✓ Reinstalled: $pkg"
                $installed++
            } else {
                Write-Error "  ✗ Failed: $pkg - $installResult"
                $failed++
            }
        }
    }
    Write-Host "" -ForegroundColor Cyan
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  Enabled: $enabled" -ForegroundColor Green
    Write-Host "  Reinstalled: $installed" -ForegroundColor Green
    Write-Host "  Failed: $failed" -ForegroundColor Red
    exit 0
}


if (-not $PackageName) {
    Write-Error "Please provide a package name to restore, or use -AllBloatware to restore all from bloatware_packages.txt"
    Write-Info "Usage: .\restore_app.ps1 -PackageName com.example.app"
    Write-Info "       .\restore_app.ps1 -ListDisabled"
    Write-Info "       .\restore_app.ps1 -AllBloatware"
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
