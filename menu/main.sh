#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/ui.sh
while true; do dashboard; box "Main Menu"; printf " [1] VMESS Management\n [2] VLESS Management\n [3] TROJAN Management\n [4] SSH Management\n [5] BACKUP\n [6] SYSTEM\n [0] EXIT\n"; line; printf " Select Menu : "; read -r opt; case "$opt" in 1) /etc/katsu/menu/vmess.sh ;; 2) /etc/katsu/menu/vless.sh ;; 3) /etc/katsu/menu/trojan.sh ;; 4) /etc/katsu/menu/ssh.sh ;; 5) /etc/katsu/menu/backup.sh ;; 6) /etc/katsu/menu/system.sh ;; 0) exit 0 ;; esac; done
