#!/usr/bin/env -S bash -e

init() {
  # Apps.
  cat="$( command -v cat )"

  # Run.
  vim
}

vim() {
  [[ ! -d '/etc/vim' ]] && { echo "Directory '/etc/vim' not found!"; exit 1; }

  ${cat} > '/etc/vim/vimrc.local' <<EOF
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
