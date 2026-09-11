@echo off
setlocal

set "SCRIPT=%~dp0build.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] File not found: %SCRIPT%
    pause
    exit /b 1
)

echo ---------------------------------------------------
echo Start Build Process...
echo ---------------------------------------------------

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%ERRORLEVEL%"

echo.
echo ===================================================
if "%RC%"=="0" (
    echo Build Process is done.
) else (
    echo Build Process finished with errors. Exit code: %RC%
)
pause

endlocal
exit /b %RC%