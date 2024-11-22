#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
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
  run() { repo_zabbix '7.0' && repo_tools && install; }

  repo_zabbix() {
    local sig; sig='/etc/apt/keyrings/zabbix.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/zabbix.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://uaik.github.io/config/zabbix/zabbix.gpg'

    curl -fsSLo "${sig}" "${key}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Zabbix|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://repo.zabbix.com/zabbix/${1}/debian|g" \
        -e "s|<#_suites_#>|${OS_CODENAME}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  repo_tools() {
    local sig; sig='/etc/apt/keyrings/zabbix.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/zabbix.tools.sources'; [[ ! -d "${src%/*}" ]] && exit 1

    curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
    && sed -i \
      -e "s|<#_name_#>|Zabbix Tools|g" \
      -e "s|<#_enabled_#>|yes|g" \
      -e "s|<#_types_#>|deb|g" \
      -e "s|<#_uri_#>|https://repo.zabbix.com/zabbix-tools/debian-ubuntu|g" \
      -e "s|<#_suites_#>|${OS_CODENAME}|g" \
      -e "s|<#_components_#>|main|g" \
      -e "s|<#_arch_#>|all|g" \
      -e "s|<#_sig_#>|${sig}|g" \
      "${src}"
  }

  install() {
    local p; p=('zabbix-server-pgsql' 'zabbix-frontend-php' 'zabbix-sql-scripts' 'zabbix-agent')

    apt update && apt install --yes "${p[@]}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
