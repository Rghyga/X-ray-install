#!/usr/bin/env bash
set -euo pipefail
APP_ROOT="/etc/katsu"; CONFIG_ENV="$APP_ROOT/config.env"; XRAY_CONF="/usr/local/etc/xray/config.json"; USERS_DIR="$APP_ROOT/users"; BACKUP_DIR="/root/backup"; TELEGRAM_ENV="$APP_ROOT/telegram.conf"
load_cfg(){ [ -f "$CONFIG_ENV" ] && source "$CONFIG_ENV"; }
pause(){ read -rp "Enter untuk kembali..." _; }
valid_user(){ [[ "$1" =~ ^[A-Za-z0-9_-]+$ ]]; }
uuid_gen(){ cat /proc/sys/kernel/random/uuid; }
save_user_json(){ local proto="$1" user="$2" secret="$3" exp="$4" iplimit="${5:-2}" status="${6:-active}"; mkdir -p "$USERS_DIR/$proto"; cat > "$USERS_DIR/$proto/$user.json" <<JSON
{"username":"$user","protocol":"$proto","secret":"$secret","expired":"$exp","iplimit":$iplimit,"status":"$status","violations":0}
JSON
}
list_users(){ ls -1 "$USERS_DIR/$1" 2>/dev/null | sed 's/\.json$//' || true; }
service_state(){ systemctl is-active --quiet "$1" && echo ONLINE || echo ERROR; }
xray_add_client(){ local proto="$1" user="$2" secret="$3" payload tag1 tag2; case "$proto" in vmess) tag1="vmess-ws"; tag2="vmess-grpc"; payload=$(jq -cn --arg u "$user" --arg s "$secret" '{"id":$s,"alterId":0,"email":$u}');; vless) tag1="vless-ws"; tag2="vless-grpc"; payload=$(jq -cn --arg u "$user" --arg s "$secret" '{"id":$s,"email":$u}');; trojan) tag1="trojan-ws"; tag2="trojan-grpc"; payload=$(jq -cn --arg u "$user" --arg s "$secret" '{"password":$s,"email":$u}');; *) return 1;; esac; jq --arg t1 "$tag1" --arg t2 "$tag2" --argjson payload "$payload" '(.inbounds[] | select(.tag==$t1 or .tag==$t2) | .settings.clients) += [$payload]' "$XRAY_CONF" > "$XRAY_CONF.tmp" && mv "$XRAY_CONF.tmp" "$XRAY_CONF"; }
xray_remove_client(){ local proto="$1" user="$2" tag1 tag2; case "$proto" in vmess) tag1="vmess-ws"; tag2="vmess-grpc";; vless) tag1="vless-ws"; tag2="vless-grpc";; trojan) tag1="trojan-ws"; tag2="trojan-grpc";; *) return 1;; esac; jq --arg t1 "$tag1" --arg t2 "$tag2" --arg u "$user" '(.inbounds[] | select(.tag==$t1 or .tag==$t2) | .settings.clients) |= map(select(.email != $u))' "$XRAY_CONF" > "$XRAY_CONF.tmp" && mv "$XRAY_CONF.tmp" "$XRAY_CONF"; }
xray_sync_all(){ cp "$XRAY_CONF" "$XRAY_CONF.bak"; jq '(.inbounds[] | .settings.clients) = []' "$XRAY_CONF.bak" > "$XRAY_CONF"; for proto in vmess vless trojan; do for f in "$USERS_DIR"/$proto/*.json; do [ -e "$f" ] || continue; user="$(jq -r .username "$f")"; secret="$(jq -r .secret "$f")"; status="$(jq -r .status "$f")"; [ "$status" = "active" ] && xray_add_client "$proto" "$user" "$secret"; done; done; }
