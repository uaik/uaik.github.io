#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
gpg=$( command -v 'gpg' )
sed=$( command -v 'sed' )

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
  run() { repo && update; }

  repo() {
    local sig; sig='/etc/apt/keyrings/kernel.zabbly.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/kernel.zabbly.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://pkgs.zabbly.com/key.asc'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${sig}" \
      && ${curl} -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Kernel (Zabbly)|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb deb-src|g" \
        -e "s|<#_uri_#>|https://pkgs.zabbly.com/kernel/stable|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main zfs|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  update() { ${apt} update; }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
