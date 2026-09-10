# LlamaCCP

Stack local de LLMs con llama.cpp + LiteLLM + Hermes Agent.

## GPU soportadas
- RTX 3070 (8GB): IQ1_M / IQ2_XXS / Qwen3-8B IQ1_M (Q3)
- RTX 5070 Ti (16GB): IQ3_XXS / IQ4_XS / Qwen3-8B IQ1_M (Q3)

## Modelos
- Qwen3.6-35B-A3B (IQ1_M, IQ3_XXS)
- Qwen3.8-27B (IQ2_XXS, IQ4_XS)
- Qwen3-8B (IQ1_M, Q3)
- Qwen3-Next-80B-A3B-Instruct (UD-TQ1_0)

## Como arrancar
1. Descargar modelos: `powershell -File scripts\download-unsloth-models.ps1`
2. Arrancar stack (esta maquina, con GPU): `scripts\run-3070.bat` o `scripts\run-5070ti.bat`
3. Lanzar Hermes (esta maquina u otra): `agentes\run-hermes.bat`

Hermes siempre usa el tunel publico de ngrok. En la PC del modelo hace falta `ngrok.exe` en `ngrok\ngrok.exe` o en `%LOCALAPPDATA%\ngrok\ngrok.exe`, ya autenticado, con el dominio reservado.

## Endpoints
- Hermes: `https://correct-ibex-charmed.ngrok-free.app/v1`  modelo `local`  api_key `any`
- llama-server (local): `http://127.0.0.1:7776/v1`
- LiteLLM (local): `http://127.0.0.1:7777/v1`

## Configuracion
Editar `scripts/config.cmd` para ajustar CTX, puertos, API key y `NGROK_URL`.
