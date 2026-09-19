#!/usr/bin/env bash
# Arranca llama-server standalone (sin LiteLLM/ngrok/Hermes) para un perfil.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=config.sh
source "$ROOT/scripts/config.sh"

PROFILE="${1:-}"
if [[ -z "$PROFILE" ]]; then
  echo "Uso: _start-standalone.sh 3070-qwen36 | 3070-qwen36-iq2 | 3070-qwen38 | 3070-qwen3 | 3070-bonsai"
  exit 1
fi

TITLE=""
MODEL=""
CTX=65536
FIT_TARGET=""
FIT_CTX=""
BATCH=""
UBATCH=""
TEMP=""
TOPP=""
PEN=""
REASON=""
EXTRA=""
GPU_LABEL=""
LLAMA_BIN_OVERRIDE=""
CTK="q4_0"
CTV="q4_0"
NGL=""

case "$PROFILE" in
  3070-qwen36)
    TITLE="Qwen3.6-35B UD-IQ1_M [3070-OPT]"
    MODEL="$MODEL_QWEN36_IQ1M"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=1536; UBATCH=384
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=auto
    EXTRA="--n-cpu-moe 999"
    GPU_LABEL="RTX 3070 8GB"
    ;;
  3070-qwen36-iq2)
    TITLE="Qwen3.6-35B IQ2_S [3070-ALT]"
    MODEL="$MODEL_QWEN36_IQ2"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=1536; UBATCH=384
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=auto
    EXTRA="--n-cpu-moe 999"
    GPU_LABEL="RTX 3070 8GB"
    ;;
  3070-qwen38)
    TITLE="Qwen3.8-27B UD-IQ2_XXS [3070-OPT]"
    MODEL="$MODEL_QWEN38_IQ2XXS"
    FIT_TARGET=350; FIT_CTX=4096; BATCH=1024; UBATCH=256
    TEMP=1.0; TOPP=0.95; PEN=0.0; REASON=on
    EXTRA="--no-mmproj"
    GPU_LABEL="RTX 3070 8GB"
    ;;
  3070-qwen3)
    TITLE="Qwen3-8B UD-IQ1_M [3070-64K]"
    MODEL="$MODEL_QWEN3_IQ1M"
    FIT_TARGET=300; FIT_CTX=65536; BATCH=1024; UBATCH=256
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=auto
    EXTRA=""
    GPU_LABEL="RTX 3070 8GB"
    ;;
  3070-bonsai)
    TITLE="Bonsai 2 27B PTQ1_0 [3070-OPT]"
    MODEL="$MODEL_BONSAI2_PTQ1"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=2048; UBATCH=512
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=on
    EXTRA="--no-mmproj"
    GPU_LABEL="RTX 3070 8GB"
    LLAMA_BIN_OVERRIDE="$ROOT/llamacpp-prism/llama-server"
    CTK="q4_0"
    CTV="q4_0"
    NGL=99
    ;;
  *)
    echo "Perfil desconocido: $PROFILE"
    exit 1
    ;;
esac

if [[ -z "$CTX" ]]; then
  echo "FATAL: CTX vacio para el perfil $PROFILE. Revisa scripts/config.sh"
  exit 1
fi
if (( CTX < 65536 )); then
  echo "FATAL: CTX=$CTX es menor que minimo 65536"
  exit 1
fi

if [[ "${2:-}" == "dry-run" ]]; then
  echo "DRY-RUN profile=$PROFILE"
  echo "TITLE=$TITLE"
  echo "MODEL=$MODEL"
  echo "CTX=$CTX"
  echo "EXTRA=$EXTRA"
  if [[ -f "$MODEL" ]]; then echo "MODEL_OK"; else echo "MODEL_MISSING"; fi
  exit 0
fi

if [[ ! -f "$MODEL" ]]; then
  echo
  echo "FATAL: no esta el modelo:"
  echo "  $MODEL"
  echo "Corre:  scripts/download-unsloth-models.sh"
  echo "   o:  powershell -File scripts/download-bonsai.ps1"
  exit 1
fi

LLAMA_BIN=""
if [[ -n "$LLAMA_BIN_OVERRIDE" ]]; then
  if [[ -x "$LLAMA_BIN_OVERRIDE" ]]; then
    LLAMA_BIN="$LLAMA_BIN_OVERRIDE"
  else
    echo "FATAL: no esta llama-server:"
    echo "  $LLAMA_BIN_OVERRIDE"
    echo "Si es Bonsai 2, corre:  powershell -File scripts/download-bonsai.ps1"
    exit 1
  fi
