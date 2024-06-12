#!/usr/bin/env -S bash -e

init() {
  # Apps.
  awk="$( command -v awk )"
  cat="$( command -v cat )"
  mv="$( command -v mv )"
  systemctl="$( command -v systemctl )"

  # Run.
  systemd-networkd
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD-NETWORKD.
# -------------------------------------------------------------------------------------------------------------------- #

systemd-networkd() {
  local eth; mapfile -t eth < <( ip -br l | ${awk} '$1 !~ "lo|vir|wl" { print $1 }' )

  for i in "${eth[@]}"; do
    ${cat} > "/etc/systemd/network/${i}.network" <<EOF
[Match]
Name=${i}

[Network]
DHCP=ipv4
EOF
  done

  ${systemctl} enable systemd-networkd \
    && ${mv} '/etc/network/interfaces' '/etc/network/interfaces.save'
}

init "$@"; exit 0
