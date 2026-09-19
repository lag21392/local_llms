@echo off
REM Fuente unica de configuracion en Windows. Los .bat hacen: call "%~dp0config.cmd"
REM En Linux usar scripts/config.sh (mantener ambos en sync).
REM CTX es la variable clave para Hermes (minimo 65536 tokens).

set "LLAMA_HOST=127.0.0.1"
set "LLAMA_PORT=7776"
set "LITELLM_PORT=7777"
set "API_KEY=any"
set "NGROK_URL=correct-ibex-charmed.ngrok-free.app"

set "HERMES_HOME=%~dp0..\agentes\hermes"
REM Hermes siempre sale por ngrok para poder usarlo desde otra maquina.
set "HERMES_BASE_URL=https://correct-ibex-charmed.ngrok-free.app/v1"
set "HERMES_MODEL=local"
set "HERMES_MIN_CTX=65536"

REM Contexto por GPU + modelo. Hermes rechaza ventanas < 65536.
set "CTX_3070_QWEN36=65536"
set "CTX_3070_QWEN38=65536"
set "CTX_3070_QWEN3=65536"
set "CTX_3070_NEXT=65536"
set "CTX_3070_BONSAI=65536"
set "CTX_5070TI_QWEN36=65536"
set "CTX_5070TI_QWEN38=65536"
set "CTX_5070TI_QWEN3=65536"
set "CTX_5070TI_NEXT=65536"
set "CTX_5070TI_BONSAI=65536"

REM Modelos — quants Unsloth Dynamic V3.0 (SOTA accuracy).
REM Qwen3.6-35B-A3B: UD-IQ1_M / IQ2_S (3070) / UD-IQ3_XXS (5070 Ti)
set "MODEL_QWEN36_IQ1M=%~dp0..\models\Qwen3.6-35B-A3B\Qwen3.6-35B-A3B-UD-IQ1_M.gguf"
set "MODEL_QWEN36_IQ2=%~dp0..\models\Qwen3.6-35B-A3B\Qwen3.6-35B-A3B-IQ2_S-2.25bpw.gguf"
set "MODEL_QWEN36_IQ3=%~dp0..\models\Qwen3.6-35B-A3B\Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf"
REM Qwen3.8-27B: UD-IQ2_XXS (3070, ~7.3 GB) / UD-IQ4_XS (5070 Ti)
set "MODEL_QWEN38_IQ2XXS=%~dp0..\models\Qwen3.8-27B\Qwen3.8-27B-UD-IQ2_XXS.gguf"
set "MODEL_QWEN38_IQ4XS=%~dp0..\models\Qwen3.8-27B\Qwen3.8-27B-UD-IQ4_XS.gguf"
REM Qwen3-8B: UD-IQ1_M (ambas GPUs, ~2.4 GB)
set "MODEL_QWEN3_IQ1M=%~dp0..\models\Qwen3-8B\Qwen3-8B-UD-IQ1_M.gguf"
REM Qwen3-Next-80B-A3B-Instruct: UD-TQ1_0 (NO cabe en 3070 8GB)
set "MODEL_NEXT_TQ1=%~dp0..\models\Qwen3-Next-80B-A3B-Instruct\Qwen3-Next-80B-A3B-Instruct-UD-TQ1_0.gguf"
set "MODEL_BONSAI2_PTQ1=%~dp0..\models\Ternary-Bonsai-2-27B\Ternary-Bonsai-2-27B-PTQ1_0.gguf"
