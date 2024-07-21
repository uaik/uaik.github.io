#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# Apps.
apt=$( command -v 'apt' )
cat=$( command -v 'cat' )
chmod=$( command -v 'chmod' )
chown=$( command -v 'chown' )
curl=$( command -v 'curl' )
fold=$( command -v 'fold' )
gpg=$( command -v 'gpg' )
head=$( command -v 'head' )
mv=$( command -v 'mv' )
sed=$( command -v 'sed' )
tr=$( command -v 'tr' )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  osp=$( password '32' '1' ); export OPENSEARCH_INITIAL_ADMIN_PASSWORD="${osp}"

  case "${osId}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { repo '2.x' && apt '2.13.0' && config && jvm; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'; [[ ! -d "${gpg_d}" ]] && exit 1
    local gpg_f; gpg_f='opensearch.gpg'
    local list_d; list_d='/etc/apt/sources.list.d'; [[ ! -d "${list_d}" ]] && exit 1
    local list_f; list_f='opensearch.sources'
    local key; key='https://artifacts.opensearch.org/publickeys/opensearch.pgp'

    ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|OpenSearch|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://artifacts.opensearch.org/releases/bundle/opensearch/${1}/apt|g" \
        -e "s|<#_suites_#>|stable|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p; p=( "opensearch=${1}" )
    ${apt} update && ${apt} install --yes "${p[@]}" && apt-mark hold "${p[@]}"
    echo '' && echo '[!] OPENSEARCH PASSWORD:' && echo "${osp}" && echo ''
  }

  config() {
    local d; d='/etc/opensearch'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('opensearch.yml')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig" || exit 1
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/opensearch/${i}"
    done
  }

  jvm(){
    local d; d='/etc/opensearch/jvm.options.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('jvm.local.options')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/opensearch/${i}" \
        && ${chown} opensearch:opensearch "${d}/${i}" && ${chmod} 660 "${d}/${i}"
    done
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

run && exit 0 || exit 1
