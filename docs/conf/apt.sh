#!/usr/bin/env -S bash -e

init() {
  # Run.
  apt
}

apt() {
  local osId; osId=$( awk -F '=' '$1=="ID" { print $2 }' /etc/os-release )
  local osCodeName; osCodeName=$( awk -F '=' '$1=="VERSION_CODENAME" { print $2 }' /etc/os-release )

  if [[ "${osId}" != 'debian' ]] && [[ ! -d '/etc/apt' ]]; then
    echo "It's not Debian!"
    echo "Directory '/etc/apt' not found!"
    exit 1
  fi

  echo 'APT::Install-Suggests "false";' \
    > '/etc/apt/apt.conf.d/00InstallSuggests'

  echo "deb http://deb.debian.org/debian ${osCodeName}-backports main contrib non-free" \
    > /etc/apt/sources.list.d/debian.backports.list
}

init "$@"; exit 0
