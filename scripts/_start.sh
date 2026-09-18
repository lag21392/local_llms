#!/usr/bin/env bash
# Arranca llama-server + LiteLLM + ngrok para un perfil.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=config.sh
source "$ROOT/scripts/config.sh"

PROFILE="${1:-}"
if [[ -z "$PROFILE" ]]; then
  echo "Uso: _start.sh 3070-qwen36 | 3070-qwen38 | 3070-next | 3070-qwen3 | 5070ti-qwen36 | 5070ti-qwen38 | 5070ti-next | 5070ti-qwen3 | 5070ti-bonsai"
  exit 1
fi

TITLE=""
MODEL=""
CTX=""
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
    TITLE="Qwen3.6-35B UD-IQ1_M [3070]"
    MODEL="$MODEL_QWEN36_IQ1M"
    CTX="$CTX_3070_QWEN36"
    FIT_TARGET=500; FIT_CTX=4096; BATCH=1024; UBATCH=256
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=auto
    EXTRA="--n-cpu-moe 999"
    GPU_LABEL="RTX 3070 8GB"
    ;;
  3070-qwen38)
    TITLE="Qwen3.8-27B UD-Q4_K_XL [3070]"
    MODEL="$MODEL_QWEN38_Q4XL"
    CTX="$CTX_3070_QWEN38"
    FIT_TARGET=500; FIT_CTX=4096; BATCH=2048; UBATCH=512
    TEMP=1.0; TOPP=0.95; PEN=0.0; REASON=on
    EXTRA="--no-mmproj"
    GPU_LABEL="RTX 3070 8GB"
    ;;
  3070-next)
    TITLE="Qwen3-Next-80B UD-TQ1_0 [3070]"
    MODEL="$MODEL_NEXT_TQ1"
    CTX="$CTX_3070_NEXT"
    FIT_TARGET=500; FIT_CTX=4096; BATCH=512; UBATCH=256
    TEMP=0.7; TOPP=0.80; PEN=1.5; REASON=auto
    EXTRA=""
    GPU_LABEL="RTX 3070 8GB"
    ;;
  3070-qwen3)
    TITLE="Qwen3-8B UD-Q4_K_M [3070]"
    MODEL="$MODEL_QWEN3_Q4M"
    CTX="$CTX_3070_QWEN3"
    FIT_TARGET=500; FIT_CTX=4096; BATCH=1024; UBATCH=256
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=auto
    EXTRA=""
    GPU_LABEL="RTX 3070 8GB"
    ;;
  5070ti-qwen36)
    TITLE="Qwen3.6-35B UD-IQ3_XXS [5070 Ti]"
    MODEL="$MODEL_QWEN36_IQ3"
    CTX="$CTX_5070TI_QWEN36"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=2048; UBATCH=1024
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=auto
    EXTRA=""
    GPU_LABEL="RTX 5070 Ti 16GB"
    ;;
  5070ti-qwen38)
    TITLE="Qwen3.8-27B UD-Q4_K_M [5070 Ti]"
    MODEL="$MODEL_QWEN38_Q4M"
    CTX="$CTX_5070TI_QWEN38"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=2048; UBATCH=1024
    TEMP=1.0; TOPP=0.95; PEN=0.0; REASON=on
    EXTRA="--no-mmproj"
    GPU_LABEL="RTX 5070 Ti 16GB"
    ;;
  5070ti-next)
    TITLE="Qwen3-Next-80B UD-TQ1_0 [5070 Ti]"
    MODEL="$MODEL_NEXT_TQ1"
    CTX="$CTX_5070TI_NEXT"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=1024; UBATCH=512
    TEMP=0.7; TOPP=0.80; PEN=1.5; REASON=auto
    EXTRA=""
    GPU_LABEL="RTX 5070 Ti 16GB"
    ;;
  5070ti-qwen3)
    TITLE="Qwen3-8B UD-Q4_K_M [5070 Ti]"
    MODEL="$MODEL_QWEN3_Q4M"
    CTX="$CTX_5070TI_QWEN3"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=2048; UBATCH=1024
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=auto
    EXTRA=""
    GPU_LABEL="RTX 5070 Ti 16GB"
    ;;
  5070ti-bonsai)
    TITLE="Bonsai 2 27B PTQ1_0 [5070 Ti]"
    MODEL="$MODEL_BONSAI2_PTQ1"
    CTX="$CTX_5070TI_BONSAI"
    FIT_TARGET=400; FIT_CTX=8192; BATCH=4096; UBATCH=2048
    TEMP=0.6; TOPP=0.95; PEN=0.0; REASON=on
    EXTRA="--no-mmproj"
    GPU_LABEL="RTX 5070 Ti 16GB"
    LLAMA_BIN_OVERRIDE="$ROOT/llamacpp-prism/llama-server"
    CTK="f16"
    CTV="f16"
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
if (( CTX < HERMES_MIN_CTX )); then
  echo "FATAL: CTX=$CTX es menor que Hermes min $HERMES_MIN_CTX"
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

LITELLM_BIN=""
if [[ -x "$ROOT/.venv/bin/litellm" ]]; then
  LITELLM_BIN="$ROOT/.venv/bin/litellm"
elif command -v litellm >/dev/null 2>&1; then
  LITELLM_BIN="$(command -v litellm)"
else
  echo "FATAL: no se encontro litellm. Crea el venv: python3 -m venv .venv && .venv/bin/pip install -r requirements.txt"
  exit 1
fi

NGROK_EXE=""
if [[ -x "$ROOT/ngrok/ngrok" ]]; then
  NGROK_EXE="$ROOT/ngrok/ngrok"
