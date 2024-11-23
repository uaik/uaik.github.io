#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID=$( . '/etc/os-release' && echo "${ID}" ); readonly OS_ID
OS_CODENAME=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" ); readonly OS_CODENAME

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
  run() { repo '3.0' && install '3.0'; }

  repo() {
    local sig; sig='/etc/apt/keyrings/haproxy.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/haproxy.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://haproxy.debian.net/bernat.debian.org.gpg'

    curl -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|HAProxy|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|http://haproxy.debian.net|g" \
        -e "s|<#_suites_#>|${OS_CODENAME}-backports-${1}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=("haproxy=${1}.\*")

    apt update && apt install --yes "${p[@]}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
