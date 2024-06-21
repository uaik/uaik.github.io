#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
curl=$( command -v 'curl' ); cmd_check 'curl'
gpg=$( command -v 'gpg' ); cmd_check 'gpg'
sed=$( command -v 'sed' ); cmd_check 'sed'

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

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
  run() { repo; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='kernel.xanmod.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='kernel.xanmod.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://dl.xanmod.org/archive.key'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/template.sources' \
      && ${sed} -i \
        -e "s|<name>|Kernel (XanMod)|g" \
        -e "s|<enabled>|yes|g" \
        -e "s|<types>|deb|g" \
        -e "s|<uri>|http://deb.xanmod.org|g" \
        -e "s|<suites>|releases|g" \
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
