#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
curl=$( command -v 'curl' ); cmd_check 'curl'
sed=$( command -v 'sed' ); cmd_check 'sed'

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

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
    local d='/etc/apt/sources.list.d'; [[ ! -d "${d}" ]] && exit 1
    ${curl} -fsSLo "${d}/debian.backports.sources" 'https://uaik.github.io/conf/apt/template.sources' \
      && ${sed} -i \
        -e "s|<name>|Debian Backports|g" \
        -e "s|<enabled>|yes|g" \
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

    local f=( '00InstallSuggests' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/apt/${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
