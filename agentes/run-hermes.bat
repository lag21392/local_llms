@echo off
setlocal
cd /d "%~dp0.."
set "ROOT=%CD%"
call "%ROOT%\scripts\config.cmd"
set "HERMES_HOME=%ROOT%\agentes\hermes"

%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\_write-runtime-config.ps1" -Ctx %HERMES_MIN_CTX% -HermesHome "%HERMES_HOME%" -SkipLiteLLM -ApiKey "%API_KEY%"
if errorlevel 1 (
    echo FATAL: no se pudo escribir la config de Hermes
    pause
    exit /b 1
)

set "PATH=%HERMES_HOME%\bin;%HERMES_HOME%\hermes-agent\venv\Scripts;%PATH%"

echo.
echo Hermes  -^> %HERMES_BASE_URL%  modelo=%HERMES_MODEL%  ctx=%HERMES_MIN_CTX%
echo HERMES_HOME=%HERMES_HOME%
echo.
echo Si el modelo no esta arriba, lanza antes scripts\run-3070.bat o scripts\run-5070ti.bat
echo.

if exist "%HERMES_HOME%\bin\hermes.exe" (
    "%HERMES_HOME%\bin\hermes.exe"
    goto :eof
)
if exist "%HERMES_HOME%\hermes-agent\venv\Scripts\hermes.exe" (
    "%HERMES_HOME%\hermes-agent\venv\Scripts\hermes.exe"
    goto :eof
)
if exist "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe" (
    "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe"
    goto :eof
)

echo No se encontro hermes.exe.
echo Buscado en:
echo   %HERMES_HOME%\bin\hermes.exe
echo   %HERMES_HOME%\hermes-agent\venv\Scripts\hermes.exe
pause
exit /b 1
