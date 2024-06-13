#!/usr/bin/env -S bash -e

init() {
  cat="$( command -v cat )"
  vim
}

vim() {
  local d; local f
  [[ -d '/etc/vim' ]] && { d='/etc/vim'; f='vimrc.local'; } || exit 1

  ${cat} > "${d}/${f}" <<EOF
filetype plugin on
syntax on
set nobackup
set nowritebackup
set noswapfile
set tabstop=2
set expandtab
set ruler
set mouse-=a
set paste
EOF
}

init "$@"; exit 0
