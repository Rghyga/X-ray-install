# Katsu Panel GitHub Ready

Repo ini sudah siap dipakai dengan model autoscript 1-command install.

## Setting repo GitHub
Default repo ada di file `install.sh` dan `update.sh`:

```bash
REPO_OWNER="${REPO_OWNER:-Rghyga}"
REPO_NAME="${REPO_NAME:-X-ray-install}"
REPO_BRANCH="${REPO_BRANCH:-main}"
```

Kalau branch kamu masih `master`, ubah `main` menjadi `master`.

## Struktur penting
- `install.sh` = bootstrap installer dari GitHub raw/curl
- `setup.sh` = installer project yang sebenarnya
- `update.sh` = update file panel dari repo GitHub
- `uninstall.sh` = hapus panel

## Install 1 command
Branch `main`:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Rghyga/X-ray-install/main/install.sh)
```

Branch `master`:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Rghyga/X-ray-install/master/install.sh)
```

## Install manual dari clone
```bash
git clone https://github.com/Rghyga/X-ray-install
cd X-ray-install
chmod +x setup.sh
./setup.sh
```

## Update
```bash
chmod +x update.sh
./update.sh
```
