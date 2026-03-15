#!/usr/bin/env bash
set -euo pipefail
if ! command -v xray >/dev/null 2>&1; then bash <(curl -fsSL https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) install || true; fi
command -v xray >/dev/null 2>&1 || { echo "Xray gagal terpasang"; exit 1; }
