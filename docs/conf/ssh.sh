#!/usr/bin/env -S bash -e

init() {
  cat="$( command -v cat )"
  sshd
}

sshd() {
  local d; local f
  [[ -d '/etc/ssh/sshd_config.d' ]] && { d='/etc/ssh/sshd_config.d'; f='00-sshd.local.conf'; } || exit 1

  ${cat} > "${d}/${f}" <<EOF
Port 8022
IgnoreRhosts yes
MaxAuthTries 2
PermitEmptyPasswords no
PermitRootLogin no
X11Forwarding no
EOF
}

init "$@"; exit 0
