#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  cat=$( command -v cat )
  curl=$( command -v curl )

  # OS.
  osId=$( . '/etc/os-release' && echo "${ID}" )
  osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

  # Run.
  [[ "${osId}" == 'debian' ]] && { debian; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  init() {
    aptSources '11.4'
  }

  aptSources() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='mariadb.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='mariadb.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://mariadb.org/mariadb_release_signing_key.pgp'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}"
    ${cat} > "${list_d}/${list_f}" <<EOF
X-Repolib-Name: MariaDB
Enabled:        yes
Types:          deb
URIs:           https://mirror.netcologne.de/mariadb/repo/${1}/${osId}
Suites:         ${osCodeName}
Components:     main
Architectures:  $( dpkg --print-architecture )
Signed-By:      ${gpg_d}/${gpg_f}
EOF
  }

  init
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
