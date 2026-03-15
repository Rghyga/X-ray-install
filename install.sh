#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-Rghyga}"
REPO_NAME="${REPO_NAME:-X-ray-install}"
REPO_BRANCH="${REPO_BRANCH:-master}"

TMP_DIR="$(mktemp -d /tmp/katsu-install.XXXXXX)"
ARCHIVE_URL="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/refs/heads/${REPO_BRANCH}"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

need_root() {
  [ "$(id -u)" = "0" ] || { echo "Run as root"; exit 1; }
}

download_repo() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/repo.tar.gz"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_DIR/repo.tar.gz" "$ARCHIVE_URL"
  else
    echo "curl atau wget wajib tersedia"
    exit 1
  fi
  tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
}

run_setup() {
  REPO_DIR="$(find "$TMP_DIR" -maxdepth 1 -mindepth 1 -type d | head -n 1)"
  [ -n "$REPO_DIR" ] || { echo "Repo gagal diekstrak"; exit 1; }
  [ -f "$REPO_DIR/setup.sh" ] || { echo "setup.sh tidak ditemukan di repo"; exit 1; }
  chmod +x "$REPO_DIR/setup.sh"
  cd "$REPO_DIR"
  exec ./setup.sh
}

main() {
  need_root
  download_repo
  run_setup
}
main "$@"
