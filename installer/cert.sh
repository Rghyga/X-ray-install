#!/usr/bin/env bash
set -euo pipefail
DOMAIN="${1:-}"
[ -n "$DOMAIN" ] || { echo "Usage: $0 domain"; exit 1; }
[ -d /root/.acme.sh ] || curl https://get.acme.sh | sh
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
systemctl stop nginx || true
/root/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone -k ec-256
mkdir -p /usr/local/etc/xray
/root/.acme.sh/acme.sh --install-cert -d "$DOMAIN" --ecc --fullchain-file /usr/local/etc/xray/xray.crt --key-file /usr/local/etc/xray/xray.key
