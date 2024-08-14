#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
sed=$( command -v 'sed' )

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
  run() { repo '11.4' && install && service; }

  repo() {
    local sig; sig='/etc/apt/keyrings/mariadb.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/mariadb.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://mariadb.org/mariadb_release_signing_key.pgp'

    ${curl} -fsSLo "${sig}" "${key}" \
      && ${curl} -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|MariaDB|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://mirror.netcologne.de/mariadb/repo/${1}/${osId}|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('mariadb-server')

    ${apt} update \
      && ${apt} install --yes "${p[@]}"
  }

  service() {
    local d; d='/etc/systemd/system/mariadb.service.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('homedir.conf' 'limits.conf')

    for i in "${f[@]}"; do
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/config/mariadb/service.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
