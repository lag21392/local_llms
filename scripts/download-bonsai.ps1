# Descarga Bonsai 2 27B (PTQ1_0) y el fork PrismML de llama.cpp (CUDA 13).
# El llama.cpp estandar no carga PTQ1_0 / PQ2_0.
# Uso:  powershell -File scripts\download-bonsai.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent
$Tmp = Join-Path $Root "tmp"
$ModelsDir = Join-Path $Root "models\Ternary-Bonsai-2-27B"
$BinDir = Join-Path $Root "llamacpp-prism"
New-Item -ItemType Directory -Force -Path $Tmp, $ModelsDir, $BinDir | Out-Null

$Release = "prism-b10685-7dffb15"
$Gguf = "Ternary-Bonsai-2-27B-PTQ1_0.gguf"
$GgufUrl = "https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf/resolve/main/$Gguf"
$BinZip = "llama-$Release-bin-win-cuda-13.3-x64.zip"
$CudartZip = "cudart-llama-bin-win-cuda-13.3-x64.zip"
$BinUrl = "https://github.com/PrismML-Eng/llama.cpp/releases/download/$Release/$BinZip"
$CudartUrl = "https://github.com/PrismML-Eng/llama.cpp/releases/download/$Release/$CudartZip"

function Get-File([string]$Url, [string]$OutFile) {
    Write-Host "  $Url" -ForegroundColor Gray
    & curl.exe -L --fail --retry 5 --retry-all-errors -C - --progress-bar -o $OutFile $Url
    if ($LASTEXITCODE -ne 0) { throw "Fallo la descarga: $Url (exit $LASTEXITCODE)" }
}

Write-Host ""
Write-Host "==== Fork PrismML llama.cpp CUDA 13 ($Release) ====" -ForegroundColor Cyan
$binZipPath = Join-Path $Tmp $BinZip
$cudartZipPath = Join-Path $Tmp $CudartZip
$server = Join-Path $BinDir "llama-server.exe"
if (Test-Path $server) {
    Write-Host "  Ya esta llama-server.exe en llamacpp-prism. Saltando binarios." -ForegroundColor Green
} else {
    Get-File $BinUrl $binZipPath
    Get-File $CudartUrl $cudartZipPath
    Write-Host "  Descomprimiendo en llamacpp-prism ..." -ForegroundColor Yellow
    Expand-Archive -LiteralPath $binZipPath -DestinationPath $BinDir -Force
    Expand-Archive -LiteralPath $cudartZipPath -DestinationPath $BinDir -Force
    $nested = Get-ChildItem $BinDir -Recurse -Filter "llama-server.exe" | Select-Object -First 1
    if (-not $nested) { throw "No aparecio llama-server.exe en el zip de Prism" }
    if ($nested.DirectoryName -ne $BinDir) {
        Get-ChildItem $nested.DirectoryName -File | ForEach-Object {
            Copy-Item $_.FullName -Destination $BinDir -Force
        }
    }
    if (-not (Test-Path $server)) { throw "No quedo llama-server.exe en $BinDir" }
    Write-Host "  Binarios listos: $server" -ForegroundColor Green
}

Write-Host ""
Write-Host "==== Modelo Ternary-Bonsai-2-27B PTQ1_0 ====" -ForegroundColor Cyan
$ggufPath = Join-Path $ModelsDir $Gguf
if ((Test-Path $ggufPath) -and ((Get-Item $ggufPath).Length -gt 4GB)) {
    $gb = [math]::Round((Get-Item $ggufPath).Length / 1GB, 2)
    Write-Host "  Ya existe ($gb GB). Saltando." -ForegroundColor Green
} else {
    Get-File $GgufUrl $ggufPath
    $gb = [math]::Round((Get-Item $ggufPath).Length / 1GB, 2)
    Write-Host "  Descargado: $gb GB" -ForegroundColor Green
}

Write-Host ""
Write-Host "Listo. Arranque: scripts\run-5070ti.bat  (opcion Bonsai 2)" -ForegroundColor Cyan
