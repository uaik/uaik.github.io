#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
OS_CODENAME="$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )"; readonly OS_CODENAME

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
  run() { repo && install && config && license; }

  repo() {
    local sig; sig='/etc/apt/keyrings/gitlab.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/gitlab.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey'

    curl ${C_PROXY} -fsSL "${key}" | gpg --dearmor -o "${sig}" \
      && curl -fsSLo "${src}" 'https://uaik.github.io/config/apt/deb.sources.tpl' \
      && sed -i \
        -e "s|<#_name_#>|GitLab|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.gitlab.com/gitlab/gitlab-ee/debian|g" \
        -e "s|<#_suites_#>|${OS_CODENAME}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  install() {
    local p; p=('gitlab-ee')

    apt update && apt install --yes "${p[@]}"
  }

  config() {
    local d; d='/etc/gitlab'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('gitlab.local.rb')

    for i in "${f[@]}"; do
      curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/gitlab/debian.${i}"
    done

    cat << EOF >> "${d}/gitlab.rb"

#################################################################################
## Loading external configuration file
#################################################################################
from_file '${d}/gitlab.local.rb'
EOF
  }

  license() {
    local d; d='/opt/gitlab/embedded/service/gitlab-rails'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('.license_encryption_key.pub')

    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && mv "${d}/${i}" "${d}/${i}.orig"
      curl -fsSLo "${d}/${i}" 'https://uaik.github.io/config/gitlab/license.pub'
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
