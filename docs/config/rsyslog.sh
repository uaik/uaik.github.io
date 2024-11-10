#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
OS_VER_ID="$( . '/etc/os-release' && echo "${VERSION_ID}" )"; readonly OS_VER_ID

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
  run() { repo && install && config; }

  repo() {
    local sig; sig='/etc/apt/keyrings/rsyslog.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/rsyslog.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key="https://download.opensuse.org/repositories/home:rgerhards/Debian_${OS_VER_ID}/Release.key"

    curl -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|Rsyslog|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|http://download.opensuse.org/repositories/home:/rgerhards/Debian_${OS_VER_ID}/|g" \
        -e "s|<#_suites_#>|/|g" \
        -e "s|<#_components_#>||g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('rsyslog')
    local s; s=('rsyslog')

    apt update \
      && apt install --yes "${p[@]}"
    # FIX:
    # > systemd[1]: Dependency failed for rsyslog.service - System Logging Service.
    for i in "${s[@]}"; do
      systemctl enable "${i}.service" && systemctl restart "${i}.service"
    done
  }

  config() {
    local d; d='/etc/rsyslog.d'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('99-local.conf')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/rsyslog/${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
