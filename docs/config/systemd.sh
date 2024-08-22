#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() { networkd && resolved; }

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD / NETWORKD
# -------------------------------------------------------------------------------------------------------------------- #

networkd() {
  local d; d='/etc/systemd/network'; [[ ! -d "${d}" ]] && exit 1
  local e; mapfile -t e < <( ip -br l | awk '$1 !~ "lo|vir|wl" { print $1 }' )
  local s; s='systemd-networkd'

  for i in "${e[@]}"; do
    curl -fsSLo "${d}/${i}.network" 'https://uaik.github.io/config/systemd/dhcp.network.tpl' \
      && sed -i -e "s|<#_name_#>|${i}|g" "${d}/${i}.network"
  done

  systemctl enable "${s}.service"
  [[ -f '/etc/network/interfaces' ]] && { mv '/etc/network/interfaces' '/etc/network/interfaces.disable'; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD / RESOLVED
# -------------------------------------------------------------------------------------------------------------------- #

resolved() {
  local p; p='systemd-resolved'
  local s; s='systemd-resolved'

  apt install --yes ${p} \
    && systemctl enable "${s}.service"
}

# -------------------------------------------------------------------------------------------------------------------- #
# REBOOT
# -------------------------------------------------------------------------------------------------------------------- #

reboot() {
  shutdown -r now
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
