#!/usr/bin/env -S bash -e

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
sed=$( command -v 'sed' )

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
  run() { repo && apt '8.3' && config '8.3'; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='php.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='php.sources'
    local key; key='https://packages.sury.org/php/apt.gpg'

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
    local p; p=(
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

  config() {
    local d; d="/etc/php/${1}/fpm/conf.d"; [[ ! -d "${d}" ]] && exit 1

    local f; f=( 'php.local.ini' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/php/${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
