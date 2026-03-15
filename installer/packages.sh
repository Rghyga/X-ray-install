#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y curl wget jq socat cron nginx ufw vnstat zip unzip tar bc ca-certificates lsb-release golang-go fail2ban
timedatectl set-timezone Asia/Jakarta || true
systemctl enable cron vnstat
systemctl restart cron vnstat
ufw allow 22/tcp || true
ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw --force enable || true
