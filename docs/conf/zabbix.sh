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
  run() { repo '7.0' && apt; }

  repo() {
    local gpg; gpg='/etc/apt/keyrings/zabbix.gpg'; [[ ! -d "${gpg%/*}" ]] && exit 1
    local list; list='/etc/apt/sources.list.d/zabbix.sources'; [[ ! -d "${list%/*}" ]] && exit 1
    local key; key='https://repo.zabbix.com/zabbix-official-repo.key'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg}" \
      && ${curl} -fsSLo "${list}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Zabbix|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://repo.zabbix.com/zabbix/${1}/debian|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg}|g" \
        "${list}"
  }

  apt() {
    local d; d='/etc/apt/preferences.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('nodejs.pref' 'nsolid.pref')
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/nodejs/debian.apt.${i}"; done
    local p; p=('nodejs')
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
