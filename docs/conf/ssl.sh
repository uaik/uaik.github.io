#!/usr/bin/env -S bash -e

# Apps.
openssl=$( command -v 'openssl' )
hostname=$( command -v 'hostname' )

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

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
  run() { serverAuth && clientAuth; dhparam; }

  serverAuth() {
    local d; d='/etc/ssl'; [[ ! -d "${d}/private" && ! -d "${d}/certs" ]] && exit 1
    local f; f='auth.server'
    local days; days='3650'
    local country; country='RU'
    local state; state='Russia'
    local city; city='Moscow'
    local org; org='LocalHost'
    local ou; ou='ITD'
    local cn; cn='localhost'
    local domain; domain=$( ${hostname} -d ); [[ -z "${domain}" ]] && domain='localdomain' || domain="${domain}"
    local email; email="postmaster@${domain}"
    local host; IFS=' ' read -ra host <<< "$( ${hostname} -I )" && printf -v ip 'IP:%s,' "${host[@]}"

    if [[ ! -f "${d}/private/${f}.key" || ! -f "${d}/certs/${f}.crt" ]]; then
      ${openssl} ecparam -genkey -name 'prime256v1' -out "${d}/private/${f}.key" \
        && ${openssl} req -new -sha256 \
          -key "${d}/private/${f}.key" \
          -out "${d}/certs/${f}.csr" \
          -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/OU=${ou}/CN=${cn}/emailAddress=${email}" \
          -addext 'basicConstraints = critical, CA:FALSE' \
          -addext 'nsCertType = server' \
          -addext 'nsComment = OpenSSL Generated Server Certificate' \
          -addext 'keyUsage = critical, digitalSignature, keyEncipherment' \
          -addext 'extendedKeyUsage = serverAuth, clientAuth' \
          -addext "subjectAltName = DNS:${cn}, DNS:*.${cn}, IP:127.0.0.1, ${ip%,}" \
        && ${openssl} x509 -req -sha256 -days ${days} -copy_extensions 'copyall' \
          -key "${d}/private/${f}.key" \
          -in "${d}/certs/${f}.csr" \
          -out "${d}/certs/${f}.crt" \
        && ${openssl} x509 -in "${d}/certs/${f}.crt" -text -noout
    fi
  }

  clientAuth() {
    local d; d='/etc/ssl'; [[ ! -d "${d}/private" && ! -d "${d}/certs" ]] && exit 1
    local f; f='auth.client'
    local days; days='3650'
    local country; country='RU'
    local state; state='Russia'
    local city; city='Moscow'
    local org; org='LocalHost'
    local ou; ou='ITD'
    local cn; cn='localhost'
    local domain; domain=$( ${hostname} -d ); [[ -z "${domain}" ]] && domain='localdomain' || domain="${domain}"
    local email; email="postmaster@${domain}"
    local host; IFS=' ' read -ra host <<< "$( ${hostname} -I )" && printf -v ip 'IP:%s,' "${host[@]}"

    if [[ ! -f "${d}/private/${f}.key" || ! -f "${d}/certs/${f}.crt" ]]; then
      ${openssl} ecparam -genkey -name 'prime256v1' -out "${d}/private/${f}.key" \
        && ${openssl} req -new -sha256 \
          -key "${d}/private/${f}.key" \
          -out "${d}/certs/${f}.csr" \
          -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/OU=${ou}/CN=${cn}/emailAddress=${email}" \
          -addext 'basicConstraints = critical, CA:FALSE' \
          -addext 'nsCertType = client, email' \
          -addext 'nsComment = OpenSSL Generated Client Certificate' \
          -addext 'keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment' \
          -addext 'extendedKeyUsage = clientAuth, emailProtection' \
          -addext "subjectAltName = DNS:${cn}, DNS:*.${cn}, IP:127.0.0.1, ${ip%,}" \
        && ${openssl} x509 -req -sha256 -days ${days} -copy_extensions 'copyall' \
          -key "${d}/private/${f}.key" \
          -in "${d}/certs/${f}.csr" \
          -out "${d}/certs/${f}.crt" \
        && ${openssl} x509 -in "${d}/certs/${f}.crt" -text -noout
    fi
  }

  dhparam() {
    local d; d='/etc/ssl'; [[ ! -d "${d}/private" && ! -d "${d}/certs" ]] && exit 1
    [[ ! -f "${d}/certs/local.dhparam.pem" ]] && ${openssl} dhparam -out "${d}/certs/local.dhparam.pem" 4096
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
