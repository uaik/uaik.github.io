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
  run() { repo && apt && conf; }

  repo() {
    local d; d='/etc/apt/sources.list.d'; [[ ! -d "${d}" ]] && exit 1
    ${curl} -fsSLo "${d}/debian.backports.sources" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Debian Backports|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|http://deb.debian.org/${osId}|g" \
        -e "s|<#_suites_#>|${osCodeName}-backports|g" \
        -e "s|<#_components_#>|main contrib non-free|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|Signed-By:  |# Signed-By:|g" \
        "${d}/debian.backports.sources"
  }

  apt() { ${apt} update; }

  conf() {
    local d; d='/etc/apt/apt.conf.d'; [[ ! -d "${d}" ]] && exit 1

    local f; f=( '00InstallSuggests' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/apt/${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
