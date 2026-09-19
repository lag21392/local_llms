@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."
set "ROOT=%CD%"
call "%ROOT%\scripts\config.cmd"

set "PROFILE=%~1"
if "%PROFILE%"=="" (
    echo Uso: _start-standalone.bat 3070-qwen36 ^| 3070-qwen36-iq2 ^| 3070-qwen38 ^| 3070-qwen3 ^| 3070-bonsai
    exit /b 1
)

if /i "%PROFILE%"=="3070-qwen36" (
    set "TITLE=Qwen3.6-35B UD-IQ1_M [3070-OPT]"
    set "MODEL=%MODEL_QWEN36_IQ1M%"
    set "CTX=65536"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=1536"
    set "UBATCH=384"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=auto"
    set "EXTRA=--n-cpu-moe 999"
    set "CTK=q4_0"
    set "CTV=q4_0"
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="3070-qwen36-iq2" (
    set "TITLE=Qwen3.6-35B IQ2_S [3070-ALT]"
    set "MODEL=%MODEL_QWEN36_IQ2%"
    set "CTX=65536"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=1536"
    set "UBATCH=384"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=auto"
    set "EXTRA=--n-cpu-moe 999"
    set "CTK=q4_0"
    set "CTV=q4_0"
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="3070-qwen38" (
    set "TITLE=Qwen3.8-27B UD-IQ2_XXS [3070-OPT]"
    set "MODEL=%MODEL_QWEN38_IQ2XXS%"
    set "CTX=65536"
    set "FIT_TARGET=350"
    set "FIT_CTX=4096"
    set "BATCH=1024"
    set "UBATCH=256"
    set "TEMP=1.0"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=on"
    set "EXTRA=--no-mmproj"
    set "CTK=q4_0"
    set "CTV=q4_0"
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="3070-qwen3" (
    set "TITLE=Qwen3-8B UD-IQ1_M [3070-64K]"
    set "MODEL=%MODEL_QWEN3_IQ1M%"
    set "CTX=65536"
    set "FIT_TARGET=300"
    set "FIT_CTX=65536"
    set "BATCH=1024"
    set "UBATCH=256"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=auto"
    set "EXTRA="
    set "CTK=q4_0"
    set "CTV=q4_0"
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="3070-bonsai" (
    set "TITLE=Bonsai 2 27B PTQ1_0 [3070-OPT]"
    set "MODEL=%MODEL_BONSAI2_PTQ1%"
    set "CTX=65536"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=2048"
    set "UBATCH=512"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=on"
    set "EXTRA=--no-mmproj"
    set "GPU_LABEL=RTX 3070 8GB"
    set "LLAMA_BIN=%ROOT%\llamacpp-prism\llama-server.exe"
    set "OFFLOAD=-ngl 99"
    set "CTK=q4_0"
    set "CTV=q4_0"
) else (
    echo Perfil desconocido: %PROFILE%
    exit /b 1
)

if not defined LLAMA_BIN set "LLAMA_BIN=%ROOT%\llamacpp-cuda13\llama-server.exe"
if not defined CTK set "CTK=q4_0"
if not defined CTV set "CTV=q4_0"
if not defined OFFLOAD set "OFFLOAD=--fit on --fit-ctx !FIT_CTX! --fit-target !FIT_TARGET!"

if "!CTX!"=="" (
    echo FATAL: CTX vacio para el perfil %PROFILE%. Revisa scripts\config.cmd
    exit /b 1
)
if !CTX! LSS 65536 (
    echo FATAL: CTX=!CTX! es menor que Hermes min 65536
    exit /b 1
)

if /i "%~2"=="dry-run" (
    echo DRY-RUN profile=%PROFILE%
    echo TITLE=!TITLE!
    echo MODEL=!MODEL!
    echo CTX=!CTX!
    echo EXTRA=!EXTRA!
    if exist "!MODEL!" (echo MODEL_OK) else (echo MODEL_MISSING)
    exit /b 0
)

if not exist "!MODEL!" (
    echo.
    echo FATAL: no esta el modelo:
    echo   !MODEL!
    echo Corre:  powershell -File scripts\download-unsloth-models.ps1
    echo    o:  powershell -File scripts\download-bonsai.ps1
    pause
    exit /b 1
)
if not exist "!LLAMA_BIN!" (
    echo.
    echo FATAL: no esta llama-server:
    echo   !LLAMA_BIN!
    echo Si es Bonsai 2, corre:  powershell -File scripts\download-bonsai.ps1
    pause
    exit /b 1
)

echo.
echo ============================================
echo  !TITLE!
echo  CTX=!CTX!
echo ============================================
echo.

for %%F in ("!MODEL!") do set "BACKEND_MODEL=%%~nxF"

2>nul netsh advfirewall firewall show rule name="LlamaCPP 7776" || (
    echo [!] Abriendo puerto 7776 en el firewall...
    netsh advfirewall firewall add rule name="LlamaCPP 7776" dir=in action=allow protocol=TCP localport=7776 profile=any >nul 2>nul
)

echo [1/1] Iniciando llama-server en puerto %LLAMA_PORT%...
echo   !GPU_LABEL!  ^|  !OFFLOAD!  ^|  --parallel 1  ^|  ctx !CTX!  ^|  KV !CTK!  ^|  --jinja
echo.

start /b "" "!LLAMA_BIN!" ^
  -m "!MODEL!" ^
  --host %LLAMA_HOST% --port %LLAMA_PORT% ^
  --main-gpu 0 --split-mode none ^
  !OFFLOAD! ^
  --parallel 1 --cache-ram 0 --no-host ^
  -c !CTX! -fa on ^
  -ctk !CTK! -ctv !CTV! ^
  -b !BATCH! -ub !UBATCH! -t 8 -tb 8 ^
  --temp !TEMP! --top-p !TOPP! --top-k 20 --min-p 0.0 --presence-penalty !PEN! ^
  --reasoning !REASON! --jinja ^
  --no-webui --no-context-shift !EXTRA!

echo Esperando que el modelo cargue (puede tardar 15-90 segundos)...

set "WAIT=0"
:waitloop
set /a WAIT+=1
if !WAIT! GTR 40 (
    echo FATAL: timeout esperando llama-server en puerto %LLAMA_PORT%
    2>nul taskkill /IM llama-server.exe /F
    pause
    exit /b 1
)
%SystemRoot%\System32\ping -n 3 127.0.0.1 >nul 2>nul
tasklist /FI "IMAGENAME eq llama-server.exe" | find /I "llama-server.exe" >nul
if errorlevel 1 (
    if !WAIT! GEQ 3 (
        echo FATAL: llama-server no arranco
        pause
        exit /b 1
    )
)
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "try { \$r = Invoke-WebRequest http://%LLAMA_HOST%:%LLAMA_PORT%/health -UseBasicParsing -TimeoutSec 2; if (\$r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if errorlevel 1 (
    echo   Aun cargando... ^(!WAIT!/40^)
    goto waitloop
)
echo   Modelo listo!
echo.

echo.
echo ============================================
echo  !TITLE!
echo  Modelo   -^> http://%LLAMA_HOST%:%LLAMA_PORT%/v1
echo  Chat UI  -^> http://%LLAMA_HOST%:%LLAMA_PORT%   (abrir en navegador)
echo  API Docs -^> http://%LLAMA_HOST%:%LLAMA_PORT%/docs
echo  Health   -^> http://%LLAMA_HOST%:%LLAMA_PORT%/health
echo  CTX      -^> !CTX!
echo ============================================
echo.
echo ENDPOINTS PARA APPS:
echo   OpenAI Compatible:  http://127.0.0.1:7776/v1
echo   Model:              local
echo   API Key:            (ninguna requerida)
echo.
echo Para conectar desde otra app (OpenWebUI, LibreChat, etc.):
echo   Base URL: http://TU_IP_LOCAL:7776/v1
echo   Model:    local
echo.
echo Presiona una tecla para detener el servidor.
pause >nul 2>nul

echo Cerrando servidor...
2>nul taskkill /IM llama-server.exe /F