#!/usr/bin/env -S bash -e

# Apps.
curl=$( command -v 'curl' )
gpg=$( command -v 'gpg' )
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
  run() { repo '8.4-lts' && conf; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='mysql.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='mysql.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://uaik.github.io/conf/mysql/mysql.asc'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/example.sources' \
      && ${sed} -i \
        -e "s|<name>|MySQL|g" \
        -e "s|<types>|deb|g" \
        -e "s|<uri>|http://repo.mysql.com/apt/${osId}|g" \
        -e "s|<suites>|${osCodeName}|g" \
        -e "s|<components>|mysql-${1}|g" \
        -e "s|<arch>|$( dpkg --print-architecture )|g" \
        -e "s|<sig>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  conf() {
    if [[ -d '/etc/systemd/system/mysql.service.d' ]]; then
      ${curl} -fsSLo '/etc/systemd/system/mysql.service.d/service.limits.conf' \
        'https://uaik.github.io/conf/mysql/service.limits.conf'
    fi
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
