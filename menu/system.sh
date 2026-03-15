#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/ui.sh
source /etc/katsu/lib/system.sh
while true; do dashboard; box "System & Monitor"; printf " [1] Cek service\n [2] Restart service\n [3] Enable auto reboot\n [4] Disable auto reboot\n [5] Realtime traffic\n [6] Online user\n [7] Top traffic\n [8] Activity log\n [0] Back\n"; line; printf " Select Menu : "; read -r opt; case "$opt" in 1) check_services ;; 2) restart_menu ;; 3) set_autoreboot ;; 4) disable_autoreboot ;; 5) realtime_monitor ;; 6) /usr/local/bin/katsu-online; pause ;; 7) /usr/local/bin/katsu-traffic; pause ;; 8) show_activity ;; 0) exit 0 ;; esac; done
