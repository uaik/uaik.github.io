#!/usr/bin/env -S bash -e

# Apps.
sed=$( command -v 'sed' )
curl=$( command -v 'curl' )

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
  run() { repo '11.4' && conf; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='mariadb.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='mariadb.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://mariadb.org/mariadb_release_signing_key.pgp'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/example.sources' \
      && ${sed} -i \
        -e "s|<name>|MariaDB|g" \
        -e "s|<types>|deb|g" \
        -e "s|<uri>|https://mirror.netcologne.de/mariadb/repo/${1}/${osId}|g" \
        -e "s|<suites>|${osCodeName}|g" \
        -e "s|<components>|main|g" \
        -e "s|<arch>|$( dpkg --print-architecture )|g" \
        -e "s|<sig>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  conf() {
    if [[ -d '/etc/systemd/system/mariadb.service.d' ]]; then
      ${curl} -fsSLo '/etc/systemd/system/mariadb.service.d/service.homedir.conf' \
        'https://uaik.github.io/conf/mariadb/service.homedir.conf'
      ${curl} -fsSLo '/etc/systemd/system/mariadb.service.d/service.limits.conf' \
        'https://uaik.github.io/conf/mariadb/service.limits.conf'
    fi
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
