#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# Apps.
apt=$( command -v 'apt' )
chmod=$( command -v 'chmod' )
chmod=$( command -v 'chmod' )
chown=$( command -v 'chown' )
chown=$( command -v 'chown' )
curl=$( command -v 'curl' )
gpg=$( command -v 'gpg' )
mv=$( command -v 'mv' )
sed=$( command -v 'sed' )

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
  run() { repo '8.x' && apt && config && jvm; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='elasticsearch.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='elasticsearch.sources'
    local key; key='https://artifacts.elastic.co/GPG-KEY-elasticsearch'

    ${curl} ${cProxy} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Elasticsearch|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://artifacts.elastic.co/packages/${1}/apt|g" \
        -e "s|<#_suites_#>|stable|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p; p=( 'elasticsearch' )
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/elasticsearch'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('elasticsearch.yml')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig" || exit 1
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/elasticsearch/${i}" \
        && ${chown} root:elasticsearch "${d}/${i}" && ${chmod} 660 "${d}/${i}"
    done
  }

  jvm(){
    local d; d='/etc/elasticsearch/jvm.options.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('jvm.local.options')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig" || exit 1
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/elasticsearch/${i}" \
        && ${chown} root:elasticsearch "${d}/${i}" && ${chmod} 660 "${d}/${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
