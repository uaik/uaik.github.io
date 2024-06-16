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
  case "${osId}" in
    'debian')
      debian
      ;;
    *)
      echo 'OS is not supported!' && exit 1
      ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  init() {
    repo '11.4' && conf
  }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='mariadb.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='mariadb.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://mariadb.org/mariadb_release_signing_key.pgp'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}"
    ${cat} > "${list_d}/${list_f}" \
<<EOF
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

  conf() {
    if [[ -d '/etc/systemd/system/mariadb.service.d' ]]; then
      ${curl} -fsSLo '/etc/systemd/system/mariadb.service.d/service.homedir.conf' \
        'https://uaik.github.io/conf/mariadb/service.homedir.conf'
      ${curl} -fsSLo '/etc/systemd/system/mariadb.service.d/service.limits.conf' \
        'https://uaik.github.io/conf/mariadb/service.limits.conf'
    fi
  }

  init
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
