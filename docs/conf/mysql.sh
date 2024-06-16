#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  cat=$( command -v cat )
  curl=$( command -v curl )
  gpg=$( command -v gpg )

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
    repo '8.4-lts' && conf
  }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='mysql.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='mysql.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://uaik.github.io/conf/mysql/mysql.asc'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}"
    ${cat} > "${list_d}/${list_f}" \
<<EOF
X-Repolib-Name: MySQL
Enabled:        yes
Types:          deb
URIs:           http://repo.mysql.com/apt/${osId}
Suites:         ${osCodeName}
Components:     mysql-${1}
Architectures:  $( dpkg --print-architecture )
Signed-By:      ${gpg_d}/${gpg_f}
EOF
  }

  conf() {
    if [[ -d '/etc/systemd/system/mysql.service.d' ]]; then
      ${curl} -fsSLo '/etc/systemd/system/mysql.service.d/service.limits.conf' \
        'https://uaik.github.io/conf/mysql/service.limits.conf'
    fi
  }

  init
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
