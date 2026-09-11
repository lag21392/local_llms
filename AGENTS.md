# LlamaCCP

LLM local: llama.cpp + LiteLLM. Hermes usa solo LiteLLM.

## Como arrancar

PC con GPU (Windows o Linux):
1. `scripts/run-3070.bat|.sh` o `scripts/run-5070ti.bat|.sh` (levanta modelo + LiteLLM + ngrok)

Cliente Hermes (esta u otra maquina, Linux o Windows):
2. Primera vez en Linux: `agentes/install-hermes.sh`
3. CLI: `agentes/run-hermes.sh` (o `agentes/run-hermes.bat` en Windows)
4. ACP Client / Rina en Cursor: recargar la ventana y conectar "Hermes Agent". El wrapper es `agentes/run-hermes-acp.sh`.

Hermes siempre habla con la LLM remota por ngrok. En Linux no hace falta GPU.

## Endpoints

- Hermes: `https://correct-ibex-charmed.ngrok-free.app/v1`  modelo `local`  api_key `any`
- llama-server (local): `http://127.0.0.1:7776/v1`
- LiteLLM (local): `http://127.0.0.1:7777/v1`

## Contexto

Editar `scripts/config.cmd` (Windows) o `scripts/config.sh` (Linux) (`CTX_3070_*` / `CTX_5070TI_*`). Hermes pide 65536 minimo. Al lanzar un modelo ese valor se copia a LiteLLM y a `agentes/hermes/config.yaml`.

## Modelos

- Qwen3.6-35B-A3B (3070: IQ1_M, 5070 Ti: IQ3_XXS)
- Qwen3.8-27B (3070: IQ2_XXS, 5070 Ti: IQ4_XS)
- Qwen3-8B (3070/5070 Ti: IQ1_M Q3)
- Qwen3-Next-80B UD-TQ1_0

No pidas API keys de nube. Para parar el stack, usa la ventana del run-*.bat o Enter en el run-*.sh.
