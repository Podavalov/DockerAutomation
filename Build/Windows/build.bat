@echo off

echo ---------------------------------------------------
echo Start Build Process...
echo ---------------------------------------------------

PowerShell -ExecutionPolicy Bypass -Command "Set-StrictMode -Version Latest"


powershell.exe -File "Path to build.ps1"

echo.
echo ===================================================
echo Build Process is done.
pause
