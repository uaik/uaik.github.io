#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
OS_CODENAME="$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )"; readonly OS_CODENAME

function debian() {
  function repo() {
    local sig; sig='/etc/apt/keyrings/kernel.zabbly.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/kernel.zabbly.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://pkgs.zabbly.com/key.asc'
    curl -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/kernel/zabbly.sources' \
      && sed -i -e "s|<#_suites_#>|${OS_CODENAME}|g" "${src}"
  }

  function update() {
    apt update
  }

  function main() {
    repo && update
  }; main
}

function main() {
  case "${OS_ID}" in
    'debian') debian ;;
    *) echo >&2 'OS is not supported!'; exit 1 ;;
  esac
}; main "$@"
