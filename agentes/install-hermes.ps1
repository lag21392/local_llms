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
$cfg = Get-Content (Join-Path $root "scripts\config.cmd") -Raw
$baseUrl = "https://correct-ibex-charmed.ngrok-free.app/v1"
$apiKey = "any"
$modelName = "local"
$ctx = 65536
if ($cfg -match 'set "HERMES_BASE_URL=([^"]+)"') { $baseUrl = $Matches[1] }
if ($cfg -match 'set "API_KEY=([^"]+)"') { $apiKey = $Matches[1] }
if ($cfg -match 'set "HERMES_MODEL=([^"]+)"') { $modelName = $Matches[1] }
if ($cfg -match 'set "HERMES_MIN_CTX=([^"]+)"') { $ctx = [int]$Matches[1] }

& (Join-Path $root "scripts\_write-runtime-config.ps1") `
    -Ctx $ctx `
    -HermesHome $HomeDir `
    -BaseUrl $baseUrl `
    -ModelName $modelName `
    -ApiKey $apiKey

Write-Host ""
Write-Host "Hermes listo. Arranque: agentes\run-hermes.bat"