elif command -v ngrok >/dev/null 2>&1; then
  NGROK_EXE="$(command -v ngrok)"
else
  echo "FATAL: no se encontro ngrok"
  echo "Buscado en:"
  echo "  $ROOT/ngrok/ngrok"
  echo "  PATH (ngrok)"
  echo "Instala ngrok, autenticalo (ngrok config add-authtoken) y reserva el dominio $NGROK_URL"
  exit 1
fi

echo
echo "============================================"
echo " $TITLE"
echo " CTX=$CTX (Hermes min $HERMES_MIN_CTX)"
echo " LiteLLM -> $HERMES_BASE_URL"
echo "============================================"
echo

BACKEND_MODEL="$(basename "$MODEL")"
"$ROOT/scripts/_write-runtime-config.sh" \
  --ctx "$CTX" \
  --hermes-home "$HERMES_HOME" \
  --base-url "$HERMES_BASE_URL" \
  --model "$HERMES_MODEL" \
  --backend-model "$BACKEND_MODEL" \
  --api-key "$API_KEY"

LLAMA_PID=""
LITELLM_PID=""
NGROK_PID=""

cleanup() {
  echo
  echo "Cerrando servicios..."
  [[ -n "$LITELLM_PID" ]] && kill "$LITELLM_PID" 2>/dev/null || true
  [[ -n "$NGROK_PID" ]] && kill "$NGROK_PID" 2>/dev/null || true
  [[ -n "$LLAMA_PID" ]] && kill "$LLAMA_PID" 2>/dev/null || true
  pkill -f "[l]lama-server" 2>/dev/null || true
  pkill -f "[n]grok http" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

mkdir -p "$ROOT/logs"

echo "[1/3] Iniciando llama-server en puerto $LLAMA_PORT..."
OFFLOAD_ARGS=(--fit on --fit-ctx "$FIT_CTX" --fit-target "$FIT_TARGET")
if [[ -n "$NGL" ]]; then
  OFFLOAD_ARGS=(-ngl "$NGL")
fi
echo "  $GPU_LABEL  |  ${OFFLOAD_ARGS[*]}  |  --parallel 1  |  ctx $CTX  |  KV $CTK  |  --jinja"
echo

# EXTRA se parte en argumentos si no esta vacio
# shellcheck disable=SC2086
"$LLAMA_BIN" \
  -m "$MODEL" \
  --host "$LLAMA_HOST" --port "$LLAMA_PORT" \
  --main-gpu 0 --split-mode none \
  "${OFFLOAD_ARGS[@]}" \
  --parallel 1 --cache-ram 0 --no-host --load-mode none \
  -c "$CTX" -fa on \
  -ctk "$CTK" -ctv "$CTV" \
  -b "$BATCH" -ub "$UBATCH" -t 8 -tb 8 \
  --temp "$TEMP" --top-p "$TOPP" --top-k 20 --min-p 0.0 --presence-penalty "$PEN" \
  --reasoning "$REASON" --jinja \
  --no-webui --no-context-shift $EXTRA \
  > "$ROOT/logs/llama-server.log" 2>&1 &
LLAMA_PID=$!

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

echo "[2/3] Iniciando proxy LiteLLM en puerto $LITELLM_PORT..."
export PYTHONIOENCODING=utf-8
"$LITELLM_BIN" --host 127.0.0.1 --port "$LITELLM_PORT" --config "$ROOT/scripts/litellm-config.yaml" \
  > "$ROOT/logs/litellm.log" 2>&1 &
LITELLM_PID=$!

READY=0
for WAIT in $(seq 1 20); do
  if curl -fsS --max-time 2 -H "Authorization: Bearer $API_KEY" \
      "http://127.0.0.1:${LITELLM_PORT}/v1/models" >/dev/null 2>&1; then
    READY=1
    break
  fi
  echo "  LiteLLM aun no responde... ($WAIT/20)"
  sleep 2
done
if [[ "$READY" -ne 1 ]]; then
  echo "FATAL: timeout esperando LiteLLM en puerto $LITELLM_PORT"
  exit 1
fi
echo "  LiteLLM listo!"
echo

echo "[3/3] Iniciando tunel ngrok https://$NGROK_URL ..."
pkill -f "[n]grok http" 2>/dev/null || true
sleep 1
"$NGROK_EXE" http --url="$NGROK_URL" "$LITELLM_PORT" \
  > "$ROOT/logs/ngrok.log" 2>&1 &
NGROK_PID=$!

READY=0
for WAIT in $(seq 1 15); do
  if curl -fsS --max-time 5 \
      -H "Authorization: Bearer $API_KEY" \
      -H "ngrok-skip-browser-warning: true" \
      "https://${NGROK_URL}/v1/models" >/dev/null 2>&1; then
    READY=1
    break
  fi
  echo "  Tunel aun no responde... ($WAIT/15)"
  sleep 2
done
if [[ "$READY" -ne 1 ]]; then
  echo "FATAL: ngrok no levanto el tunel https://$NGROK_URL"
  echo "Revisa logs/ngrok.log  (auth token, dominio reservado, otro ngrok abierto)"
  exit 1
fi
echo "  ngrok listo: https://$NGROK_URL/v1"
echo

echo
echo "============================================"
echo " $TITLE"
echo " Modelo   -> http://$LLAMA_HOST:$LLAMA_PORT/v1"
echo " LiteLLM  -> http://$LLAMA_HOST:$LITELLM_PORT/v1"
echo " Hermes   -> $HERMES_BASE_URL"
echo " CTX      -> $CTX"
echo "============================================"
echo
echo "En esta u otra maquina:  agentes/run-hermes.sh"
echo
echo "Presiona Enter para detener todos los servicios."
read -r _
