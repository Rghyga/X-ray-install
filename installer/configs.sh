#!/usr/bin/env bash
set -euo pipefail
DOMAIN="${1:-}"
[ -n "$DOMAIN" ] || { echo "Usage: $0 domain"; exit 1; }
APP_ROOT="/etc/katsu"
XRAY_DIR="/usr/local/etc/xray"
mkdir -p /var/log/xray /etc/nginx/conf.d /var/www/html /root/backup /var/log/katsu
touch /var/log/xray/access.log /var/log/xray/error.log /var/log/katsu/activity.log
cp "$APP_ROOT/templates/xray.json.tpl" "$XRAY_DIR/config.json"
sed "s|__DOMAIN__|$DOMAIN|g; s|__XRAY_DIR__|$XRAY_DIR|g" "$APP_ROOT/templates/nginx.conf.tpl" > /etc/nginx/conf.d/katsu.conf
rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf || true
nginx -t
mkdir -p /etc/fail2ban/filter.d /etc/fail2ban/jail.d
cp "$APP_ROOT/templates/fail2ban/nginx-badbots.conf" /etc/fail2ban/filter.d/nginx-badbots.conf
cp "$APP_ROOT/templates/fail2ban/jail.local" /etc/fail2ban/jail.d/katsu.local
