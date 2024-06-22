#!/usr/bin/env -S bash -e

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
ln=$( command -v 'ln' )
openssl=$( command -v 'openssl' )
sed=$( command -v 'sed' )
unlink=$( command -v 'unlink' )
hostname=$( command -v 'hostname' )

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )
osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

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
  run() { repo && apt && conf && site; ssl; }

  repo() {
    local gpg_d; gpg_d='/etc/apt/keyrings'
    local gpg_f; gpg_f='apache2.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
    local list_d; list_d='/etc/apt/sources.list.d'
    local list_f; list_f='apache2.sources'; [[ ! -d "${list_d}" ]] && exit 1
    local key; key='https://packages.sury.org/apache2/apt.gpg'

    ${curl} -fsSLo "${gpg_d}/${gpg_f}" "${key}" \
      && ${curl} -fsSLo "${list_d}/${list_f}" 'https://uaik.github.io/conf/apt/deb.sources.tpl' \
      && ${sed} -i \
        -e "s|<#_name_#>|Apache (Sury)|g" \
        -e "s|<#_enabled_#>|yes|g" \
        -e "s|<#_types_#>|deb|g" \
        -e "s|<#_uri_#>|https://packages.sury.org/apache2|g" \
        -e "s|<#_suites_#>|${osCodeName}|g" \
        -e "s|<#_components_#>|main|g" \
        -e "s|<#_arch_#>|$( dpkg --print-architecture )|g" \
        -e "s|<#_sig_#>|${gpg_d}/${gpg_f}|g" \
        "${list_d}/${list_f}"
  }

  apt() {
    local p; p=( 'apache2' )
    ${apt} update && ${apt} install --yes "${p[@]}"
  }

  conf() {
    local d; d='/etc/apache2/conf-available'; [[ ! -d "${d}" ]] && exit 1

    # Disabling original config.
    for i in '/etc/apache2/conf-enabled/'*; do
      if [[ -L "${i}" ]]; then ${unlink} "${i}"; else continue; fi
    done

    # Installing and enabling custom config.
    local f; f=( 'httpd.local.conf' )
    for i in "${f[@]}"; do
      ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/httpd/${i}" \
        && ${ln} -s "${d}/${i}" '/etc/apache2/conf-enabled/'
    done

    # Changing base config.
    ${sed} -i -e "s|80|8080|g" -e "s|443|8081|g" '/etc/apache2/ports.conf'
  }

  site() {
    local d; d='/etc/apache2/sites-available'; [[ ! -d "${d}" ]] && exit 1

    # Disabling original sites.
    for i in '/etc/apache2/sites-enabled/'*; do
      if [[ -L "${i}" ]]; then ${unlink} "${i}"; else continue; fi
    done
  }

  ssl() {
    local d; d='/etc/ssl'; [[ ! -d "${d}/private" && ! -d "${d}/certs" ]] && exit 1
    local f; f='web.local'
    local days; days='3650'
    local country; country='RU'
    local state; state='Russia'
    local city; city='Moscow'
    local org; org='LocalHost'
    local host; IFS=' ' read -ra host <<< "$( hostname -I )" && printf -v host 'DNS:%s,' "${host[@]}"

    if [[ ! -f "${d}/private/${f}.key" ]]; then
      ${openssl} ecparam -genkey -name 'prime256v1' -out "${d}/private/${f}.key" \
        && ${openssl} req -new -sha256 \
          -key "${d}/private/${f}.key" \
          -out "${d}/certs/${f}.csr" \
          -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/CN=${host[0]}" \
          -addext "subjectAltName=${host%,}" \
        && ${openssl} req -x509 -sha256 -days ${days} \
          -key "${d}/private/${f}.key" \
          -in "${d}/certs/${f}.csr" \
          -out "${d}/certs/${f}.crt"
    fi

    [[ ! -f "${d}/certs/dhparam.pem" ]] && ${openssl} dhparam -out "${d}/certs/dhparam.pem" 4096
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
