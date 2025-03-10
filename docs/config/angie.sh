#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
OS_VER="$( . '/etc/os-release' && echo "${VERSION_ID}" )"; readonly OS_VER
OS_CODENAME="$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )"; readonly OS_CODENAME

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
  run() { repo && install && config01 && config02 && site; }

  repo() {
    local sig; sig='/etc/apt/keyrings/angie.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/angie.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://angie.software/keys/angie-signing.gpg'

    curl -fsSLo "${sig}" "${key}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Angie|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://download.angie.software/angie/${OS_ID}/${OS_VER}|g" \
        -e "s|<#_suites_#>|${OS_CODENAME}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('angie' 'angie-module-brotli' 'angie-module-zstd')

    apt update && apt install --yes "${p[@]}"
  }

  config01() {
    local d; d='/etc/angie'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('angie.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/angie/debian.${i}"
    done
  }

  config02() {
    local d; d='/etc/angie/conf.d'; [[ ! -d "${d}" ]] && mkdir "${d}"
    local f; f=(
      'acme.conf'
      'brotli.conf'
      'gzip.conf'
      'headers.conf'
      'proxy.conf'
      'real_ip.conf'
      'real_ip.cf.conf'
      'ssl.conf'
      'zstd.conf'
    )

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/angie/${i}"
    done
  }

  site() {
    local d; d='/etc/angie/http.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('default.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/angie/debian.site.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
