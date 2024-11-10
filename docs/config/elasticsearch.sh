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
  run() { repo '8.x' && install && config && jvm; }

  repo() {
    local sig; sig='/etc/apt/keyrings/elasticsearch.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/elasticsearch.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://artifacts.elastic.co/GPG-KEY-elasticsearch'

    curl ${C_PROXY} -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Elasticsearch|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://artifacts.elastic.co/packages/${1}/apt|g" \
        -e "s|<#_suites_#>|stable|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=( 'elasticsearch' )

    apt update \
      && apt install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/elasticsearch'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('elasticsearch.yml')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/elasticsearch/${i}" \
        && chown root:elasticsearch "${d}/${i}" && chmod 660 "${d}/${i}"
    done
  }

  jvm(){
    local d; d='/etc/elasticsearch/jvm.options.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('jvm.local.options')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/elasticsearch/${i}" \
        && chown root:elasticsearch "${d}/${i}" && chmod 660 "${d}/${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
