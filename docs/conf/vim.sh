#!/usr/bin/env -S bash -e

# Apps.
curl=$( command -v 'curl' )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() { config; }

# -------------------------------------------------------------------------------------------------------------------- #
# VIM.
# -------------------------------------------------------------------------------------------------------------------- #

config() {
  local d; d='/etc/vim'; [[ ! -d "${d}" ]] && exit 1

  local f; f=( 'vimrc.local' )
  for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/vim/${i}"; done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
