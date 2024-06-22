#!/usr/bin/env -S bash -e

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
ln=$( command -v 'ln' )
sed=$( command -v 'sed' )
unlink=$( command -v 'unlink' )

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
  run() { repo && apt && conf && site; }

  repo() {
    local gpg_d='/etc/apt/keyrings'; local gpg_f='apache2.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d='/etc/apt/sources.list.d'; local list_f='apache2.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key='https://packages.sury.org/apache2/apt.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Apache (Sury)|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.sury.org/apache2|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p=( 'apache2' )
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  conf() {
    local d='/etc/apache2/conf-available'; [[ ! -d "${d}" ]] && exit 1

    # Disabled original config.
    for i in '/etc/apache2/conf-enabled/'*; do [[ -L "${i}" ]] && ${unlink} "${i}"; done

    # Install and enabled custom config.
    local f=( 'httpd.local.conf' )
    for i in "${f[@]}"; do
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/httpd/${i}" \
        && ${ln} -s "${d}/${i}" '/etc/apache2/conf-enabled/'
    done

    ${sed} -i -e "s|80|8080|g" -e "s|443|8081|g" '/etc/apache2/ports.conf'
  }

  site() {
    local d='/etc/apache2/sites-available'; [[ ! -d "${d}" ]] && exit 1

    # Disabled original sites.
    for i in '/etc/apache2/sites-enabled/'*; do [[ -L "${i}" ]] && ${unlink} "${i}"; done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
