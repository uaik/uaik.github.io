#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID

function debian() {
  function config() {
    local d; d='/etc'
    local f; f=('nftables.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" 'https://uaik.github.io/config/nft/nftables.conf' && chmod +x "${d}/${i}"
    done
  }

  function service() {
    local s; s=('nftables')
    systemctl enable "${s[@]/%/.service}"
  }

  function main() {
    config && service
  }; main
}

function main() {
  case "${OS_ID}" in
    'debian') debian ;;
    *) echo >&2 'OS is not supported!'; exit 1 ;;
  esac
}; main "$@"
