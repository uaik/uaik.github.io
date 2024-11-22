#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID

# Proxy.
[[ -n "${proxy}" ]] && C_PROXY="-x ${proxy}" || C_PROXY=''; readonly C_PROXY

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  case "${OS_ID}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { repo '6.1' && install && config; angie; nginx; }

  repo() {
    local sig; sig='/etc/apt/keyrings/graylog.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/graylog.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://packages.graylog2.org/repo/debian/keyring.gpg'

    curl ${C_PROXY} -fsSLo "${sig}" "${key}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Graylog|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.graylog2.org/repo/debian|g" \
        -e "s|<#_suites_#>|stable|g" \
        -e "s|<#_components_#>|${1}|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('graylog-server')

    apt update && apt install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/graylog/server'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('server.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/graylog/${i}"
    done
  }

  angie() {
    local d; d='/etc/angie/http.d'; [[ ! -d "${d}" ]] && return 0
    local f; f=('graylog.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/graylog/debian.site.${i}"
    done
  }

  nginx() {
    local d; d='/etc/nginx/sites-available'; [[ ! -d "${d}" ]] && return 0
    local f; f=('graylog.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/graylog/debian.site.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
