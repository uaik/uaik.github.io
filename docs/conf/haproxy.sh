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
    repo '3.0'
  }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='haproxy.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='haproxy.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://haproxy.debian.net/bernat.debian.org.gpg'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}"
    ${cat} > "${list_d}/${list_f}" \
<<EOF
Enabled:        yes
Types:          deb
URIs:           http://haproxy.debian.net
Suites:         ${osCodeName}-backports-${1}
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
