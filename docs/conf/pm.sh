#!/usr/bin/env -S bash -e

init() {
  osId=$( awk -F '=' '$1=="ID" { print $2 }' /etc/os-release )
  osCodeName=$( awk -F '=' '$1=="VERSION_CODENAME" { print $2 }' /etc/os-release )
  [[ "${osId}" == 'debian' ]] && { debianAptConf && debianAptSources; }
}

debianAptConf() {
  local d
  [[ -d '/etc/apt/apt.conf.d' ]] && { d='/etc/apt/apt.conf.d'; } || exit 1

  echo 'APT::Install-Suggests "false";' \
    > "${d}/00InstallSuggests"
}

debianAptSources() {
  local d
  [[ -d '/etc/apt/sources.list.d' ]] && { d='/etc/apt/sources.list.d'; } || exit 1

  echo "deb http://deb.debian.org/debian ${osCodeName}-backports main contrib non-free" \
    > "${d}/debian.backports.list"
}

init "$@"; exit 0
