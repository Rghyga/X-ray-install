#!/usr/bin/env bash
set -euo pipefail
rm -rf /etc/katsu /etc/profile.d/katsu-panel.sh /usr/local/sbin/menu /usr/local/sbin/katsu-* /usr/local/bin/katsu-* /etc/cron.d/katsu-* /etc/systemd/system/katsu-realtime-watch.service /etc/nginx/conf.d/katsu.conf
systemctl daemon-reload || true
systemctl restart nginx || true
echo "Katsu panel removed"
