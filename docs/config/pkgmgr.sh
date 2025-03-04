#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
OS_CODENAME="$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )"; readonly OS_CODENAME

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  case "${OS_ID}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { repo && config && update; }

  repo() {
    local d; d='/etc/apt/sources.list.d'; [[ ! -d "${d}" ]] && exit 1

    curl -fsSLo "${d}/debian.backports.sources" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Debian Backports|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|http://deb.debian.org/${OS_ID}|g" \
        -e "s|<#_suites_#>|${OS_CODENAME}-backports|g" \
        -e "s|<#_components_#>|main contrib non-free|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|Signed-By:  |# Signed-By:|g" \
        "${d}/debian.backports.sources"
  }

  config() {
    local d; d='/etc/apt/apt.conf.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=( '00InstallSuggests' '99proxy' )

    for i in "${f[@]}"; do
      [[ ! -f "${d}/${i}" ]] && curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/apt/${i}"
    done
  }

  update() { apt update; }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
