#!/usr/bin/env bash
# Escribe litellm-config.yaml y agentes/hermes/{config.yaml,.env}
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CTX=""
HERMES_HOME=""
BASE_URL="https://correct-ibex-charmed.ngrok-free.app/v1"
MODEL_NAME="local"
BACKEND_MODEL=""
API_KEY="any"
SKIP_LITELLM=0

usage() {
  echo "Uso: _write-runtime-config.sh --ctx N --hermes-home DIR [--base-url URL] [--model NAME] [--backend-model NAME] [--api-key KEY] [--skip-litellm]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ctx) CTX="$2"; shift 2 ;;
    --hermes-home) HERMES_HOME="$2"; shift 2 ;;
    --base-url) BASE_URL="$2"; shift 2 ;;
    --model) MODEL_NAME="$2"; shift 2 ;;
    --backend-model) BACKEND_MODEL="$2"; shift 2 ;;
    --api-key) API_KEY="$2"; shift 2 ;;
    --skip-litellm) SKIP_LITELLM=1; shift ;;
    -h|--help) usage ;;
    *) echo "Flag desconocida: $1"; usage ;;
  esac
done

if [[ -z "$CTX" || -z "$HERMES_HOME" ]]; then
  usage
fi

if [[ -z "$BACKEND_MODEL" ]]; then
  BACKEND_MODEL="$(
    curl -fsS --max-time 3 "http://127.0.0.1:7776/v1/models" 2>/dev/null \
      | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
    print((d.get("data") or [{}])[0].get("id") or "")
except Exception:
    print("")' 2>/dev/null || true
  )"
fi
if [[ -z "$BACKEND_MODEL" ]]; then
  BACKEND_MODEL="local"
fi

write_utf8() {
  python3 -c '
import sys
path = sys.argv[1]
text = sys.stdin.read()
with open(path, "w", encoding="utf-8", newline="\n") as f:
    f.write(text)
' "$1"
}

if [[ "$SKIP_LITELLM" -eq 0 ]]; then
  {
    echo "model_list:"
    cat <<EOF
  - model_name: ${MODEL_NAME}
    litellm_params:
      model: openai/${BACKEND_MODEL}
      api_base: http://127.0.0.1:7776/v1
      api_key: "${API_KEY}"
    model_info:
      max_input_tokens: ${CTX}
      max_context_length: ${CTX}
EOF
    if [[ "$BACKEND_MODEL" != "$MODEL_NAME" ]]; then
      cat <<EOF
  - model_name: ${BACKEND_MODEL}
    litellm_params:
      model: openai/${BACKEND_MODEL}
      api_base: http://127.0.0.1:7776/v1
      api_key: "${API_KEY}"
    model_info:
      max_input_tokens: ${CTX}
      max_context_length: ${CTX}
EOF
    fi
    cat <<'EOF'

litellm_settings:
  drop_params: true
EOF
  } | write_utf8 "$ROOT/scripts/litellm-config.yaml"
fi

mkdir -p "$HERMES_HOME"

NGROK_HEADERS=""
PROVIDER_NGROK=""
if [[ "$BASE_URL" == *ngrok* ]]; then
  NGROK_HEADERS=$'\n  extra_headers:\n    ngrok-skip-browser-warning: "true"\n  default_headers:\n    ngrok-skip-browser-warning: "true"'
  PROVIDER_NGROK=$'\n    extra_headers:\n      ngrok-skip-browser-warning: "true"'
fi

{
  cat <<EOF
model:
  default: "${MODEL_NAME}"
  provider: custom
  base_url: "${BASE_URL}"
  api_key: "${API_KEY}"
  context_length: ${CTX}${NGROK_HEADERS}

# ngrok no es "local" para Hermes: el stale default es 180s y mata el prefill de ACP.
providers:
  custom:
    base_url: "${BASE_URL}"
    api_key: "${API_KEY}"
    request_timeout_seconds: 1800
    stale_timeout_seconds: 900${PROVIDER_NGROK}
    models:
      ${MODEL_NAME}:
        context_length: ${CTX}
        timeout_seconds: 1800
        stale_timeout_seconds: 900

compression:
  enabled: true

platform_toolsets:
  cli: [file, terminal]
  acp: [file, terminal]

agent:
  disabled_toolsets:
    - web
    - browser
    - vision
    - image_gen
    - tts
    - memory
    - delegation
    - cron
    - skills
    - mcp
EOF
} | write_utf8 "$HERMES_HOME/config.yaml"

write_env() {
  cat > "$1" <<EOF
OPENAI_API_KEY=${API_KEY}
HERMES_API_TIMEOUT=1800
HERMES_API_CALL_STALE_TIMEOUT=900
HERMES_STREAM_STALE_TIMEOUT=900
HERMES_STREAM_STALE_GIVEUP=20
EOF
}

write_env "$HERMES_HOME/.env"

# El cliente ACP (Cursor/VS Code) lanza `hermes acp` sin HERMES_HOME y lee ~/.hermes.
DEFAULT_HOME="${HOME}/.hermes"
if [[ "$HERMES_HOME" != "$DEFAULT_HOME" ]]; then
  mkdir -p "$DEFAULT_HOME"
  write_utf8 "$DEFAULT_HOME/config.yaml" < "$HERMES_HOME/config.yaml"
  write_env "$DEFAULT_HOME/.env"
fi

echo "Runtime config: CTX=$CTX  Hermes=$BASE_URL  model=$MODEL_NAME  backend=$BACKEND_MODEL"
