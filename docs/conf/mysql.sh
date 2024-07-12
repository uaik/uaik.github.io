#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
gpg=$( command -v 'gpg' )
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
  run() { repo '8.4-lts' && apt && service; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='mysql.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='mysql.sources'
    local key; key='https://uaik.github.io/conf/mysql/mysql.asc'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|MySQL|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|http://repo.mysql.com/apt/${osId}|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|mysql-${1}|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p; p=('mysql-server')
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  service() {
    local d; d='/etc/systemd/system/mysql.service.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('limits.conf')
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/mysql/service.${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
