#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

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
  run() { repoProsody && repoJitsi && install; }

  repoProsody() {
    local sig; sig='/etc/apt/keyrings/prosody.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/prosody.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://prosody.im/files/prosody-debian-packages.key'

    curl -fsSLo "${sig}" "${key}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Prosody|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|http://packages.prosody.im/debian|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  repoJitsi() {
    local sig; sig='/etc/apt/keyrings/jitsi.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/jitsi.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://download.jitsi.org/jitsi-key.gpg.key'

    curl -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Jitsi|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://download.jitsi.org|g" \
        -e "s|<#_suites_#>|stable|g" \
        -e "/<#_components_#>/d" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('lua5.2' 'jitsi-meet')

    apt update \
      && apt install --yes "${p[@]}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
