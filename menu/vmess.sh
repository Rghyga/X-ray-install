#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/core.sh
source /etc/katsu/lib/ui.sh
source /etc/katsu/lib/proto.sh
load_cfg
add_user(){ read -rp "Username: " user; valid_user "$user" || { echo "Username tidak valid"; pause; return; }; read -rp "Expired berapa hari: " days; read -rp "Limit IP [2]: " iplimit; iplimit="${iplimit:-2}"; secret="$(uuid_gen)"; exp="$(date -d "+${days} days" +%F)"; xray_add_client vmess "$user" "$secret"; save_user_json vmess "$user" "$secret" "$exp" "$iplimit"; systemctl restart xray; dashboard; print_vmess "$user" "$secret" "$exp"; pause; }
del_user(){ read -rp "Username: " user; xray_remove_client vmess "$user"; rm -f "$USERS_DIR/vmess/$user.json" "/var/www/html/vmess-$user.txt"; systemctl restart xray; echo "Deleted: $user"; pause; }
renew_user(){ read -rp "Username: " user; read -rp "Tambah hari: " days; file="$USERS_DIR/vmess/$user.json"; [ -f "$file" ] || { echo "User tidak ada"; pause; return; }; old="$(jq -r .expired "$file")"; new="$(date -d "$old +$days days" +%F 2>/dev/null || date -d "+$days days" +%F)"; jq --arg d "$new" '.expired=$d' "$file" > "$file.tmp" && mv "$file.tmp" "$file"; echo "Expired baru: $new"; pause; }
trial_user(){ user="trial$(tr -dc a-z0-9 </dev/urandom | head -c 4)"; secret="$(uuid_gen)"; exp="$(date -d '+1 day' +%F)"; xray_add_client vmess "$user" "$secret"; save_user_json vmess "$user" "$secret" "$exp" 1; systemctl restart xray; echo "Trial created: $user exp:$exp"; pause; }
list_user(){ dashboard; box "VMESS USER LIST"; for u in $(list_users vmess); do exp="$(jq -r .expired "$USERS_DIR/vmess/$u.json")"; iplimit="$(jq -r .iplimit "$USERS_DIR/vmess/$u.json")"; status="$(jq -r .status "$USERS_DIR/vmess/$u.json")"; printf " %-18s exp:%-12s iplimit:%-3s status:%s\n" "$u" "$exp" "$iplimit" "$status"; done; pause; }
set_limit(){ read -rp "Username: " user; read -rp "Limit IP baru: " limit; file="$USERS_DIR/vmess/$user.json"; [ -f "$file" ] || { echo "User tidak ada"; pause; return; }; jq --argjson l "$limit" '.iplimit=$l' "$file" > "$file.tmp" && mv "$file.tmp" "$file"; echo "Updated"; pause; }
while true; do dashboard; box "VMESS Management"; printf " [1] Add\n [2] Delete\n [3] List\n [4] Renew\n [5] Trial\n [6] Set Limit IP\n [0] Back\n"; line; printf " Select Menu : "; read -r opt; case "$opt" in 1) add_user ;; 2) del_user ;; 3) list_user ;; 4) renew_user ;; 5) trial_user ;; 6) set_limit ;; 0) exit 0 ;; esac; done
