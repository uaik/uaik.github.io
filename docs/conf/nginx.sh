#!/usr/bin/env -S bash -e

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
ln=$( command -v 'ln' )
mv=$( command -v 'mv' )
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
  run() { repo && apt && conf; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='nginx.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='nginx.sources'
    local key; key='https://packages.sury.org/nginx/apt.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
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
    local p; p=( 'nginx' 'libnginx-mod-brotli' )
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  conf() {
    local conf_d; conf_d='/etc/nginx/conf.d'; [[ ! -d "${conf_d}" ]] && exit 1
    local conf_f; conf_f=( 'nginx.local.conf' )
    for i in "${conf_f[@]}"; do ${curl} -fsSLo "${conf_d}/${i}" "https://uaik.github.io/conf/nginx/debian.${i}"; done

    local sites_d; sites_d='/etc/nginx/sites-available'; [[ ! -d "${sites_d}" ]] && exit 1
    local sites_f; sites_f=( 'default.conf' )
    for i in "${sites_f[@]}"; do
      [[ -f "${sites_d}/${i}" ]] && ${mv} "${sites_d}/${i}" "${sites_d}/${i}.orig"
      ${curl} -fsSLo "${sites_d}/${i}" "https://uaik.github.io/conf/nginx/debian.site.${i}" \
        && ${ln} -s "${sites_d}/${i}" '/etc/nginx/sites-enabled/'
    done

    ${sed} -i \
      -e 's|worker_connections 768;|worker_connections 1024;|g' \
      -e 's|types_hash_max_size |#types_hash_max_size |g' \
      -e 's|ssl_protocols |#ssl_protocols |g' \
      -e 's|ssl_prefer_server_ciphers |#ssl_prefer_server_ciphers |g' \
      -e 's|gzip on;|#gzip on;|g' \
      '/etc/nginx/nginx.conf'
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
