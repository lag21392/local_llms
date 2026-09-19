# LlamaCCP

LLM local: solo llama.cpp. Sin LiteLLM, sin ngrok, sin Hermes.

## Como arrancar

PC con GPU (Windows o Linux):
1. `scripts/run-3070.bat|.sh` o `scripts/run-5070ti.bat|.sh` (levanta solo llama-server en puerto 7776)
2. Para modo standalone: `scripts/run-standalone.bat|.sh`

## Endpoints

- llama-server (local): `http://127.0.0.1:7776/v1`
- Chat UI: `http://127.0.0.1:7776`
- API Docs: `http://127.0.0.1:7776/docs`
- Health: `http://127.0.0.1:7776/health`

## Para VS Code / Cursor / OpenWebUI / LibreChat

```
Base URL: http://127.0.0.1:7776/v1   (o http://TU_IP:7776/v1 en LAN)
Model:    local
API Key:  (vacío)
```

## Modelos (reales para 3070 8GB)

- Qwen3.6-35B-A3B UD-IQ1_M — 3.1 GB VRAM, 24 TPS
- Qwen3.6-35B-A3B IQ2_S — 3.0 GB VRAM, 24 TPS
- Qwen3.8-27B UD-IQ2_XXS — 7.9 GB VRAM, 6 TPS
- Qwen3-8B UD-IQ1_M — 6.6 GB VRAM, **82 TPS, 64K ctx** ← mejor para código
- Bonsai 2 27B PTQ1_0 — ~4.5 GB VRAM, 21 TPS (requiere `llamacpp-prism`)

## Configuración

- Windows: `scripts/config.cmd`
- Linux: `scripts/config.sh`

KV cache `q4_0` optimizado para 8GB VRAM. Contextos: 8K (modelos 35B/27B) o 64K (modelo 8B).