#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/core.sh
source /etc/katsu/lib/ui.sh
backup_now(){ file="$BACKUP_DIR/katsu-$(date +%F-%H%M%S).tar.gz"; tar -czf "$file" /etc/katsu /usr/local/etc/xray /etc/nginx/conf.d /var/log/katsu >/dev/null 2>&1; echo "$file"; if [ -f "$TELEGRAM_ENV" ]; then source "$TELEGRAM_ENV"; curl -fsS -F document=@"$file" -F caption="Katsu backup $(hostname) $(date '+%F %T')" "https://api.telegram.org/bot$BOT_TOKEN/sendDocument?chat_id=$CHAT_ID" >/dev/null || true; echo "Backup sent to Telegram"; fi; pause; }
restore_backup(){ read -rp "Full path backup: " file; [ -f "$file" ] || { echo "Not found"; pause; return; }; tar -xzf "$file" -C /; systemctl restart nginx xray; echo "Restored"; pause; }
set_telegram(){ read -rp "Bot Token: " token; read -rp "Chat ID: " chatid; cat > "$TELEGRAM_ENV" <<ENV
BOT_TOKEN=$token
CHAT_ID=$chatid
ENV
echo "Saved"; pause; }
set_autobackup(){ echo "1) 3 jam 2) 6 jam 3) 12 jam 4) 24 jam 5) custom cron"; read -r s; case "$s" in 1) cron="0 */3 * * *";;2) cron="0 */6 * * *";;3) cron="0 */12 * * *";;4) cron="0 0 * * *";;5) read -rp "Cron expr: " cron;; *) return;; esac; cat > /etc/cron.d/katsu-autobackup <<CRON
SHELL=/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin
$cron root /usr/local/sbin/katsu-backup-auto >/dev/null 2>&1
CRON
systemctl restart cron; echo "Auto backup enabled"; pause; }
disable_autobackup(){ rm -f /etc/cron.d/katsu-autobackup; systemctl restart cron; echo "Disabled"; pause; }
