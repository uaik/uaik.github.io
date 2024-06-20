#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
chmod=$( command -v 'chmod' ); cmd_check 'chmod'
curl=$( command -v 'curl' ); cmd_check 'curl'
mv=$( command -v 'mv' ); cmd_check 'mv'
systemctl=$( command -v 'systemctl' ); cmd_check 'systemctl'

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  case "${osId}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { conf; }

  conf() {
    local f='/etc/nftables.conf'; [[ -f "${f}" && ! -f "${f}.orig" ]] && ${mv} "${f}" "${f}.orig" || exit 1
    ${curl} -fsSLo "${f}" 'https://uaik.github.io/conf/nft/nftables.conf' && ${chmod} +x "${f}"

    local s=( 'nftables' )
    for i in "${s[@]}"; do ${systemctl} enable --now "${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
