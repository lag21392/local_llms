@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."
set "ROOT=%CD%"
call "%ROOT%\scripts\config.cmd"

echo.
echo ============================================
echo  LlamaCCP Standalone - RTX 3070 8GB
echo ============================================
echo.
echo  1^) Qwen3.6-35B-A3B     UD-IQ1_M    [Optimizado]
echo  2^) Qwen3.6-35B-A3B     IQ2_S       [Alternativo]
echo  3^) Qwen3.8-27B         UD-IQ2_XXS  [Encaja en 8GB]
echo  4^) Qwen3-8B            UD-IQ1_M    [64K Contexto]
echo  5^) Bonsai 2 27B        PTQ1_0      [Prism, Optimizado]
echo.
set /p CHOICE=Elegi modelo [1-5]:
if "%CHOICE%"=="1" call "%~dp0_start-standalone.bat" 3070-qwen36 & goto :eof
if "%CHOICE%"=="2" call "%~dp0_start-standalone.bat" 3070-qwen36-iq2 & goto :eof
if "%CHOICE%"=="3" call "%~dp0_start-standalone.bat" 3070-qwen38 & goto :eof
if "%CHOICE%"=="4" call "%~dp0_start-standalone.bat" 3070-qwen3 & goto :eof
if "%CHOICE%"=="5" call "%~dp0_start-standalone.bat" 3070-bonsai & goto :eof
echo Opcion invalida.
pause