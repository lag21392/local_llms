#!/usr/bin/env bash
# Instala Hermes Agent en agentes/hermes (HERMES_HOME del proyecto).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../scripts/config.sh
source "$ROOT/scripts/config.sh"

HOME_DIR="$ROOT/agentes/hermes"
mkdir -p "$HOME_DIR"

INSTALLER="${TMPDIR:-/tmp}/hermes-install.sh"
echo "Descargando instalador oficial..."
curl -fsSL "https://hermes-agent.nousresearch.com/install.sh" -o "$INSTALLER"

echo "Instalando en $HOME_DIR ..."
# --skip-browser: este stack no usa web/browser (van deshabilitados en config.yaml)
# --skip-setup / --non-interactive: la config la escribe _write-runtime-config.sh
bash "$INSTALLER" \
  --hermes-home "$HOME_DIR" \
  --dir "$HOME_DIR/hermes-agent" \
  --skip-setup \
  --non-interactive \
  --skip-browser \
  --skip-computer-use

"$ROOT/scripts/_write-runtime-config.sh" \
  --ctx "$HERMES_MIN_CTX" \
  --hermes-home "$HOME_DIR" \
  --base-url "$HERMES_BASE_URL" \
  --model "$HERMES_MODEL" \
  --api-key "$API_KEY" \
  --skip-litellm

echo
echo "Hermes listo. Arranque:  agentes/run-hermes.sh"
echo "Apunta a la LLM remota:  $HERMES_BASE_URL  modelo=$HERMES_MODEL"
