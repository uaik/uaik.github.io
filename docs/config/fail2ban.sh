#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  case "${osId}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { install && config && jail && service; }

  install() {
    local p; p='fail2ban'

    apt update \
      && apt install --yes ${p}
  }

  config() {
    local d; d='/etc/fail2ban'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('fail2ban.local' 'jail.local')

    for i in "${f[@]}"; do
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/fail2ban/${i}"
    done

    [[ ! -d '/var/log/fail2ban' ]] && mkdir '/var/log/fail2ban'
  }

  jail() {
    local d; d='/etc/fail2ban/jail.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('sshd.local')

    for i in "${f[@]}"; do
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/fail2ban/jail.${i}"
    done
  }

  service() {
    local d; d='/etc/systemd/system/fail2ban.service.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('service.override.conf')

    for i in "${f[@]}"; do
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/fail2ban/service.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
