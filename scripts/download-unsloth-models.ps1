# Descarga los GGUF Unsloth Dynamic V3.0 para 3070 (8GB) y 5070 Ti (16GB).
# Si no estan, los baja automaticamente al iniciar.
# Requiere: c:\LlamaCCP\.venv\Scripts\hf.exe
# Uso:  powershell -File scripts\download-unsloth-models.ps1
#
# Modelos:
#   Qwen3.6-35B-A3B (IQ1_M: 3070, IQ3_XXS: 5070 Ti)
#   Qwen3.8-27B     (Q4_K_XL: 3070, Q4_K_M: 5070 Ti)
#   Qwen3-8B        (Q4_K_M: 3070/5070 Ti)
#   Qwen3-Next-80B-A3B-Instruct (UD-TQ1_0)

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent

$Hf = Join-Path $Root ".venv\Scripts\hf.exe"
if (-not (Test-Path $Hf)) {
    Write-Host "ERROR: No se encontro hf.exe en $Hf" -ForegroundColor Red
    exit 1
}

$Jobs = @(
    @{
        Repo  = "unsloth/Qwen3.6-35B-A3B-GGUF"
        File  = "Qwen3.6-35B-A3B-UD-IQ1_M.gguf"
        Dest  = Join-Path $Root "models\Qwen3.6-35B-A3B"
        Note  = "3.6 Unsloth Dynamic 2.0 - mejor para RTX 3070 8GB"
    },
    @{
        Repo  = "unsloth/Qwen3.6-35B-A3B-GGUF"
        File  = "Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf"
        Dest  = Join-Path $Root "models\Qwen3.6-35B-A3B"
        Note  = "3.6 Unsloth Dynamic 2.0 - mejor para RTX 5070 Ti 16GB"
    },
    @{
        Repo  = "unsloth/Qwen3.8-27B-GGUF"
        File  = "Qwen3.8-27B-UD-Q4_K_XL.gguf"
        Dest  = Join-Path $Root "models\Qwen3.8-27B"
        Note  = "3.8 Dynamic V3.0 Q4_K_XL - mejor para RTX 3070 8GB (~17-19 GB)"
    },
    @{
        Repo  = "unsloth/Qwen3.8-27B-GGUF"
        File  = "Qwen3.8-27B-UD-Q4_K_M.gguf"
        Dest  = Join-Path $Root "models\Qwen3.8-27B"
        Note  = "3.8 Dynamic V3.0 Q4_K_M - mejor para RTX 5070 Ti 16GB (~24 GB)"
    },
    @{
        Repo  = "unsloth/Qwen3-8B-GGUF"
        File  = "Qwen3-8B-UD-Q4_K_M.gguf"
        Dest  = Join-Path $Root "models\Qwen3-8B"
        Note  = "Qwen3-8B Dynamic V3.0 Q4_K_M - denso, ~5 GB"
    },
    @{
        Repo  = "unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF"
        File  = "Qwen3-Next-80B-A3B-Instruct-UD-TQ1_0.gguf"
        Dest  = Join-Path $Root "models\Qwen3-Next-80B-A3B-Instruct"
        Note  = "Next superquantizado Unsloth UD-TQ1_0 (ternary 1-bit)"
    }
)

Write-Host ""
Write-Host "Descargando $($Jobs.Count) modelos (Unsloth Dynamic V3.0)..." -ForegroundColor Cyan

foreach ($j in $Jobs) {
    $out = Join-Path $j.Dest $j.File
    Write-Host ""
    Write-Host "==== $($j.Note) ====" -ForegroundColor White
    Write-Host "  Repo: $($j.Repo)" -ForegroundColor Gray
    Write-Host "  File: $($j.File)" -ForegroundColor Gray

    if ((Test-Path $out) -and ((Get-Item $out).Length -gt 1GB)) {
        $gb = [math]::Round((Get-Item $out).Length / 1GB, 2)
        Write-Host "  Ya existe ($gb GB). Saltando." -ForegroundColor Green
        continue
    }

    New-Item -ItemType Directory -Force -Path $j.Dest | Out-Null

    Write-Host "  Descargando..." -ForegroundColor Yellow
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & $Hf download $j.Repo $j.File --local-dir $j.Dest
    $hfCode = $LASTEXITCODE
    $ErrorActionPreference = $prevEap
    if ($hfCode -ne 0) {
        Write-Host "  ERROR: Fallo la descarga de $($j.File) (exit $hfCode)" -ForegroundColor Red
        continue
    }

    if (-not (Test-Path $out)) {
        Write-Host "  ERROR: no aparecio el archivo $($j.File)" -ForegroundColor Red
        continue
    }

    $sz = [math]::Round((Get-Item $out).Length / 1GB, 2)
    Write-Host "  Descargado: $sz GB" -ForegroundColor Green
}

Write-Host ""
Write-Host "Descargas listas." -ForegroundColor Cyan
Get-ChildItem (Join-Path $Root "models") -Recurse -File -Filter *.gguf |
    Select-Object Name, @{N="GB";E={[math]::Round($_.Length/1GB,2)}} |
    Format-Table -AutoSize
