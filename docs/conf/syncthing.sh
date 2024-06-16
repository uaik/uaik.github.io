#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  curl=$( command -v curl )
  sed=$( command -v sed )

  # OS.
  osId=$( . '/etc/os-release' && echo "${ID}" )

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
    repo
  }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='syncthing.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='syncthing.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://syncthing.net/release-key.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/example.sources' \
      && ${sed} -i \
        -e "s|<name>|Syncthing|g" \
        -e "s|<types>|deb|g" \
        -e "s|<uri>|https://apt.syncthing.net|g" \
        -e "s|<suites>|syncthing|g" \
        -e "s|<components>|stable|g" \
        -e "s|<arch>|$( dpkg --print-architecture )|g" \
        -e "s|<sig>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  init
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
