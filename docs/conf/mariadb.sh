#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
curl=$( command -v 'curl' ); cmd_check 'curl'
sed=$( command -v 'sed' ); cmd_check 'sed'

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

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
  run() { repo '11.4' && service; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='mariadb.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='mariadb.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://mariadb.org/mariadb_release_signing_key.pgp'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#name#>|MariaDB|g" \
        -e "s|<#enabled#>|yes|g" \
        -e "s|<#types#>|deb|g" \
        -e "s|<#uri#>|https://mirror.netcologne.de/mariadb/repo/${1}/${osId}|g" \
        -e "s|<#suites#>|${osCodeName}|g" \
        -e "s|<#components#>|main|g" \
        -e "s|<#arch#>|$( dpkg --print-architecture )|g" \
        -e "s|<#sig#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  service() {
    local d='/etc/systemd/system/mariadb.service.d'; [[ ! -d "${d}" ]] && exit 1

    local f=( 'homedir.conf' 'limits.conf' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/mariadb/service.${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
