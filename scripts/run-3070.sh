#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo
echo "============================================"
echo " LlamaCCP  -  RTX 3070 Laptop 8GB"
echo "============================================"
echo
echo " 1) Qwen3.6-35B-A3B     UD-IQ1_M"
echo " 2) Qwen3.8-27B         UD-Q4_K_XL"
echo " 3) Qwen3-Next-80B-A3B  UD-TQ1_0"
echo " 4) Qwen3-8B            UD-Q4_K_M"
echo
read -r -p "Elegi modelo [1-4]: " CHOICE
case "$CHOICE" in
  1) exec ./_start.sh 3070-qwen36 ;;
  2) exec ./_start.sh 3070-qwen38 ;;
  3) exec ./_start.sh 3070-next ;;
  4) exec ./_start.sh 3070-qwen3 ;;
  *) echo "Opcion invalida."; exit 1 ;;
esac
