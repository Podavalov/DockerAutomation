@echo off


echo ---------------------------------------------------
echo Loading images and starting containers...
echo ---------------------------------------------------


PowerShell -ExecutionPolicy Bypass -Command "Set-StrictMode -Version Latest"


powershell.exe -File "Path to load.ps1"

echo.
echo ===================================================
echo Loading and startup are complete.
pause
