#!/usr/bin/env -S bash -e

init() {
  apt="$( command -v apt )"
  awk="$( command -v awk )"
  cat="$( command -v cat )"
  mv="$( command -v mv )"
  systemctl="$( command -v systemctl )"
  systemd-networkd && systemd-resolved
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD-NETWORKD.
# -------------------------------------------------------------------------------------------------------------------- #

systemd-networkd() {
  local d
  [[ -d '/etc/systemd/network' ]] && { d='/etc/systemd/network'; } || exit 1

  local eth
  mapfile -t eth < <( ip -br l | ${awk} '$1 !~ "lo|vir|wl" { print $1 }' )

  for i in "${eth[@]}"; do
    ${cat} > "${d}/${i}.network" <<EOF
[Match]
Name=${i}

[Network]
DHCP=ipv4
EOF
  done

  ${systemctl} enable systemd-networkd \
    && ${mv} '/etc/network/interfaces' '/etc/network/interfaces.disable'
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD-RESOLVED.
# -------------------------------------------------------------------------------------------------------------------- #

systemd-resolved() {
  ${apt} install --yes systemd-resolved
}

init "$@"; exit 0
