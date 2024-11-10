#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() { config; }

# -------------------------------------------------------------------------------------------------------------------- #
# VIM
# -------------------------------------------------------------------------------------------------------------------- #

config() {
  local d; d='/etc/vim'; [[ ! -d "${d}" ]] && exit 1
  local f; f=('vimrc.local')

  for i in "${f[@]}"; do
    curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/vim/${i}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
