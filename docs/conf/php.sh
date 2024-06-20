#!/usr/bin/env -S bash -e

# Apps.
curl=$( command -v 'curl' )
sed=$( command -v 'sed' )

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" || exit 1 )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" || exit 1 )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  case "${osId}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { repo && conf; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='php.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='php.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://packages.sury.org/php/apt.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/example.sources' \
      && ${sed} -i \
        -e "s|<name>|PHP (Sury)|g" \
        -e "s|<types>|deb|g" \
        -e "s|<uri>|https://packages.sury.org/php|g" \
        -e "s|<suites>|${osCodeName}|g" \
        -e "s|<components>|main|g" \
        -e "s|<arch>|$( dpkg --print-architecture )|g" \
        -e "s|<sig>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  conf() {
    if [[ -d '/etc/php/8.3/apache2/conf.d' ]]; then
      ${curl} -fsSLo '/etc/php/8.3/apache2/conf.d/php.local.ini' 'https://uaik.github.io/conf/php/php.local.ini'
    fi
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
