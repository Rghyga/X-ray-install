#!/usr/bin/env bash
set -euo pipefail
source /etc/katsu/lib/ssh.sh
while true; do dashboard; box "SSH Management"; printf " [1] Add\n [2] Delete\n [3] List\n [4] Renew\n [5] Trial\n [6] Set Limit IP\n [7] Check Online\n [0] Back\n"; line; printf " Select Menu : "; read -r opt; case "$opt" in 1) ssh_add ;; 2) ssh_del ;; 3) ssh_list ;; 4) ssh_renew ;; 5) ssh_trial ;; 6) ssh_limit ;; 7) ssh_online ;; 0) exit 0 ;; esac; done
