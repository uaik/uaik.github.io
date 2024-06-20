#!/usr/bin/env -S bash -e

# Apps.
curl=$( command -v 'curl' )
sed=$( command -v 'sed' )

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() {
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
  run() { repo && conf; }

  repo() {
    local d='/etc/apt/sources.list.d'; [[ ! -d "${d}" ]] && exit 1
    ${curl} -fsSLo "${d}/debian.backports.sources" 'https://uaik.github.io/conf/apt/example.sources' \
      && ${sed} -i \
        -e "s|<name>|Debian Backports|g" \
        -e "s|<types>|deb|g" \
        -e "s|<uri>|http://deb.debian.org/${osId}|g" \
        -e "s|<suites>|${osCodeName}-backports|g" \
        -e "s|<components>|main contrib non-free|g" \
        -e "s|<arch>|$( dpkg --print-architecture )|g" \
        -e "s|Signed-By:|# Signed-By:|g" \
        "${d}/debian.backports.sources"
  }

  conf() {
    local d='/etc/apt/apt.conf.d'; [[ ! -d "${d}" ]] && exit 1
    ${curl} -fsSLo "${d}/00InstallSuggests" 'https://uaik.github.io/conf/apt/00InstallSuggests'
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
