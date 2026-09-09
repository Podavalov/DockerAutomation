@echo off


echo ---------------------------------------------------
echo Starting running containers...
echo ---------------------------------------------------

:: Установка политики исполнения
PowerShell -ExecutionPolicy Bypass -Command "Set-StrictMode -Version Latest"

:: Вызов PowerShell для запуска основного скрипта
powershell.exe -File "Path to run.ps1"

echo.
echo ===================================================
echo Launch complete.
pause
