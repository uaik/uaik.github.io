#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  osp=$( password '32' '1' ); export OPENSEARCH_INITIAL_ADMIN_PASSWORD="${osp}"

  case "${osId}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() { repo '2.x' && install '2.13.0' && config && jvm; }

  repo() {
    local sig; sig='/etc/apt/keyrings/opensearch.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/opensearch.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://artifacts.opensearch.org/publickeys/opensearch.pgp'

    curl -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|OpenSearch|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://artifacts.opensearch.org/releases/bundle/opensearch/${1}/apt|g" \
        -e "s|<#_suites_#>|stable|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=( "opensearch=${1}" )

    apt update \
      && apt install --yes "${p[@]}" \
      && apt-mark hold "${p[@]}"

    echo '' && echo '[!] OPENSEARCH PASSWORD:' && echo "${osp}" && echo ''
  }

  config() {
    local d; d='/etc/opensearch'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('opensearch.yml')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/opensearch/${i}"
    done
  }

  jvm(){
    local d; d='/etc/opensearch/jvm.options.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('jvm.local.options')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/opensearch/${i}" \
        && chown opensearch:opensearch "${d}/${i}" && chmod 660 "${d}/${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON FUNCTIONS
# -------------------------------------------------------------------------------------------------------------------- #

password() {
  local password
  password=$( cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w "${1}" | head -n "${2}" )
  echo "${password}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
