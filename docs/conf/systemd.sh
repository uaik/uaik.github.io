#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
apt=$( command -v 'apt' ); cmd_check 'apt'
awk=$( command -v 'awk' ); cmd_check 'awk'
curl=$( command -v 'curl' ); cmd_check 'curl'
mv=$( command -v 'mv' ); cmd_check 'mv'
sed=$( command -v 'sed' ); cmd_check 'sed'
shutdown=$( command -v 'shutdown' ); cmd_check 'shutdown'
systemctl=$( command -v 'systemctl' ); cmd_check 'systemctl'

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() { networkd && resolved && reboot; }

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD / NETWORKD.
# -------------------------------------------------------------------------------------------------------------------- #

networkd() {
  local d='/etc/systemd/network'; [[ ! -d "${d}" ]] && exit 1

  local e; mapfile -t e < <( ip -br l | ${awk} '$1 !~ "lo|vir|wl" { print $1 }' )
  for i in "${e[@]}"; do
    ${curl} -fsSLo "${d}/${i}.network" 'https://uaik.github.io/conf/systemd/dhcp.network.tpl' \
      && ${sed} -i -e "s|<# name #>|${i}|g" "${d}/${i}.network"
  done

  local s='systemd-networkd'; ${systemctl} enable ${s}
  [[ -f '/etc/network/interfaces' ]] && { ${mv} '/etc/network/interfaces' '/etc/network/interfaces.disable'; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEMD / RESOLVED.
# -------------------------------------------------------------------------------------------------------------------- #

resolved() {
  local s='systemd-resolved'
  ${apt} install --yes ${s} && ${systemctl} enable ${s}
}

# -------------------------------------------------------------------------------------------------------------------- #
# REBOOT.
# -------------------------------------------------------------------------------------------------------------------- #

reboot() {
  ${shutdown} -r now
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
