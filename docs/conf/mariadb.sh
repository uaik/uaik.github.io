#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  awk="$( command -v awk )"
  curl="$( command -v curl )"

  # OS.
  osId=$( ${awk} -F '=' '$1=="ID" { print $2 }' /etc/os-release )
  osCodeName=$( ${awk} -F '=' '$1=="VERSION_CODENAME" { print $2 }' /etc/os-release )

  # Run.
  [[ "${osId}" == 'debian' ]] && { debianMariaDB '11.4'; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN / MARIADB.
# -------------------------------------------------------------------------------------------------------------------- #

debianMariaDB() {
  local gpg_d='/etc/apt/keyrings'; local gpg_f='mariadb.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
  local list_d='/etc/apt/sources.list.d'; local list_f='mariadb.list'; [[ ! -d "${list_d}" ]] && exit 1

  ${curl} -sSLo "${gpg_d}/${gpg_f}" 'https://mariadb.org/mariadb_release_signing_key.pgp'
  echo "deb [signed-by=${gpg_d}/${gpg_f}] https://mirror.netcologne.de/mariadb/repo/${1}/${osId} ${osCodeName} main" \
    > "${list_d}/${list_f}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
