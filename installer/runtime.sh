#!/usr/bin/env bash
set -euo pipefail
APP_ROOT="/etc/katsu"
cat > /usr/local/sbin/menu <<'EOF'
#!/usr/bin/env bash
exec /etc/katsu/menu/main.sh
EOF
install -m 755 "$APP_ROOT/scripts/backup-auto.sh" /usr/local/sbin/katsu-backup-auto
install -m 755 "$APP_ROOT/scripts/realtime-watch.sh" /usr/local/sbin/katsu-realtime-watch
install -m 755 "$APP_ROOT/scripts/banner.sh" /etc/profile.d/katsu-panel.sh
install -m 644 "$APP_ROOT/systemd/katsu-realtime-watch.service" /etc/systemd/system/katsu-realtime-watch.service
chmod +x /usr/local/sbin/menu
systemctl daemon-reload
systemctl enable nginx xray fail2ban katsu-realtime-watch
systemctl restart fail2ban || true
systemctl restart xray
systemctl restart nginx
systemctl restart katsu-realtime-watch || true
