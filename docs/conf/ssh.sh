#!/usr/bin/env -S bash -e

cat="$( command -v cat )"

${cat} > '/etc/ssh/sshd_config.d/00-sshd.local.conf' <<EOF
Port 8022
IgnoreRhosts yes
MaxAuthTries 2
PermitEmptyPasswords no
PermitRootLogin no
X11Forwarding no
EOF
