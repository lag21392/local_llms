@echo off
REM Fuente unica de configuracion. Los .bat hacen: call "%~dp0config.cmd"
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
set "CTX_5070TI_QWEN36=65536"
set "CTX_5070TI_QWEN38=65536"
set "CTX_5070TI_QWEN3=65536"
set "CTX_5070TI_NEXT=65536"

set "MODEL_QWEN36_IQ1M=%~dp0..\models\Qwen3.6-35B-A3B\Qwen3.6-35B-A3B-UD-IQ1_M.gguf"
set "MODEL_QWEN36_IQ3=%~dp0..\models\Qwen3.6-35B-A3B\Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf"
set "MODEL_QWEN38_IQ2=%~dp0..\models\Qwen3.8-27B\Qwen3.8-27B-UD-IQ2_XXS.gguf"
set "MODEL_QWEN38_IQ4=%~dp0..\models\Qwen3.8-27B\Qwen3.8-27B-UD-IQ4_XS.gguf"
set "MODEL_QWEN3_IQ1=%~dp0..\models\Qwen3-8B\Qwen3-8B-UD-IQ1_M.gguf"
set "MODEL_NEXT_TQ1=%~dp0..\models\Qwen3-Next-80B-A3B-Instruct\Qwen3-Next-80B-A3B-Instruct-UD-TQ1_0.gguf"
