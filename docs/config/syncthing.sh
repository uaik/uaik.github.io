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
  run() { repo && install && config; }

  repo() {
    local sig; sig='/etc/apt/keyrings/syncthing.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/syncthing.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://syncthing.net/release-key.gpg'

    curl -fsSLo "${sig}" "${key}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Syncthing|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://apt.syncthing.net|g" \
        -e "s|<#_suites_#>|syncthing|g" \
        -e "s|<#_components_#>|stable|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local d; d='/etc/apt/preferences.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('syncthing.pref')
    local p; p=('syncthing')

    for i in "${f[@]}"; do
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/syncthing/debian.apt.${i}"
    done

    apt update && apt install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/systemd/system'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('syncthing@.service')

    for i in "${f[@]}"; do
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/syncthing/debian.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
