#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

function sshd_config() {
  local d; d='/etc/ssh/sshd_config.d'; [[ ! -d "${d}" ]] && exit 1
  local f; f=('90-sshd.local.conf')
  for i in "${f[@]}"; do
    curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/ssh/${i}"
  done
}

function main() {
  sshd_config
}; main "$@"
