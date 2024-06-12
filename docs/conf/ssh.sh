#!/usr/bin/env -S bash -e

init() {
  # Apps.
  cat="$( command -v cat )"

  # Run.
  ssh
}

ssh() {
  [[ ! -d '/etc/ssh/sshd_config.d' ]] && { echo "Directory '/etc/ssh/sshd_config.d' not found!"; exit 1; }

  ${cat} > '/etc/ssh/sshd_config.d/00-sshd.local.conf' <<EOF
Port 8022
IgnoreRhosts yes
MaxAuthTries 2
PermitEmptyPasswords no
PermitRootLogin no
X11Forwarding no
EOF
}

init "$@"; exit 0
