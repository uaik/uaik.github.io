#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# Apps.
chmod=$( command -v 'chmod' )
curl=$( command -v 'curl' )
mv=$( command -v 'mv' )
systemctl=$( command -v 'systemctl' )

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
  run() { config && service; }

  config() {
    local d; d='/etc'
    local f; f=('nftables.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" 'https://uaik.github.io/conf/nft/nftables.conf' && ${chmod} +x "${d}/${i}"
    done
  }

  service() {
    local s; s=('nftables')

    for i in "${s[@]}"; do
      ${systemctl} enable "${i}.service"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1