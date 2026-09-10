@echo off
setlocal
cd /d "%~dp0"
echo.
echo ============================================
echo  LlamaCCP  -  RTX 3070 Laptop 8GB
echo ============================================
echo.
echo  1^) Qwen3.6-35B-A3B     UD-IQ1_M
echo  2^) Qwen3.8-27B         UD-IQ2_XXS
echo  3^) Qwen3-Next-80B-A3B  UD-TQ1_0
echo  4^) Qwen3-8B            UD-IQ1_M [Q3]
echo.
set /p CHOICE=Elegi modelo [1-4]: 
if "%CHOICE%"=="1" call "%~dp0_start.bat" 3070-qwen36 & goto :eof
if "%CHOICE%"=="2" call "%~dp0_start.bat" 3070-qwen38 & goto :eof
if "%CHOICE%"=="3" call "%~dp0_start.bat" 3070-next & goto :eof
if "%CHOICE%"=="4" call "%~dp0_start.bat" 3070-qwen3 & goto :eof
echo Opcion invalida.
pause
