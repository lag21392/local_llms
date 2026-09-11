#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo
echo "============================================"
echo " LlamaCCP  -  RTX 5070 Ti 16GB"
echo "============================================"
echo
echo " 1) Qwen3.6-35B-A3B     UD-IQ3_XXS"
echo " 2) Qwen3.8-27B         UD-IQ4_XS"
echo " 3) Qwen3-Next-80B-A3B  UD-TQ1_0"
echo " 4) Qwen3-8B            UD-IQ1_M [Q3]"
echo
read -r -p "Elegi modelo [1-4]: " CHOICE
case "$CHOICE" in
  1) exec ./_start.sh 5070ti-qwen36 ;;
  2) exec ./_start.sh 5070ti-qwen38 ;;
  3) exec ./_start.sh 5070ti-next ;;
  4) exec ./_start.sh 5070ti-qwen3 ;;
  *) echo "Opcion invalida."; exit 1 ;;
esac
