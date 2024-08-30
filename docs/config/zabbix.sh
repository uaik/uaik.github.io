#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

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
  run() { repo01 '7.0' && repo02 && install; }

  repo01() {
    local sig; sig='/etc/apt/keyrings/zabbix.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/zabbix.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://uaik.github.io/config/zabbix/zabbix.gpg'

    curl -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Zabbix|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://repo.zabbix.com/zabbix/${1}/debian|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  repo02() {
    local sig; sig='/etc/apt/keyrings/zabbix.tools.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/zabbix.tools.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://uaik.github.io/config/zabbix/zabbix.tools.gpg'

    curl -fsSLo "${sig}" "${key}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Zabbix Tools|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://repo.zabbix.com/zabbix-tools/debian-ubuntu|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|all|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('zabbix-server-pgsql' 'zabbix-frontend-php' 'zabbix-sql-scripts' 'zabbix-agent')

    apt update \
      && apt install --yes "${p[@]}"
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
