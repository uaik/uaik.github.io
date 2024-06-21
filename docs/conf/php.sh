#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
apt=$( command -v 'apt' ); cmd_check 'apt'
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
  run() { repo && apt '8.3' && conf '8.3'; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='php.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='php.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://packages.sury.org/php/apt.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|PHP (Sury)|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.sury.org/php|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p=(
      "php${1}"
      "php${1}-bz2"
      "php${1}-cli"
      "php${1}-common"
      "php${1}-curl"
      "php${1}-fpm"
      "php${1}-gd"
      "php${1}-gmp"
      "php${1}-imagick"
      "php${1}-imap"
      "php${1}-intl"
      "php${1}-mbstring"
      "php${1}-memcached"
      "php${1}-mysql"
      "php${1}-odbc"
      "php${1}-opcache"
      "php${1}-pgsql"
      "php${1}-redis"
      "php${1}-uploadprogress"
      "php${1}-xml"
      "php${1}-zip"
      "php${1}-zstd"
    )
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  conf() {
    local d="/etc/php/${1}/apache2/conf.d"; [[ ! -d "${d}" ]] && exit 1

    local f=( 'php.local.ini' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/php/${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
