#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/ui.sh
source /etc/katsu/lib/backup.sh
while true; do dashboard; box "Backup & Restore"; printf " [1] Backup sekarang\n [2] Restore backup\n [3] Set Telegram\n [4] Enable auto backup\n [5] Disable auto backup\n [0] Back\n"; line; printf " Select Menu : "; read -r opt; case "$opt" in 1) backup_now ;; 2) restore_backup ;; 3) set_telegram ;; 4) set_autobackup ;; 5) disable_autobackup ;; 0) exit 0 ;; esac; done
