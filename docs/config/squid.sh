#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  case "${OS_ID}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { install && config && service; }

  install() {
    local p; p=('squid')

    apt update \
      && apt install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/squid'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('squid.conf' 'users.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/squid/${i}"
    done
  }

  service() {
    local s; s=('squid')

    for i in "${s[@]}"; do
      systemctl restart "${i}.service"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
