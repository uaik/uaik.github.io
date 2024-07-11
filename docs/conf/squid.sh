#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
mv=$( command -v 'mv' )
systemctl=$( command -v 'systemctl' )

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
  run() { apt && config && config_ext && service; }

  apt() {
    local p; p=( 'squid' )
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/squid'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('squid.conf' 'users.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/squid/${i}"
    done
  }

  config_ext() {
    local d; d='/etc/squid/conf.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('acl.dnf_yum.conf' 'main.extended.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/squid/${i}"
    done
  }

  service() {
    local s; s=( 'squid.service' )
    for i in "${s[@]}"; do ${systemctl} restart "${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
