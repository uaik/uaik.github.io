#!/usr/bin/env -S bash -e

init() {
  awk="$( command -v awk )"
  curl="$( command -v curl )"
  osId=$( ${awk} -F '=' '$1=="ID" { print $2 }' /etc/os-release )
  osCodeName=$( ${awk} -F '=' '$1=="VERSION_CODENAME" { print $2 }' /etc/os-release )

  [[ "${osId}" == 'debian' ]] && { debianPhp; }
}

debianPhp() {
  local gpg_d; local gpg_f; local list_d; local list_f

  [[ -d '/etc/apt/trusted.gpg.d' ]] && { gpg_d='/etc/apt/trusted.gpg.d'; gpg_f='php.gpg'; } || exit 1
  [[ -d '/etc/apt/sources.list.d' ]] && { list_d='/etc/apt/sources.list.d'; list_f='php.list'; } || exit 1

  ${curl} -sSLo "${gpg_d}/${gpg_f}" 'https://packages.sury.org/php/apt.gpg'
  echo "deb [signed-by=${gpg_d}/${gpg_f}] https://packages.sury.org/php/ ${osCodeName} main" \
    > "${list_d}/${list_f}"
}

init "$@"; exit 0
