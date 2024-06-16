#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  curl=$( command -v curl )

  # Run.
  vim
}

# -------------------------------------------------------------------------------------------------------------------- #
# VIM.
# -------------------------------------------------------------------------------------------------------------------- #

vim() {
  local d='/etc/vim'; [[ ! -d "${d}" ]] && exit 1
  local f='vimrc.local'

  ${curl} -fsSLo "${d}/${f}" "https://uaik.github.io/conf/vim/${f}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
