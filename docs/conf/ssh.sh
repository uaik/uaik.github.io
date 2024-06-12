#!/usr/bin/env -S bash -e

cat="$( command -v cat )"

[[ ! -d '/etc/ssh/sshd_config.d' ]] && { exit 1; }

${cat} > '/etc/ssh/sshd_config.d/00-sshd.local.conf' <<EOF
Port 8022
IgnoreRhosts yes
MaxAuthTries 2
PermitEmptyPasswords no
PermitRootLogin no
X11Forwarding no
EOF
