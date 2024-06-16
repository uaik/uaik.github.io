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
    repo && conf
  }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='php.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='php.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://packages.sury.org/php/apt.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}"
    ${cat} > "${list_d}/${list_f}" \
<<EOF
X-Repolib-Name: PHP (Sury)
Enabled:        yes
Types:          deb
URIs:           https://packages.sury.org/php
Suites:         ${osCodeName}
Components:     main
Architectures:  $( dpkg --print-architecture )
Signed-By:      ${gpg_d}/${gpg_f}
EOF
  }

  conf() {
    if [[ -d '/etc/php/8.3/apache2/conf.d' ]]; then
      ${curl} -fsSLo '/etc/php/8.3/apache2/conf.d/php.local.ini' 'https://uaik.github.io/conf/php/php.local.ini'
    fi
  }

  init
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
