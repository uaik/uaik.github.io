#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

function sysctl_config() {
  local d; d='/etc/sysctl.d'; [[ ! -d "${d}" ]] && exit 1
  local f; f=('90-sysctl.local.conf')
  for i in "${f[@]}"; do curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/sysctl/${i}"; done
}

function main() {
  sysctl_config
}; main "$@"
