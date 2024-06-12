#!/usr/bin/env -S bash -e

os=$( awk -F '=' '$1=="ID" { print $2 }' /etc/os-release )

if [[ "${os}" != 'debian' ]] && [[ ! -d '/etc/apt' ]]; then
  echo "It's not Debian!"
  echo "Directory '/etc/apt' not found!"
  exit 1
fi

echo 'APT::Install-Suggests "false";' \
  > '/etc/apt/apt.conf.d/00InstallSuggests'

echo 'deb http://deb.debian.org/debian bookworm-backports main contrib non-free' \
  > /etc/apt/sources.list.d/debian.backports.list

exit 0
