#!/usr/bin/env -S bash -e

cat="$( command -v cat )"

echo 'APT::Install-Suggests "false";' \
  > '/etc/apt/apt.conf.d/00InstallSuggests'

echo 'deb http://deb.debian.org/debian bookworm-backports main contrib non-free' \
  > /etc/apt/sources.list.d/debian.backports.list
