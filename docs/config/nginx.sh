#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

# Proxy.
[[ -n "${proxy}" ]] && cProxy="-x ${proxy}" || cProxy=''

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
  run() { repo && install && symlink && config01 && config02 && site; }

  repo() {
    local sig; sig='/etc/apt/keyrings/nginx.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/nginx.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://packages.sury.org/nginx/apt.gpg'

    curl ${cProxy} -fsSLo "${sig}" "${key}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Nginx (Sury)|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.sury.org/nginx|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('nginx' 'libnginx-mod-brotli')

    apt update \
      && apt install --yes "${p[@]}"
  }

  symlink() {
    local d; d=('/etc/nginx/sites-enabled')

    for i in "${d[@]}"; do
      [[ -d "${i}" ]] || continue
      for f in "${i}"/*; do
        { [[ -L "${f}" ]] && unlink "${f}"; } || continue
      done
    done
  }

  config01() {
    local d; d='/etc/nginx'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('nginx.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/nginx/debian.${i}"
    done
  }

  config02() {
    local d; d='/etc/nginx/conf.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('brotli.conf' 'gzip.conf' 'headers.conf' 'proxy.conf' 'real_ip.conf' 'real_ip.cf.conf' 'ssl.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/nginx/${i}"
    done
  }

  site() {
    local d; d='/etc/nginx/sites-available'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('default.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/nginx/debian.site.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
