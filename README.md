# LlamaCCP

Stack local de LLMs con llama.cpp + LiteLLM + Hermes Agent.

## GPU soportadas
- RTX 3070 (8GB): modelos IQ1_M / IQ2_XXS / IQ3_XXS (Q3)
- RTX 5070 Ti (16GB): IQ3_XXS / IQ4_XS / IQ3_XXS (Q3)

## Modelos
- Qwen3.6-35B-A3B (IQ1_M, IQ3_XXS)
- Qwen3.8-27B (IQ2_XXS, IQ4_XS)
- Qwen3-8B-A3B (IQ1_M, para 3070 Q3)
- Qwen3-Next-80B-A3B-Instruct (UD-TQ1_0)

## Como arrancar
1. Descargar modelos: `powershell -File scripts\download-unsloth-models.ps1`
2. Arrancar stack: `scripts\run-3070.bat` o `scripts\run-5070ti.bat`
3. Lanzar Hermes: `agentes\run-hermes.bat`

## Endpoints
- llama-server: `http://127.0.0.1:7776/v1`
- LiteLLM: `http://127.0.0.1:7777/v1` (Hermes usa este)
- ngrok: `https://correct-ibex-charmed.ngrok-free.app`

## Configuracion
Editar `scripts/config.cmd` para ajustar CTX, puertos, API key.
