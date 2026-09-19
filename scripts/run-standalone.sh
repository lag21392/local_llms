#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo
echo "============================================"
echo " LlamaCCP Standalone - RTX 3070 8GB"
echo "============================================"
echo
echo " 1) Qwen3.6-35B-A3B     UD-IQ1_M    [Optimizado]"
echo " 2) Qwen3.6-35B-A3B     IQ2_S       [Alternativo]"
echo " 3) Qwen3.8-27B         UD-IQ2_XXS  [Encaja en 8GB]"
echo " 4) Qwen3-8B            UD-IQ1_M    [64K Contexto]"
echo " 5) Bonsai 2 27B        PTQ1_0      [Prism, Optimizado]"
echo
read -r -p "Elegi modelo [1-5]: " CHOICE
case "$CHOICE" in
  1) exec ./_start-standalone.sh 3070-qwen36 ;;
  2) exec ./_start-standalone.sh 3070-qwen36-iq2 ;;
  3) exec ./_start-standalone.sh 3070-qwen38 ;;
  4) exec ./_start-standalone.sh 3070-qwen3 ;;
  5) exec ./_start-standalone.sh 3070-bonsai ;;
  *) echo "Opcion invalida."; exit 1 ;;
esac