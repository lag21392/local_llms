# Instala Hermes Agent en agentes\hermes (HERMES_HOME del proyecto).
$ErrorActionPreference = "Stop"
$HomeDir = Join-Path $PSScriptRoot "hermes"
New-Item -ItemType Directory -Force -Path $HomeDir | Out-Null

$installer = Join-Path $env:TEMP "hermes-install.ps1"
Write-Host "Descargando instalador oficial..."
Invoke-WebRequest -Uri "https://hermes-agent.nousresearch.com/install.ps1" -OutFile $installer -UseBasicParsing

Write-Host "Instalando en $HomeDir ..."
& $installer -HermesHome $HomeDir -SkipSetup -NonInteractive
if ($LASTEXITCODE -ne 0) { throw "El instalador de Hermes fallo con codigo $LASTEXITCODE" }

$root = Split-Path $PSScriptRoot -Parent
& (Join-Path $root "scripts\_write-runtime-config.ps1") `
    -Ctx 65536 `
    -HermesHome $HomeDir `
    -BaseUrl "http://127.0.0.1:7777/v1" `
    -ModelName "local" `
    -ApiKey "any"

Write-Host ""
Write-Host "Hermes listo. Arranque: agentes\run-hermes.bat"
