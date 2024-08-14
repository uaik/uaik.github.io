#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osVer=$( . '/etc/os-release' && echo "${VERSION_ID}" )
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
  run() { repo && install; }

  repo() {
    local sig; sig='/etc/apt/keyrings/angie.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/angie.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://angie.software/keys/angie-signing.gpg'

    ${curl} -fsSLo "${sig}" "${key}" \
      && ${curl} -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Angie|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://download.angie.software/angie/${osId}/${osVer}|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('angie' 'angie-module-brotli')

    ${apt} update \
      && ${apt} install --yes "${p[@]}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
