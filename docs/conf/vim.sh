#!/usr/bin/env -S bash -e

cat="$( command -v cat )"

[[ ! -d '/etc/vim' ]] && { exit 1; }

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
