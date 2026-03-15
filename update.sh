#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-Rghyga}"
REPO_NAME="${REPO_NAME:-X-ray-install}"
REPO_BRANCH="${REPO_BRANCH:-main}"
APP_ROOT="/etc/katsu"
TMP_DIR="$(mktemp -d /tmp/katsu-update.XXXXXX)"
ARCHIVE_URL="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/refs/heads/${REPO_BRANCH}"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

[ "$(id -u)" = "0" ] || { echo "Run as root"; exit 1; }

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/repo.tar.gz"
else
  wget -qO "$TMP_DIR/repo.tar.gz" "$ARCHIVE_URL"
fi

tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
REPO_DIR="$(find "$TMP_DIR" -maxdepth 1 -mindepth 1 -type d | head -n 1)"

[ -d "$APP_ROOT" ] || { echo "/etc/katsu belum ada. Install dulu."; exit 1; }

cp -rf "$REPO_DIR"/templates "$APP_ROOT"/
cp -rf "$REPO_DIR"/lib "$APP_ROOT"/
cp -rf "$REPO_DIR"/menu "$APP_ROOT"/
cp -rf "$REPO_DIR"/scripts "$APP_ROOT"/
cp -rf "$REPO_DIR"/systemd "$APP_ROOT"/

install -m 755 "$APP_ROOT/scripts/backup-auto.sh" /usr/local/sbin/katsu-backup-auto
install -m 755 "$APP_ROOT/scripts/realtime-watch.sh" /usr/local/sbin/katsu-realtime-watch
install -m 755 "$APP_ROOT/scripts/banner.sh" /etc/profile.d/katsu-panel.sh
install -m 644 "$APP_ROOT/systemd/katsu-realtime-watch.service" /etc/systemd/system/katsu-realtime-watch.service

systemctl daemon-reload
systemctl restart katsu-realtime-watch || true
systemctl restart xray || true
systemctl restart nginx || true

echo "Update selesai dari ${REPO_OWNER}/${REPO_NAME}:${REPO_BRANCH}"
