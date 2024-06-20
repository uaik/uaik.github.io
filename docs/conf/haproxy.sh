#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
curl=$( command -v 'curl' ); cmd_check 'curl'
gpg=$( command -v 'gpg' ); cmd_check 'gpg'
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
  run() { repo '3.0'; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='haproxy.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='haproxy.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://haproxy.debian.net/bernat.debian.org.gpg'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/example.sources' \
      && ${sed} -i \
        -e "s|<name>|HAProxy|g" \
        -e "s|<types>|deb|g" \
        -e "s|<uri>|http://haproxy.debian.net|g" \
        -e "s|<suites>|${osCodeName}-backports-${1}|g" \
        -e "s|<components>|main|g" \
        -e "s|<arch>|$( dpkg --print-architecture )|g" \
        -e "s|<sig>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
