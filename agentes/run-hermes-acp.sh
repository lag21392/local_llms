#!/usr/bin/env bash
# Wrapper para el cliente ACP (Cursor / VS Code). Exporta HERMES_HOME
# y deja stdout limpio para JSON-RPC.
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
  --skip-litellm >/dev/null

export HERMES_HOME
export PATH="$HERMES_HOME/bin:$HERMES_HOME/hermes-agent/venv/bin:$HOME/.local/bin:$PATH"

if [[ -x "$HOME/.local/bin/hermes-acp" ]]; then
  exec "$HOME/.local/bin/hermes-acp" "$@"
fi
if [[ -x "$HERMES_HOME/hermes-agent/venv/bin/hermes" ]]; then
  exec "$HERMES_HOME/hermes-agent/venv/bin/hermes" acp "$@"
fi

echo "No se encontro hermes-acp. Corre: agentes/install-hermes.sh" >&2
exit 1
