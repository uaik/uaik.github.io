#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
OS_CODENAME="$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )"; readonly OS_CODENAME

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
  run() { orig && repo && config && update; }

  orig() {
    local d; d='/etc/apt'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('sources.list')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
    done
  }

  repo() {
    local d; d='/etc/apt/sources.list.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('debian.sources'); [[ -x "$( command -v 'pveversion' )" ]] && f+=('proxmox.sources')

    for i in "${f[@]}"; do
      [[ ! -f "${d}/${i}" ]] && curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/apt/${i}" \
        && sed -i -e "s|<#_suites_#>|${OS_CODENAME}|g" "${d}/${i}"
    done
  }

  config() {
    local d; d='/etc/apt/apt.conf.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('00InstallRecommends' '00InstallSuggests' '99proxy')

    for i in "${f[@]}"; do
      [[ ! -f "${d}/${i}" ]] && curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/apt/${i}"
    done
  }

  update() { apt update; }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
