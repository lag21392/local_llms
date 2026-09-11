# LlamaCCP

Stack local de LLMs con llama.cpp + LiteLLM + Hermes Agent.

## Modelos

- Qwen3.6-35B-A3B (3070: UD-IQ1_M, 5070 Ti: UD-IQ3_XXS)
- Qwen3.8-27B (3070: UD-Q4_K_XL, 5070 Ti: UD-Q4_K_M)
- Qwen3-8B (3070/5070 Ti: UD-Q4_K_M)
- Qwen3-Next-80B-A3B-Instruct (UD-TQ1_0)

## Como arrancar

### Windows (PC con GPU)
1. Descargar modelos: `powershell -File scripts\download-unsloth-models.ps1`
2. Arrancar stack: `scripts\run-3070.bat` o `scripts\run-5070ti.bat`
3. Lanzar Hermes (esta maquina u otra): `agentes\run-hermes.bat`

### Linux (cliente Hermes contra LLM remota)
1. Instalar Hermes una vez: `agentes/install-hermes.sh`
2. En la PC con GPU, dejar el stack arriba (`run-3070` / `run-5070ti`)
3. En esta maquina: `agentes/run-hermes.sh`
4. En Cursor, ACP Client: conectar **Hermes Agent** (usa `agentes/run-hermes-acp.sh`). Recarga la ventana si no aparece.

Hermes habla solo con LiteLLM por ngrok (`https://correct-ibex-charmed.ngrok-free.app/v1`, modelo `local`, api_key `any`). No hace falta GPU en el cliente.

Si tambien queres levantar el stack en Linux: `scripts/download-unsloth-models.sh` y luego `scripts/run-3070.sh` o `scripts/run-5070ti.sh` (hace falta `llama-server` en `llamacpp-cuda13/` o en el PATH, venv con LiteLLM, y ngrok autenticado).

## Endpoints

- Hermes: `https://correct-ibex-charmed.ngrok-free.app/v1`  modelo `local`  api_key `any`
- llama-server (local): `http://127.0.0.1:7776/v1`
- LiteLLM (local): `http://127.0.0.1:7777/v1`

## Configuracion

- Windows: `scripts/config.cmd`
- Linux: `scripts/config.sh`

Ahi se ajustan CTX, puertos, API key y `NGROK_URL` / `HERMES_BASE_URL`.
