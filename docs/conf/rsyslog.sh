#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osVerId=$( . '/etc/os-release' && echo "${VERSION_ID}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
gpg=$( command -v 'gpg' )
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
  run() { repo && apt && config; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='rsyslog.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='rsyslog.sources'
    local key; key="https://download.opensuse.org/repositories/home:rgerhards/Debian_${osVerId}/Release.key"

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Rsyslog|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|http://download.opensuse.org/repositories/home:/rgerhards/Debian_${osVerId}/|g" \
        -e "s|<#_suites_#>|/|g" \
        -e "s|<#_components_#>||g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p; p=('rsyslog')
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/rsyslog.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('99-local.conf')
    for i in "${f[@]}"; do
      ${curl} -fsSLo "${d}/${i}" 'https://uaik.github.io/conf/rsyslog/99-local.conf'
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
