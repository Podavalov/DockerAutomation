@echo off
setlocal

set "SCRIPT=%~dp0run.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] File not found: %SCRIPT%
    pause
    exit /b 1
)

echo ---------------------------------------------------
echo Starting running containers...
echo ---------------------------------------------------

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%ERRORLEVEL%"

echo.
echo ===================================================
if "%RC%"=="0" (
    echo Launch complete.
) else (
    echo Launch finished with errors. Exit code: %RC%
)
pause

endlocal
exit /b %RC%