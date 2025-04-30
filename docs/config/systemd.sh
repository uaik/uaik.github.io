#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() { ipv6_disable && timesyncd && networkd && resolved; }

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD: NETWORKD
# -------------------------------------------------------------------------------------------------------------------- #

networkd() {
  local d; d='/etc/systemd/network'; [[ ! -d "${d}" ]] && exit 1
  local e; mapfile -t e < <( ip -br l | awk '$1 !~ "lo|vir|wl" { print $1 }' )
  local s; s=('systemd-networkd')

  for i in "${e[@]}"; do
    curl -fsSLo "${d}/${i}.network" 'https://uaik.github.io/config/systemd/networkd.dhcp.tpl' \
      && sed -i -e "s|<#_name_#>|${i}|g" "${d}/${i}.network"
  done

  systemctl enable "${s[@]/%/.service}"
  [[ -f '/etc/network/interfaces' ]] && { mv '/etc/network/interfaces' '/etc/network/interfaces.disable'; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD: RESOLVED
# -------------------------------------------------------------------------------------------------------------------- #

resolved() {
  local d; d='/etc/systemd/resolved.conf.d'; [[ ! -d "${d}" ]] && mkdir -p "${d}"
  local f; f=('local.conf')
  local p; p=('systemd-resolved' 'libnss-resolve')
  local s; s=('systemd-resolved')

  apt update && apt install --yes "${p[@]}" \
    && systemctl enable "${s[@]/%/.service}"

  for i in "${f[@]}"; do
    curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/systemd/resolved.${i}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD: TIMESYNCD
# -------------------------------------------------------------------------------------------------------------------- #

timesyncd() {
  local d; d='/etc/systemd/timesyncd.conf.d'; [[ ! -d "${d}" ]] && mkdir -p "${d}"
  local f; f=('local.conf')

  for i in "${f[@]}"; do
    curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/systemd/timesyncd.${i}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# IPV6: DISABLE
# -------------------------------------------------------------------------------------------------------------------- #

ipv6_disable() {
  local d; d='/etc/systemd/system'; [[ ! -d "${d}" ]] && exit 1
  local f; f=('ipv6-disable.service')

  for i in "${f[@]}"; do
    curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/systemd/${i}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
