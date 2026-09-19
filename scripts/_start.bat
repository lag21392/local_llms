@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."
set "ROOT=%CD%"
call "%ROOT%\scripts\config.cmd"

set "PROFILE=%~1"
if "%PROFILE%"=="" (
    echo Uso: _start.bat 3070-qwen36 ^| 3070-qwen36-iq2 ^| 3070-qwen38 ^| 3070-qwen3 ^| 3070-bonsai ^| 5070ti-qwen36 ^| 5070ti-qwen38 ^| 5070ti-next ^| 5070ti-qwen3 ^| 5070ti-bonsai
    exit /b 1
)

if /i "%PROFILE%"=="3070-qwen36" (
    set "TITLE=Qwen3.6-35B UD-IQ1_M [3070-OPT]"
    set "MODEL=%MODEL_QWEN36_IQ1M%"
    set "CTX=%CTX_3070_QWEN36%"
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
    set "CTX=%CTX_3070_QWEN36%"
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
    set "CTX=%CTX_3070_QWEN38%"
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
    set "CTX=%CTX_3070_QWEN3%"
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
    set "TITLE=Bonsai 2 27B PTQ1_0 [3070]"
    set "MODEL=%MODEL_BONSAI2_PTQ1%"
    set "CTX=%CTX_3070_BONSAI%"
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
    set "TITLE=Qwen3.8-27B UD-Q4_K_M [5070 Ti]"
    set "MODEL=%MODEL_QWEN38_Q4M%"
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
    set "TITLE=Qwen3-8B UD-Q4_K_M [5070 Ti]"
    set "MODEL=%MODEL_QWEN3_Q4M%"
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
) else if /i "%PROFILE%"=="5070ti-bonsai" (
    set "TITLE=Bonsai 2 27B PTQ1_0 [5070 Ti]"
    set "MODEL=%MODEL_BONSAI2_PTQ1%"
    set "CTX=%CTX_5070TI_BONSAI%"
    set "FIT_TARGET=400"
    set "FIT_CTX=8192"
    set "BATCH=4096"
    set "UBATCH=2048"
    set "TEMP=0.6"
    set "TOPP=0.95"
    set "PEN=0.0"
    set "REASON=on"
    set "EXTRA=--no-mmproj"
    set "GPU_LABEL=RTX 5070 Ti 16GB"
    set "LLAMA_BIN=%ROOT%\llamacpp-prism\llama-server.exe"
    set "OFFLOAD=-ngl 99"
    set "CTK=f16"
    set "CTV=f16"
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
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "try { $r = Invoke-WebRequest http://%LLAMA_HOST%:%LLAMA_PORT%/health -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if errorlevel 1 (
    echo   Aun cargando... ^(!WAIT!/40^)
    goto waitloop
)
echo   Modelo listo!
echo.

echo [2/3] Iniciando proxy LiteLLM en puerto %LITELLM_PORT%...
set PYTHONIOENCODING=utf-8
start /b "" cmd /c ""%ROOT%\.venv\Scripts\litellm.exe" --host 127.0.0.1 --port %LITELLM_PORT% --config "%ROOT%\scripts\litellm-config.yaml" >nul 2>&1"

set "WAIT=0"
:waitlitellm
set /a WAIT+=1
if !WAIT! GTR 20 (
    echo FATAL: timeout esperando LiteLLM en puerto %LITELLM_PORT%
    2>nul taskkill /IM litellm.exe /F
    2>nul taskkill /IM llama-server.exe /F
    pause
    exit /b 1
)
%SystemRoot%\System32\ping -n 3 127.0.0.1 >nul 2>nul
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "try { $h=@{Authorization='Bearer %API_KEY%'}; $r=Invoke-WebRequest http://127.0.0.1:%LITELLM_PORT%/v1/models -Headers $h -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if errorlevel 1 (
    echo   LiteLLM aun no responde... ^(!WAIT!/20^)
    goto waitlitellm
)
echo   LiteLLM listo!
echo.

echo [3/3] Iniciando tunel ngrok https://%NGROK_URL% ...
set "NGROK_EXE="
if exist "%ROOT%\ngrok\ngrok.exe" set "NGROK_EXE=%ROOT%\ngrok\ngrok.exe"
if not defined NGROK_EXE if exist "%LOCALAPPDATA%\ngrok\ngrok.exe" set "NGROK_EXE=%LOCALAPPDATA%\ngrok\ngrok.exe"
if not defined NGROK_EXE (
    echo FATAL: no se encontro ngrok.exe
    echo Buscado en:
    echo   %ROOT%\ngrok\ngrok.exe
    echo   %LOCALAPPDATA%\ngrok\ngrok.exe
    echo Instala ngrok, autenticalo ^(ngrok config add-authtoken^) y reserva el dominio %NGROK_URL%
    2>nul taskkill /IM litellm.exe /F
    2>nul taskkill /IM llama-server.exe /F
    pause
    exit /b 1
)
if not exist "%ROOT%\logs" mkdir "%ROOT%\logs" >nul 2>nul
2>nul taskkill /IM ngrok.exe /F
%SystemRoot%\System32\ping -n 2 127.0.0.1 >nul 2>nul
start /b "" cmd /c ""!NGROK_EXE!" http --url=%NGROK_URL% %LITELLM_PORT% > "%ROOT%\logs\ngrok.log" 2>&1"

set "WAIT=0"
:waitngrok
set /a WAIT+=1
if !WAIT! GTR 15 (
    echo FATAL: ngrok no levanto el tunel https://%NGROK_URL%
    echo Revisa logs\ngrok.log  ^(auth token, dominio reservado, otro ngrok abierto^)
    2>nul taskkill /IM ngrok.exe /F
    2>nul taskkill /IM litellm.exe /F
    2>nul taskkill /IM llama-server.exe /F
    pause
    exit /b 1
)
%SystemRoot%\System32\ping -n 3 127.0.0.1 >nul 2>nul
tasklist /FI "IMAGENAME eq ngrok.exe" | find /I "ngrok.exe" >nul
if errorlevel 1 (
    echo   Esperando ngrok... ^(!WAIT!/15^)
    goto waitngrok
)
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "try { $h=@{Authorization='Bearer %API_KEY%'; 'ngrok-skip-browser-warning'='true'}; $r=Invoke-WebRequest https://%NGROK_URL%/v1/models -Headers $h -UseBasicParsing -TimeoutSec 5; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if errorlevel 1 (
    echo   Tunel aun no responde... ^(!WAIT!/15^)
    goto waitngrok
)
echo   ngrok listo: https://%NGROK_URL%/v1
echo.

echo.
echo ============================================
echo  !TITLE!
echo  Modelo   -^> http://%LLAMA_HOST%:%LLAMA_PORT%/v1
echo  LiteLLM  -^> http://%LLAMA_HOST%:%LITELLM_PORT%/v1
echo  Hermes   -^> %HERMES_BASE_URL%
echo  CTX      -^> !CTX!
echo ============================================
echo.
echo En esta u otra maquina:  agentes\run-hermes.bat
echo.
echo Presiona una tecla para detener todos los servicios.
pause >nul 2>nul

echo Cerrando servicios...
2>nul taskkill /IM litellm.exe /F
2>nul taskkill /IM ngrok.exe /F
2>nul taskkill /IM llama-server.exe /F
