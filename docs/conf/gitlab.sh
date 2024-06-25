#!/usr/bin/env -S bash -e

# Apps.
apt=$( command -v 'apt' )
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
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { repo && apt; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'
    local gpg_f; gpg_f='gitlab.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d; list_d='/etc/apt/sources.list.d'
    local list_f; list_f='gitlab.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key; key='https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|GitLab|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.gitlab.com/gitlab/gitlab-ce/debian|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p; p='postgresql'
    ${apt} update && ${apt} install --yes ${p}
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
