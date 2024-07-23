#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
mv=$( command -v 'mv' )
sed=$( command -v 'sed' )
unlink=$( command -v 'unlink' )

# Proxy.
[[ -n "${proxy}" ]] && cProxy="-x ${proxy}" || cProxy=''

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
  run() { repo && apt && config && configExt && sitesRemoveSymlink && sitesConfig; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='nginx.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='nginx.sources'
    local key; key='https://packages.sury.org/nginx/apt.gpg'

    ${curl} ${cProxy} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Nginx (Sury)|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.sury.org/nginx|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p; p=('nginx' 'libnginx-mod-brotli')
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/nginx'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('nginx.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/nginx/debian.${i}"
    done
  }

  configExt() {
    local d; d='/etc/nginx/conf.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('brotli.conf' 'gzip.conf' 'headers.conf' 'proxy.conf' 'real_ip.cf.conf' 'ssl.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/nginx/${i}"
    done
  }

  sitesRemoveSymlink() {
    local d; d='/etc/nginx/sites-enabled'; [[ ! -d "${d}" ]] && exit 1
    for i in "${d}"/*; do { [[ -L "${i}" ]] && ${unlink} "${i}"; } || continue; done
  }

  sitesConfig() {
    local d; d='/etc/nginx/sites-available'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('default.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/nginx/debian.site.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
