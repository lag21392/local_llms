# LlamaCCP

Stack local de LLMs con llama.cpp (standalone) para RTX 3070 / 5070 Ti.

## GPU soportadas
- RTX 3070 (8GB): UD-IQ1_M / IQ2_S / UD-IQ2_XXS / UD-IQ1_M (64K) / PTQ1_0
- RTX 5070 Ti (16GB): UD-IQ3_XXS / UD-Q4_K_M / UD-Q4_K_M / PTQ1_0

## Modelos (reales, descargados)

| Modelo | 3070 8GB | 5070 Ti 16GB | Notas |
|--------|----------|--------------|-------|
| Qwen3.6-35B-A3B UD-IQ1_M | ✅ 3.1 GB VRAM | — | Optimizado |
| Qwen3.6-35B-A3B IQ2_S | ✅ 3.0 GB VRAM | — | Alternativo |
| Qwen3.8-27B UD-IQ2_XXS | ✅ 7.9 GB VRAM | — | Justo |
| Qwen3-8B UD-IQ1_M | ✅ 6.6 GB VRAM (64K ctx) | ✅ | **Mejor para código** |
| Bonsai 2 27B PTQ1_0 | ✅ ~4.5 GB VRAM | ✅ | Requiere `llamacpp-prism` |
| Qwen3.6-35B UD-IQ3_XXS | ❌ | ✅ | |
| Qwen3.8-27B UD-Q4_K_M | ❌ | ✅ | |
| Qwen3-8B UD-Q4_K_M | ❌ | ✅ | |

## Como arrancar

### Windows (PC con GPU)
1. `scripts\run-3070.bat` o `scripts\run-5070ti.bat`
   - Menú interactivo, elige modelo
   - Levanta solo `llama-server` en puerto 7776
   - **Sin** LiteLLM, **sin** ngrok, **sin** Hermes

### Linux
1. `scripts/run-3070.sh` o `scripts/run-5070ti.sh`
   - Mismo menú, mismo resultado

### Modo standalone (solo llama-server)
- `scripts\run-standalone.bat` / `scripts/run-standalone.sh`
- Solo llama-server, puerto 7776, firewall abierto

## Endpoints

- llama-server (local): `http://127.0.0.1:7776/v1`
- Chat UI web: `http://127.0.0.1:7776`
- API Docs (Swagger): `http://127.0.0.1:7776/docs`
- Health: `http://127.0.0.1:7776/health`

## Para VS Code / Cursor / OpenWebUI / LibreChat

```
Base URL: http://127.0.0.1:7776/v1   (o http://TU_IP:7776/v1 en LAN)
Model:    local
API Key:  (vacío)
```

## Configuración

- Windows: `scripts/config.cmd`
- Linux: `scripts/config.sh`

CTX, puertos, batch sizes, KV cache (q4_0 optimizado para 8GB).