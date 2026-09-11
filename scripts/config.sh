# Fuente unica de configuracion en Linux. Los .sh hacen: source "$ROOT/scripts/config.sh"
# CTX es la variable clave para Hermes (minimo 65536 tokens).
# Mantener en sync con scripts/config.cmd

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

LLAMA_HOST=127.0.0.1
LLAMA_PORT=7776
LITELLM_PORT=7777
API_KEY=any
NGROK_URL=correct-ibex-charmed.ngrok-free.app

HERMES_HOME="${HERMES_HOME:-$ROOT/agentes/hermes}"
# Hermes siempre sale por ngrok para poder usarlo desde otra maquina.
HERMES_BASE_URL="${HERMES_BASE_URL:-https://correct-ibex-charmed.ngrok-free.app/v1}"
HERMES_MODEL="${HERMES_MODEL:-local}"
HERMES_MIN_CTX=65536

# Contexto por GPU + modelo. Hermes rechaza ventanas < 65536.
CTX_3070_QWEN36=65536
CTX_3070_QWEN38=65536
CTX_3070_QWEN3=65536
CTX_3070_NEXT=65536
CTX_5070TI_QWEN36=65536
CTX_5070TI_QWEN38=65536
CTX_5070TI_QWEN3=65536
CTX_5070TI_NEXT=65536

MODEL_QWEN36_IQ1M="$ROOT/models/Qwen3.6-35B-A3B/Qwen3.6-35B-A3B-UD-IQ1_M.gguf"
MODEL_QWEN36_IQ3="$ROOT/models/Qwen3.6-35B-A3B/Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf"
MODEL_QWEN38_IQ2="$ROOT/models/Qwen3.8-27B/Qwen3.8-27B-UD-IQ2_XXS.gguf"
MODEL_QWEN38_IQ4="$ROOT/models/Qwen3.8-27B/Qwen3.8-27B-UD-IQ4_XS.gguf"
MODEL_QWEN3_IQ1="$ROOT/models/Qwen3-8B/Qwen3-8B-UD-IQ1_M.gguf"
MODEL_NEXT_TQ1="$ROOT/models/Qwen3-Next-80B-A3B-Instruct/Qwen3-Next-80B-A3B-Instruct-UD-TQ1_0.gguf"
