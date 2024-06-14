#!/usr/bin/env -S bash -e

init() {
  # Apps.
  awk="$( command -v awk )"
  curl="$( command -v curl )"
  gpg="$( command -v gpg )"

  # OS.
  osId=$( ${awk} -F '=' '$1=="ID" { print $2 }' /etc/os-release )
  osCodeName=$( ${awk} -F '=' '$1=="VERSION_CODENAME" { print $2 }' /etc/os-release )

  # Run.
  [[ "${osId}" == 'debian' ]] && { debianHAProxy; }
}

debianHAProxy() {
  local gpg_d; local gpg_f; local list_d; local list_f
  [[ -d '/etc/apt/keyrings' ]] && { gpg_d='/etc/apt/keyrings'; gpg_f='haproxy.gpg'; } || exit 1
  [[ -d '/etc/apt/sources.list.d' ]] && { list_d='/etc/apt/sources.list.d'; list_f='haproxy.list'; } || exit 1

  ${curl} -sSL 'https://haproxy.debian.net/bernat.debian.org.gpg' \
    | ${gpg} --dearmor > "${gpg_d}/${gpg_f}"
  echo "deb [signed-by=${gpg_d}/${gpg_f}] http://haproxy.debian.net ${osCodeName}-backports-3.0 main" \
    > "${list_d}/${list_f}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
