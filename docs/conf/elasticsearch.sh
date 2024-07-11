#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# Apps.
apt=$( command -v 'apt' )
cat=$( command -v 'cat' )
curl=$( command -v 'curl' )
fold=$( command -v 'fold' )
gpg=$( command -v 'gpg' )
head=$( command -v 'head' )
sed=$( command -v 'sed' )
tr=$( command -v 'tr' )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  esp=$( password '32' '1' ); export ELASTIC_PASSWORD="${esp}"

  case "${osId}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { repo '8.x' && apt; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='elasticsearch.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='elasticsearch.sources'
    local key; key='https://artifacts.elastic.co/GPG-KEY-elasticsearch'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
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
    echo '' && echo '[!!!] ELASTICSEARCH PASSWORD:' && echo "${esp}" && echo ''
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON FUNCTIONS.
# -------------------------------------------------------------------------------------------------------------------- #

password() {
  local password
  password=$( ${cat} /dev/urandom | LC_ALL=C ${tr} -dc 'a-zA-Z0-9' | ${fold} -w "${1}" | ${head} -n "${2}" )
  echo "${password}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
