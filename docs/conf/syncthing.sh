#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
apt=$( command -v 'apt' ); cmd_check 'apt'
curl=$( command -v 'curl' ); cmd_check 'curl'
sed=$( command -v 'sed' ); cmd_check 'sed'

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
  run() { repo && apt && conf; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='syncthing.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='syncthing.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://syncthing.net/release-key.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#name#>|Syncthing|g" \
        -e "s|<#enabled#>|yes|g" \
        -e "s|<#types#>|deb|g" \
        -e "s|<#uri#>|https://apt.syncthing.net|g" \
        -e "s|<#suites#>|syncthing|g" \
        -e "s|<#components#>|stable|g" \
        -e "s|<#arch#>|$( dpkg --print-architecture )|g" \
        -e "s|<#sig#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() { ${apt} update; }

  conf() {
    local sys_d='/etc/systemd/system'; [[ ! -d "${sys_d}" ]] && exit 1
    local sys_f=( 'syncthing@.service' )
    for i in "${sys_f[@]}"; do ${curl} -fsSLo "${sys_d}/${i}" "https://uaik.github.io/conf/syncthing/${i}"; done

    local apt_d='/etc/apt/preferences.d'; [[ ! -d "${apt_d}" ]] && exit 1
    local apt_f=( 'syncthing.pref' )
    for i in "${apt_f[@]}"; do ${curl} -fsSLo "${apt_d}/${i}" "https://uaik.github.io/conf/syncthing/${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
