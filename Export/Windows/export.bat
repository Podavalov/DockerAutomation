@echo off


echo ---------------------------------------------------
echo Start Export Process...
echo ---------------------------------------------------


PowerShell -ExecutionPolicy Bypass -Command "Set-StrictMode -Version Latest"


powershell.exe -File "Path to export.ps1"

echo.
echo ===================================================
echo Export Process is done.
pause
