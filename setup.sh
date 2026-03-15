#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_ROOT="/etc/katsu"
need_root(){ [ "$(id -u)" = "0" ] || { echo "Run as root"; exit 1; }; }
public_ip(){ curl -4fsSL https://ipv4.icanhazip.com | tr -d '\n'; }
main(){ need_root; clear; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "         KATSU PANEL FINAL"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; read -rp "Masukkan domain anda: " DOMAIN; [ -n "$DOMAIN" ] || { echo "Domain wajib diisi"; exit 1; }; pip="$(public_ip || true)"; dip="$(getent ahostsv4 "$DOMAIN" | awk '/STREAM/ {print $1; exit}')"; [ -n "$pip" ] || { echo "Tidak bisa mendeteksi IP publik"; exit 1; }; [ -n "$dip" ] || { echo "Domain belum resolve ke IPv4"; exit 1; }; [ "$dip" = "$pip" ] || { echo "Domain $DOMAIN resolve ke $dip, bukan $pip"; exit 1; }; rm -rf "$APP_ROOT"; mkdir -p "$APP_ROOT"; cp -r "$SCRIPT_DIR"/templates "$APP_ROOT"/; cp -r "$SCRIPT_DIR"/lib "$APP_ROOT"/; cp -r "$SCRIPT_DIR"/menu "$APP_ROOT"/; cp -r "$SCRIPT_DIR"/scripts "$APP_ROOT"/; cp -r "$SCRIPT_DIR"/systemd "$APP_ROOT"/; mkdir -p "$APP_ROOT/users"/{vmess,vless,trojan,ssh}; cat > "$APP_ROOT/config.env" <<EOF
DOMAIN=$DOMAIN
APP_ROOT=$APP_ROOT
XRAY_DIR=/usr/local/etc/xray
TIMEZONE=Asia/Jakarta
EOF
bash "$SCRIPT_DIR/installer/packages.sh"; bash "$SCRIPT_DIR/installer/xray.sh"; bash "$SCRIPT_DIR/installer/cert.sh" "$DOMAIN"; bash "$SCRIPT_DIR/installer/configs.sh" "$DOMAIN"; (cd "$SCRIPT_DIR/cmd/online" && go build -o /usr/local/bin/katsu-online .); (cd "$SCRIPT_DIR/cmd/traffic" && go build -o /usr/local/bin/katsu-traffic .); (cd "$SCRIPT_DIR/cmd/iplimit" && go build -o /usr/local/bin/katsu-iplimit .); cat > /usr/local/bin/katsu-ssh-online <<'EOF'
#!/usr/bin/env bash
who | awk '{print $1,$5}' | sort | uniq
EOF
chmod +x /usr/local/bin/katsu-online /usr/local/bin/katsu-traffic /usr/local/bin/katsu-iplimit /usr/local/bin/katsu-ssh-online; bash "$SCRIPT_DIR/installer/runtime.sh"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo " INSTALL SELESAI"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "Domain : $DOMAIN"; echo "IP VPS : $pip"; echo "Xray   : $(systemctl is-active xray || true)"; echo "Nginx  : $(systemctl is-active nginx || true)"; echo "Fail2ban: $(systemctl is-active fail2ban || true)"; echo; echo "Ketik: menu"; }
main "$@"
