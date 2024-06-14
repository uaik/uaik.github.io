#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  awk="$( command -v awk )"
  curl="$( command -v curl )"
  gpg="$( command -v gpg )"

  # OS.
  osId=$( ${awk} -F '=' '$1=="ID" { print $2 }' /etc/os-release )
  osCodeName=$( ${awk} -F '=' '$1=="VERSION_CODENAME" { print $2 }' /etc/os-release )

  # Run.
  [[ "${osId}" == 'debian' ]] && { debian '3.0'; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN / HAPROXY.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  local gpg_d='/etc/apt/keyrings'; local gpg_f='haproxy.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
  local list_d='/etc/apt/sources.list.d'; local list_f='haproxy.list'; [[ ! -d "${list_d}" ]] && exit 1

  ${curl} -sSL 'https://haproxy.debian.net/bernat.debian.org.gpg' \
    | ${gpg} --dearmor > "${gpg_d}/${gpg_f}"
  echo "deb [signed-by=${gpg_d}/${gpg_f}] http://haproxy.debian.net ${osCodeName}-backports-${1} main" \
    > "${list_d}/${list_f}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
