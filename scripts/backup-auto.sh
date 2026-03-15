#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/core.sh
file="$BACKUP_DIR/katsu-$(date +%F-%H%M%S).tar.gz"
tar -czf "$file" /etc/katsu /usr/local/etc/xray /etc/nginx/conf.d /var/log/katsu >/dev/null 2>&1
if [ -f "$TELEGRAM_ENV" ]; then source "$TELEGRAM_ENV"; curl -fsS -F document=@"$file" -F caption="Katsu backup $(hostname) $(date '+%F %T')" "https://api.telegram.org/bot$BOT_TOKEN/sendDocument?chat_id=$CHAT_ID" >/dev/null || true; fi
