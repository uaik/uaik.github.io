#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
mv=$( command -v 'mv' )
sed=$( command -v 'sed' )
unlink=$( command -v 'unlink' )

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
  run() { repo && apt && symlink && config && configExt && site; }

  repo() {
    local sig; sig='/etc/apt/keyrings/apache2.gpg'; [[ ! -d "${sig%/*}" ]] && exit 1
    local src; src='/etc/apt/sources.list.d/apache2.sources'; [[ ! -d "${src%/*}" ]] && exit 1
    local key; key='https://packages.sury.org/apache2/apt.gpg'

    ${curl} ${cProxy} -fsSLo "${sig}" "${key}" \
      && ${curl} -fsSLo "${src}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Apache (Sury)|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.sury.org/apache2|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${sig}|g" \
        "${src}"
  }

  apt() {
    local p; p=('apache2')
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  symlink() {
    local d; d=('/etc/apache2/conf-enabled/' '/etc/apache2/sites-enabled/')

    for i in "${d[@]}"; do
      [[ -d "${i}" ]] || continue
      for f in "${i}"/*; do { [[ -L "${f}" ]] && ${unlink} "${f}"; } || continue; done
    done
  }

  config() {
    local d; d='/etc/apache2'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('apache2.conf' 'ports.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/httpd/debian.${i}"
    done
  }

  configExt() {
    local d; d='/etc/apache2/conf-available'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('logs.conf' 'security.conf')

    # Rename original configs.
    for i in "${d}"/*; do
      { [[ -f "${i}" && ! -f "${i}.orig" ]] && ${mv} "${i}" "${i}.orig"; } || continue
    done

    # Download custom configs.
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/httpd/debian.${i}"
    done
  }

  site() {
    local d; d='/etc/apache2/sites-available'; [[ ! -d "${d}" ]] && exit 1
    local f; f=('default.conf')
    for i in "${f[@]}"; do
      [[ -f "${d}/${i}" && ! -f "${d}/${i}.orig" ]] && ${mv} "${d}/${i}" "${d}/${i}.orig"
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/httpd/debian.site.${i}"
    done
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
