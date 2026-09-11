#!/usr/bin/env bash
# Descarga los GGUF Unsloth Dynamic V3.0 para 3070 (8GB) y 5070 Ti (16GB).
# Si no estan, los baja automaticamente al iniciar.
# Uso:  scripts/download-unsloth-models.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

HF=""
if [[ -x "$ROOT/.venv/bin/hf" ]]; then
  HF="$ROOT/.venv/bin/hf"
elif command -v hf >/dev/null 2>&1; then
  HF="$(command -v hf)"
else
  echo "ERROR: no se encontro hf. Instala huggingface-hub o crea el venv:"
  echo "  python3 -m venv .venv && .venv/bin/pip install -r requirements.txt"
  exit 1
fi

download() {
  local repo="$1" file="$2" dest="$3" note="$4"
  local out="$dest/$file"
  echo
  echo "==== $note ===="
  echo "  Repo: $repo"
  echo "  File: $file"

  if [[ -f "$out" ]]; then
    local bytes size_gb
    bytes="$(stat -c %s "$out" 2>/dev/null || echo 0)"
    size_gb="$(python3 -c "print(round($bytes/1024**3, 2))")"
    if (( bytes > 1073741824 )); then
      echo "  Ya existe ($size_gb GB). Saltando."
      return 0
    fi
  fi

  mkdir -p "$dest"
  echo "  Descargando..."
  if ! "$HF" download "$repo" "$file" --local-dir "$dest"; then
    echo "  ERROR: fallo la descarga de $file"
    return 0
  fi
  if [[ ! -f "$out" ]]; then
    echo "  ERROR: no aparecio el archivo $file"
    return 0
  fi
  local bytes size_gb
  bytes="$(stat -c %s "$out")"
  size_gb="$(python3 -c "print(round($bytes/1024**3, 2))")"
  echo "  Descargado: $size_gb GB"
}

echo
echo "Descargando 6 modelos (Unsloth Dynamic V3.0)..."

download unsloth/Qwen3.6-35B-A3B-GGUF \
  Qwen3.6-35B-A3B-UD-IQ1_M.gguf \
  "$ROOT/models/Qwen3.6-35B-A3B" \
  "3.6 Unsloth Dynamic 2.0 - mejor para RTX 3070 8GB"

download unsloth/Qwen3.6-35B-A3B-GGUF \
  Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf \
  "$ROOT/models/Qwen3.6-35B-A3B" \
  "3.6 Unsloth Dynamic 2.0 - mejor para RTX 5070 Ti 16GB"

download unsloth/Qwen3.8-27B-GGUF \
  Qwen3.8-27B-UD-Q4_K_XL.gguf \
  "$ROOT/models/Qwen3.8-27B" \
  "3.8 Dynamic V3.0 Q4_K_XL - mejor para RTX 3070 8GB (~17-19 GB)"

download unsloth/Qwen3.8-27B-GGUF \
  Qwen3.8-27B-UD-Q4_K_M.gguf \
  "$ROOT/models/Qwen3.8-27B" \
  "3.8 Dynamic V3.0 Q4_K_M - mejor para RTX 5070 Ti 16GB (~24 GB)"

download unsloth/Qwen3-8B-GGUF \
  Qwen3-8B-UD-Q4_K_M.gguf \
  "$ROOT/models/Qwen3-8B" \
  "Qwen3-8B Dynamic V3.0 Q4_K_M - denso, ~5 GB"

download unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF \
  Qwen3-Next-80B-A3B-Instruct-UD-TQ1_0.gguf \
  "$ROOT/models/Qwen3-Next-80B-A3B-Instruct" \
  "Next superquantizado Unsloth UD-TQ1_0 (ternary 1-bit)"

echo
echo "Descargas listas."
if [[ -d "$ROOT/models" ]]; then
  find "$ROOT/models" -type f -name '*.gguf' -printf '%f\t%s\n' \
    | python3 -c '
import sys
print(f"{\"Name\":<50} {\"GB\":>8}")
for line in sys.stdin:
    name, size = line.rstrip("\n").split("\t")
    print(f"{name:<50} {int(size)/1024**3:8.2f}")
'
fi
