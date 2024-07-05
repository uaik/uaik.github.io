#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
sed=$( command -v 'sed' )

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
  run() { repo && apt && config; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='syncthing.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='syncthing.sources'
    local key; key='https://syncthing.net/release-key.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Syncthing|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://apt.syncthing.net|g" \
        -e "s|<#_suites_#>|syncthing|g" \
        -e "s|<#_components_#>|stable|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local apt_d; apt_d='/etc/apt/preferences.d'; [[ ! -d "${apt_d}" ]] && exit 1
    local apt_f; apt_f=( 'syncthing.pref' )
    for i in "${apt_f[@]}"; do ${curl} -fsSLo "${apt_d}/${i}" "https://uaik.github.io/conf/syncthing/debian.apt.${i}"; done
    local p; p=( 'syncthing' )
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  config() {
    local sys_d; sys_d='/etc/systemd/system'; [[ ! -d "${sys_d}" ]] && exit 1
    local sys_f; sys_f=( 'syncthing@.service' )
    for i in "${sys_f[@]}"; do ${curl} -fsSLo "${sys_d}/${i}" "https://uaik.github.io/conf/syncthing/debian.${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
