#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
curl=$( command -v 'curl' ); cmd_check 'curl'

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
  run() { conf && jail && service; }

  conf() {
    local d='/etc/fail2ban'; [[ ! -d "${d}" ]] && exit 1

    local f=( 'fail2ban.local' 'jail.local' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/fail2ban/${i}"; done

    [[ ! -d '/var/log/fail2ban' ]] && mkdir '/var/log/fail2ban'
  }

  jail() {
    local d='/etc/fail2ban/jail.d'; [[ ! -d "${d}" ]] && exit 1

    local f=( 'sshd.local' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/fail2ban/jail.${i}"; done
  }

  service() {
    local d='/etc/systemd/system/fail2ban.service.d'; [[ ! -d "${d}" ]] && exit 1

    local f=( 'service.override.conf' )
    for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/fail2ban/service.${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
