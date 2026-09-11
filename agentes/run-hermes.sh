#!/usr/bin/env bash
# Arranca Hermes contra la LLM remota (ngrok / LiteLLM).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../scripts/config.sh
source "$ROOT/scripts/config.sh"
HERMES_HOME="${HERMES_HOME:-$ROOT/agentes/hermes}"

"$ROOT/scripts/_write-runtime-config.sh" \
  --ctx "$HERMES_MIN_CTX" \
  --hermes-home "$HERMES_HOME" \
  --base-url "$HERMES_BASE_URL" \
  --model "$HERMES_MODEL" \
  --api-key "$API_KEY" \
  --skip-litellm

export HERMES_HOME
export PATH="$HERMES_HOME/bin:$HERMES_HOME/hermes-agent/venv/bin:$HOME/.local/bin:$PATH"

echo
echo "Hermes  -> $HERMES_BASE_URL  modelo=$HERMES_MODEL  ctx=$HERMES_MIN_CTX"
echo "HERMES_HOME=$HERMES_HOME"
echo
echo "Hermes sale siempre por ngrok (LLM remota)."
echo "En la PC con GPU el modelo tiene que estar arriba: scripts/run-3070.sh|.bat o scripts/run-5070ti.sh|.bat"
echo

find_hermes() {
  local c
  for c in \
    "$HERMES_HOME/bin/hermes" \
    "$HERMES_HOME/hermes-agent/venv/bin/hermes" \
    "$HOME/.local/bin/hermes" \
    "$HOME/.hermes/hermes-agent/venv/bin/hermes"
  do
    if [[ -x "$c" ]]; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

if HERMES_BIN="$(find_hermes)"; then
  exec "$HERMES_BIN"
fi

echo "No se encontro el binario hermes."
echo "Buscado en:"
echo "  $HERMES_HOME/bin/hermes"
echo "  $HERMES_HOME/hermes-agent/venv/bin/hermes"
echo "  $HOME/.local/bin/hermes"
echo "Instalalo con:  agentes/install-hermes.sh"
exit 1
