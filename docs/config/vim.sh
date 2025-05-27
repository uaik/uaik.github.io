#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

function config() {
  local d; d='/etc/vim'; [[ ! -d "${d}" ]] && exit 1
  local f; f=('vimrc.local')
  for i in "${f[@]}"; do curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/vim/${i}"; done
}

function main() {
  config
}; main "$@"
