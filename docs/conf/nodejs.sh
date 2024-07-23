#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

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
  run() { repo '20.x' && apt; }

  repo() {
    local sig; sig='/etc/apt/keyrings/nodejs.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/nodejs.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${sig}" \
      && ${curl} -fsSLo "${src}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Node.js|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://deb.nodesource.com/node_${1}|g" \
        -e "s|<#_suites_#>|nodistro|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  apt() {
    local apt_d; apt_d='/etc/apt/preferences.d'; [[ ! -d "${apt_d}" ]] && exit 1
    local apt_f; apt_f=('nodejs.pref' 'nsolid.pref')
    for i in "${apt_f[@]}"; do ${curl} -fsSLo "${apt_d}/${i}" "https://uaik.github.io/conf/nodejs/debian.apt.${i}"; done
    local p; p=('nodejs')
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
