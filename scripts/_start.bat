@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."
set "ROOT=%CD%"
call "%ROOT%\scripts\config.cmd"

set "PROFILE=%~1"
if "%PROFILE%"=="" (
    echo Uso: _start.bat 3070-qwen36 ^| 3070-qwen38 ^| 3070-next ^| 3070-qwen3 ^| 5070ti-qwen36 ^| 5070ti-qwen38 ^| 5070ti-next ^| 5070ti-qwen3
    exit /b 1
)

if /i "%PROFILE%"=="3070-qwen36" (
    set "TITLE=Qwen3.6-35B UD-IQ1_M [3070]"
    set "MODEL=%MODEL_QWEN36_IQ1M%"
    set "CTX=%CTX_3070_QWEN36%"
    set "FIT_TARGET=500"
    set "FIT_CTX=4096"
    set "BATCH=1024"
    set "UBATCH=256"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=auto"
    set "EXTRA=--n-cpu-moe 999"
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="3070-qwen38" (
    set "TITLE=Qwen3.8-27B UD-IQ2_XXS [3070]"
    set "MODEL=%MODEL_QWEN38_IQ2%"
    set "CTX=%CTX_3070_QWEN38%"
    set "FIT_TARGET=500"
    set "FIT_CTX=4096"
    set "BATCH=2048"
    set "UBATCH=512"
    set "TEMP=1.0"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=on"
    set "EXTRA=--no-mmproj"
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="3070-next" (
    set "TITLE=Qwen3-Next-80B UD-TQ1_0 [3070]"
    set "MODEL=%MODEL_NEXT_TQ1%"
    set "CTX=%CTX_3070_NEXT%"
    set "FIT_TARGET=500"
    set "FIT_CTX=4096"
    set "BATCH=512"
    set "UBATCH=256"
    set "TEMP=0.7"
    set "TOPP=0.80"
    set "PEN=1.5"
    set "REASON=auto"
    set "EXTRA="
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="3070-qwen3" (
    set "TITLE=Qwen3-8B UD-IQ1_M [3070 Q3]"
    set "MODEL=%MODEL_QWEN3_IQ1%"
    set "CTX=%CTX_3070_QWEN3%"
    set "FIT_TARGET=500"
    set "FIT_CTX=4096"
    set "BATCH=1024"
    set "UBATCH=256"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=auto"
    set "EXTRA="
    set "GPU_LABEL=RTX 3070 8GB"
) else if /i "%PROFILE%"=="5070ti-qwen36" (
    set "TITLE=Qwen3.6-35B UD-IQ3_XXS [5070 Ti]"
    set "MODEL=%MODEL_QWEN36_IQ3%"
    set "CTX=%CTX_5070TI_QWEN36%"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=2048"
    set "UBATCH=1024"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=auto"
    set "EXTRA="
    set "GPU_LABEL=RTX 5070 Ti 16GB"
) else if /i "%PROFILE%"=="5070ti-qwen38" (
    set "TITLE=Qwen3.8-27B UD-IQ4_XS [5070 Ti]"
    set "MODEL=%MODEL_QWEN38_IQ4%"
    set "CTX=%CTX_5070TI_QWEN38%"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=2048"
    set "UBATCH=1024"
    set "TEMP=1.0"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=on"
    set "EXTRA=--no-mmproj"
    set "GPU_LABEL=RTX 5070 Ti 16GB"
) else if /i "%PROFILE%"=="5070ti-next" (
    set "TITLE=Qwen3-Next-80B UD-TQ1_0 [5070 Ti]"
    set "MODEL=%MODEL_NEXT_TQ1%"
    set "CTX=%CTX_5070TI_NEXT%"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=1024"
    set "UBATCH=512"
    set "TEMP=0.7"
    set "TOPP=0.80"
    set "PEN=1.5"
    set "REASON=auto"
    set "EXTRA="
    set "GPU_LABEL=RTX 5070 Ti 16GB"
) else if /i "%PROFILE%"=="5070ti-qwen3" (
    set "TITLE=Qwen3-8B UD-IQ1_M [5070 Ti Q3]"
    set "MODEL=%MODEL_QWEN3_IQ1%"
    set "CTX=%CTX_5070TI_QWEN3%"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=2048"
    set "UBATCH=1024"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=auto"
    set "EXTRA="
    set "GPU_LABEL=RTX 5070 Ti 16GB"
) else (
    echo Perfil desconocido: %PROFILE%
    exit /b 1
)

if "!CTX!"=="" (
    echo FATAL: CTX vacio para el perfil %PROFILE%. Revisa scripts\config.cmd
    exit /b 1
)
if !CTX! LSS %HERMES_MIN_CTX% (
    echo FATAL: CTX=!CTX! es menor que Hermes min %HERMES_MIN_CTX%
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
    pause
    exit /b 1
)

echo.
echo ============================================
echo  !TITLE!
echo  CTX=!CTX! ^(Hermes min %HERMES_MIN_CTX%^)
echo  LiteLLM -^> %HERMES_BASE_URL%
echo ============================================
echo.

for %%F in ("!MODEL!") do set "BACKEND_MODEL=%%~nxF"
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\_write-runtime-config.ps1" -Ctx !CTX! -HermesHome "%HERMES_HOME%" -BaseUrl "%HERMES_BASE_URL%" -ModelName "%HERMES_MODEL%" -BackendModel "!BACKEND_MODEL!" -ApiKey "%API_KEY%"
if errorlevel 1 (
    echo FATAL: no se pudo escribir litellm/hermes config
    pause
    exit /b 1
)

2>nul netsh advfirewall firewall show rule name="LlamaCPP 7777" || (
    echo [!] Abriendo puerto 7777 en el firewall...
    netsh advfirewall firewall add rule name="LlamaCPP 7777" dir=in action=allow protocol=TCP localport=7777 profile=any >nul 2>nul
)

echo [1/3] Iniciando llama-server en puerto %LLAMA_PORT%...
echo   !GPU_LABEL!  ^|  --fit  ^|  --parallel 1  ^|  ctx !CTX!  ^|  KV q4_0  ^|  --jinja
echo.

start /b "" "%ROOT%\llamacpp-cuda13\llama-server.exe" ^
  -m "!MODEL!" ^
  --host %LLAMA_HOST% --port %LLAMA_PORT% ^
  --main-gpu 0 --split-mode none ^
  --fit on --fit-ctx !FIT_CTX! --fit-target !FIT_TARGET! ^
  --parallel 1 --cache-ram 0 ^
  -c !CTX! -fa on ^
  -ctk q4_0 -ctv q4_0 ^
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
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "try { $r = Invoke-WebRequest http://%LLAMA_HOST%:%LLAMA_PORT%/health -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if errorlevel 1 (
    echo   Aun cargando... ^(!WAIT!/40^)
    goto waitloop
)
echo   Modelo listo!
echo.

echo [2/3] Iniciando proxy LiteLLM en puerto %LITELLM_PORT%...
set PYTHONIOENCODING=utf-8
start /b "" cmd /c ""%ROOT%\.venv\Scripts\litellm.exe" --port %LITELLM_PORT% --config "%ROOT%\scripts\litellm-config.yaml" >nul 2>&1"

%SystemRoot%\System32\ping -n 5 127.0.0.1 >nul 2>nul

echo [3/3] Iniciando tunel ngrok...
start /b "" cmd /c ""%ROOT%\ngrok\ngrok.exe" http --url=%NGROK_URL% %LITELLM_PORT% >nul 2>&1"

echo.
echo ============================================
echo  !TITLE!
echo  Modelo   -^> http://%LLAMA_HOST%:%LLAMA_PORT%
echo  LiteLLM  -^> http://%LLAMA_HOST%:%LITELLM_PORT%   ^(Hermes usa este^)
echo  ngrok    -^> https://%NGROK_URL%
echo  CTX      -^> !CTX!
echo ============================================
echo.
echo Hermes:  agentes\run-hermes.bat
echo.
echo Presiona una tecla para detener todos los servicios.
pause >nul 2>nul

echo Cerrando servicios...
2>nul taskkill /IM litellm.exe /F
2>nul taskkill /IM ngrok.exe /F
2>nul taskkill /IM llama-server.exe /F
