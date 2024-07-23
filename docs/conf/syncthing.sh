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
    local sig; sig='/etc/apt/keyrings/syncthing.gpg'; [[ ! -d "${sig}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/syncthing.sources'; [[ ! -d "${src}" ]] && exit 1
    local key; key='https://syncthing.net/release-key.gpg'

    ${curl} -fsSLo "${sig}" "${key}" \
      && ${curl} -fsSLo "${src}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
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

  apt() {
    local apt_d; apt_d='/etc/apt/preferences.d'; [[ ! -d "${apt_d}" ]] && exit 1
    local apt_f; apt_f=('syncthing.pref')
    for i in "${apt_f[@]}"; do ${curl} -fsSLo "${apt_d}/${i}" "https://uaik.github.io/conf/syncthing/debian.apt.${i}"; done
    local p; p=('syncthing')
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  config() {
    local sys_d; sys_d='/etc/systemd/system'; [[ ! -d "${sys_d}" ]] && exit 1
    local sys_f; sys_f=('syncthing@.service')
    for i in "${sys_f[@]}"; do ${curl} -fsSLo "${sys_d}/${i}" "https://uaik.github.io/conf/syncthing/debian.${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
