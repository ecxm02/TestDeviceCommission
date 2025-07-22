# Android Device Commission Script

A comprehensive ADB script suite to debloat Android devices and sideload essential APKs. Perfect for quickly configuring new Android devices or cleaning up bloated phones.

## 🚀 Quick Start

1. **Enable Developer Options** on your Android device:
   - Go to Settings → About Phone → Tap "Build Number" 7 times
   - Go to Settings → Developer Options → Enable "USB Debugging"

2. **Connect your device** via USB and authorize the computer

3. **Run the script**:
   ```powershell
   # PowerShell (recommended)
   .\android_debloat.ps1
   
   # Or use the batch wrapper
   .\run_debloat.bat
   ```

## 📁 Files Overview

### Main Scripts
- **`android_debloat.ps1`** - Main PowerShell script with full functionality
- **`run_debloat.bat`** - Batch wrapper for easy execution
- **`restore_app.ps1`** - Recovery script to restore accidentally removed apps

### Configuration Files
- **`bloatware_packages.txt`** - List of packages to remove (customizable)
- **`recommended_apps.txt`** - Guide for essential APKs to install
- **`manual_adb_commands.txt`** - Reference for manual ADB commands

### APK Storage
- **`apks/`** - Folder to place APK files for automatic installation

## 🛠️ Features

### Bloatware Removal
- ✅ Safely removes/disables unwanted apps
- ✅ Supports all major manufacturers (Samsung, Xiaomi, Huawei, etc.)
- ✅ Customizable package list
- ✅ Detailed removal summary
- ✅ Fallback to disable if uninstall fails

### APK Installation
- ✅ Batch install APKs from folder
- ✅ Installation progress tracking
- ✅ Automatic APK discovery
- ✅ Detailed installation summary

### Safety Features
- ✅ Device connection verification
- ✅ Non-destructive removal (user-level only)
- ✅ Comprehensive error handling
- ✅ Recovery script included
- ✅ Warning about critical system apps

## 📋 Prerequisites

1. **ADB (Android Debug Bridge)** installed and in PATH
   - Download Android SDK Platform Tools
   - Add to Windows PATH environment variable

2. **PowerShell** (usually pre-installed on Windows)

3. **USB Debugging enabled** on Android device

## 🎯 Usage Examples

### Basic Usage
```powershell
# Run full debloat and APK installation
.\android_debloat.ps1

# Skip bloatware removal, only install APKs
.\android_debloat.ps1 -SkipBloatwareRemoval

# Skip APK installation, only remove bloatware
.\android_debloat.ps1 -SkipAPKInstall

# Run without prompts (automated)
.\android_debloat.ps1 -Force
```

### Recovery
```powershell
# List disabled packages
.\restore_app.ps1 -ListDisabled

# Restore a specific package
.\restore_app.ps1 -PackageName com.android.calculator2
```

## 🔧 Customization

### Modify Bloatware List
Edit `bloatware_packages.txt` to add/remove packages:
```
# Add packages you want to remove
com.example.unwanted.app

# Comment out packages you want to keep
# com.google.android.maps
```

### Add APKs for Installation
1. Download APKs from trusted sources
2. Place them in the `apks/` folder
3. Run the script - they'll be installed automatically

## ⚠️ Important Warnings

### DO NOT REMOVE These Critical Packages:
- `com.android.systemui` (System UI)
- `com.android.settings` (Settings app)
- `com.android.phone` (Phone app)
- `com.google.android.gms` (Google Play Services)
- `com.android.vending` (Google Play Store)
- `com.android.launcher3` (Default launcher)

### Before Running:
- ✅ Backup important data
- ✅ Ensure device is charged (>50%)
- ✅ Test with non-critical device first
- ✅ Read the bloatware list and customize it

## 🔍 Troubleshooting

### Device Not Detected
```powershell
# Check ADB connection
adb devices

# Restart ADB server
adb kill-server
adb start-server
```

### Package Not Found
- Package might already be removed
- Package name might be incorrect
- Package might be manufacturer-specific

### Installation Failures
- Check if "Install from Unknown Sources" is enabled
- Verify APK file integrity
- Ensure enough storage space

## 📱 Supported Devices

- ✅ Samsung Galaxy series
- ✅ Xiaomi/MIUI devices  
- ✅ Huawei devices
- ✅ Google Pixel
- ✅ OnePlus
- ✅ Most Android devices with USB debugging

## 🔗 Recommended APK Sources

- **F-Droid** - https://f-droid.org/ (Open source apps)
- **APKMirror** - https://www.apkmirror.com/ (Verified APKs)
- **Official websites** - Always prefer official sources

## 📝 License

This project is provided as-is for educational and personal use. Use at your own risk.

## 🤝 Contributing

Feel free to submit issues, suggestions, or improvements to the bloatware lists and scripts.
