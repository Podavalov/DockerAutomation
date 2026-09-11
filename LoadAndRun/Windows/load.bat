@echo off
setlocal

set "SCRIPT=%~dp0load.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] File not found: %SCRIPT%
    pause
    exit /b 1
)

echo ---------------------------------------------------
echo Loading images and starting containers...
echo ---------------------------------------------------

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%ERRORLEVEL%"

echo.
echo ===================================================
if "%RC%"=="0" (
    echo Loading and startup are complete.
) else (
    echo Loading and startup finished with errors. Exit code: %RC%
)
pause

endlocal
exit /b %RC%