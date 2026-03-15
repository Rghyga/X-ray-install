#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/core.sh
source /etc/katsu/lib/ui.sh
check_services(){ dashboard; pause; }
restart_menu(){ echo "1) Xray 2) Nginx 3) Semua"; read -r x; case "$x" in 1) systemctl restart xray ;; 2) systemctl restart nginx ;; 3) systemctl restart xray nginx cron fail2ban ;; esac; echo "Done"; pause; }
set_autoreboot(){ echo "1) 3 jam 2) 6 jam 3) 12 jam 4) 24 jam 5) custom cron"; read -r s; case "$s" in 1) cron="0 */3 * * *";;2) cron="0 */6 * * *";;3) cron="0 */12 * * *";;4) cron="0 0 * * *";;5) read -rp "Cron expr: " cron;; *) return;; esac; cat > /etc/cron.d/katsu-autoreboot <<CRON
SHELL=/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin
$cron root /sbin/reboot
CRON
systemctl restart cron; echo "Auto reboot enabled"; pause; }
disable_autoreboot(){ rm -f /etc/cron.d/katsu-autoreboot; systemctl restart cron; echo "Disabled"; pause; }
show_activity(){ dashboard; box "Activity Log"; tail -n 30 /var/log/katsu/activity.log 2>/dev/null || true; pause; }
realtime_monitor(){ iface=$(ip route get 1.1.1.1 | awk '{print $5; exit}'); prev_rx=0; prev_tx=0; while true; do rx=$(cat /sys/class/net/$iface/statistics/rx_bytes); tx=$(cat /sys/class/net/$iface/statistics/tx_bytes); if [ "$prev_rx" -gt 0 ]; then srx=$(( (rx-prev_rx)/2 )); stx=$(( (tx-prev_tx)/2 )); else srx=0; stx=0; fi; prev_rx=$rx; prev_tx=$tx; dashboard; box "Realtime Traffic"; /usr/local/bin/katsu-online || true; printf "\n RX/s : %s B/s\n TX/s : %s B/s\n\nCtrl+C untuk keluar\n" "$srx" "$stx"; sleep 2; done; }
