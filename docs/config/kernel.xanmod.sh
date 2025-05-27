#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID

function debian() {
  function repo() {
    local sig; sig='/etc/apt/keyrings/kernel.xanmod.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/kernel.xanmod.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://dl.xanmod.org/archive.key'
    curl -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/kernel/xanmod.sources'
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