elif [[ -x "$ROOT/llamacpp-cuda13/llama-server" ]]; then
  LLAMA_BIN="$ROOT/llamacpp-cuda13/llama-server"
elif command -v llama-server >/dev/null 2>&1; then
  LLAMA_BIN="$(command -v llama-server)"
else
  echo "FATAL: no se encontro llama-server"
  echo "Buscado en:"
  echo "  $ROOT/llamacpp-cuda13/llama-server"
  echo "  PATH (llama-server)"
  exit 1
fi

mkdir -p "$ROOT/logs"

echo
echo "============================================"
echo " $TITLE"
echo " CTX=$CTX"
echo "============================================"
echo

BACKEND_MODEL="$(basename "$MODEL")"

OFFLOAD_ARGS=(--fit on --fit-ctx "$FIT_CTX" --fit-target "$FIT_TARGET")
if [[ -n "$NGL" ]]; then
  OFFLOAD_ARGS=(-ngl "$NGL")
fi
echo "[1/1] Iniciando llama-server en puerto $LLAMA_PORT..."
echo "  $GPU_LABEL  |  ${OFFLOAD_ARGS[*]}  |  --parallel 1  |  ctx $CTX  |  KV $CTK  |  --jinja"
echo

# EXTRA se parte en argumentos si no esta vacio
# shellcheck disable=SC2086
"$LLAMA_BIN" \
  -m "$MODEL" \
  --host "$LLAMA_HOST" --port "$LLAMA_PORT" \
  --main-gpu 0 --split-mode none \
  "${OFFLOAD_ARGS[@]}" \
  --parallel 1 --cache-ram 0 --no-host \
  -c "$CTX" -fa on \
  -ctk "$CTK" -ctv "$CTV" \
  -b "$BATCH" -ub "$UBATCH" -t 8 -tb 8 \
  --temp "$TEMP" --top-p "$TOPP" --top-k 20 --min-p 0.0 --presence-penalty "$PEN" \
  --reasoning "$REASON" --jinja \
  --no-webui --no-context-shift $EXTRA \
  > "$ROOT/logs/llama-server.log" 2>&1 &
LLAMA_PID=$!

cleanup() {
  echo
  echo "Cerrando servidor..."
  [[ -n "$LLAMA_PID" ]] && kill "$LLAMA_PID" 2>/dev/null || true
  pkill -f "[l]lama-server" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "Esperando que el modelo cargue (puede tardar 15-90 segundos)..."
READY=0
for WAIT in $(seq 1 40); do
  if ! kill -0 "$LLAMA_PID" 2>/dev/null && (( WAIT >= 3 )); then
    echo "FATAL: llama-server no arranco. Mira logs/llama-server.log"
    exit 1
  fi
  if curl -fsS --max-time 2 "http://${LLAMA_HOST}:${LLAMA_PORT}/health" >/dev/null 2>&1; then
    READY=1
    break
  fi
  echo "  Aun cargando... ($WAIT/40)"
  sleep 2
done
if [[ "$READY" -ne 1 ]]; then
  echo "FATAL: timeout esperando llama-server en puerto $LLAMA_PORT"
  exit 1
fi
echo "  Modelo listo!"
echo

LOCAL_IP=$(hostname -I | awk '{print $1}')

echo
echo "============================================"
echo " $TITLE"
echo " Modelo     -> http://$LLAMA_HOST:$LLAMA_PORT/v1"
echo " Chat UI    -> http://$LLAMA_HOST:$LLAMA_PORT   (abrir en navegador)"
echo " API Docs   -> http://$LLAMA_HOST:$LLAMA_PORT/docs"
echo " Health     -> http://$LLAMA_HOST:$LLAMA_PORT/health"
echo " CTX        -> $CTX"
echo "============================================"
echo
echo "ENDPOINTS PARA APPS:"
echo "  OpenAI Compatible:  http://$LLAMA_HOST:$LLAMA_PORT/v1"
echo "  Model:              local"
echo "  API Key:            (ninguna requerida)"
echo
echo "Para conectar desde otra app (OpenWebUI, LibreChat, etc.) en LAN:"
echo "  Base URL: http://$LOCAL_IP:$LLAMA_PORT/v1"
echo "  Model:    local"
echo
echo "Presiona Enter para detener el servidor."
read -r _