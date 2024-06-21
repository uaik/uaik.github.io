#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
apt=$( command -v 'apt' ); cmd_check 'apt'
curl=$( command -v 'curl' ); cmd_check 'curl'
gpg=$( command -v 'gpg' ); cmd_check 'gpg'
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
  run() { repo '8.4-lts' && apt && service; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='mysql.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='mysql.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://uaik.github.io/conf/mysql/mysql.asc'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<# name #>|MySQL|g" \
        -e "s|<# enabled #>|yes|g" \
        -e "s|<# types #>|deb|g" \
        -e "s|<# uri #>|http://repo.mysql.com/apt/${osId}|g" \
        -e "s|<# suites #>|${osCodeName}|g" \
        -e "s|<# components #>|mysql-${1}|g" \
        -e "s|<# arch #>|$( dpkg --print-architecture )|g" \
        -e "s|<# sig #>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p='mysql-server'
    ${apt} update && ${apt} install --yes ${p}
  }

  service() {
    local d='/etc/systemd/system/mysql.service.d'; [[ ! -d "${d}" ]] && exit 1

    local f=( 'limits.conf' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/mysql/service.${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
