@echo off
REM Batch wrapper for PowerShell script - for users who prefer batch files
REM This allows easy execution without changing PowerShell execution policy

echo === Android Device Commission Script ===
echo.

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell detected' -ForegroundColor Green" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is not available or not in PATH
    echo Please ensure PowerShell is installed and accessible
    pause
    exit /b 1
)

echo Starting Android debloat script...
echo.

REM Execute the PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0android_debloat.ps1" %*

echo.
echo Script execution completed.
pause
