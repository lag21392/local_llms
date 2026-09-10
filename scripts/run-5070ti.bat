@echo off
setlocal
cd /d "%~dp0"
echo.
echo ============================================
echo  LlamaCCP  -  RTX 5070 Ti 16GB
echo ============================================
echo.
echo  1^) Qwen3.6-35B-A3B     UD-IQ3_XXS
echo  2^) Qwen3.8-27B         UD-IQ4_XS
echo  3^) Qwen3-Next-80B-A3B  UD-TQ1_0
echo  4^) Qwen3-8B            UD-IQ1_M [Q3]
echo.
set /p CHOICE=Elegi modelo [1-4]: 
if "%CHOICE%"=="1" call "%~dp0_start.bat" 5070ti-qwen36 & goto :eof
if "%CHOICE%"=="2" call "%~dp0_start.bat" 5070ti-qwen38 & goto :eof
if "%CHOICE%"=="3" call "%~dp0_start.bat" 5070ti-next & goto :eof
if "%CHOICE%"=="4" call "%~dp0_start.bat" 5070ti-qwen3 & goto :eof
echo Opcion invalida.
pause
