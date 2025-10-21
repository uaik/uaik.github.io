#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID

function debian() {
  function server_auth() {
    local d; d='/etc/ssl'; [[ ! -d "${d}" ]] && exit 1
    local f; f='auth.server'
    local days; days='3650'
    local country; country='RU'
    local state; state='Russia'
    local city; city='Moscow'
    local org; org='LocalHost'
    local ou; ou='IT Department'
    local cn; cn='localhost'
    local domain; domain=$( hostname -d ); [[ -z "${domain}" ]] && domain='localdomain' || domain="${domain}"
    local email; email="postmaster@${domain}"
    local host; IFS=' ' read -ra host <<< "$( hostname -I )" && printf -v ip 'IP:%s,' "${host[@]}"

    [[ ! -d "${d}/_ssc" ]] && mkdir "${d}/_ssc"
    if [[ ! -f "${d}/_ssc/${f}.key" || ! -f "${d}/_ssc/${f}.crt" ]]; then
      openssl ecparam -genkey -noout -name 'prime256v1' -out "${d}/_ssc/${f}.key" \
        && openssl req -new -sha256 -key "${d}/_ssc/${f}.key" -out "${d}/_ssc/${f}.csr" \
          -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/OU=${ou}/CN=${cn}/emailAddress=${email}" \
          -addext 'basicConstraints = critical, CA:FALSE' \
          -addext 'nsCertType = server, client' \
          -addext 'nsComment = OpenSSL Self-Signed Certificate' \
          -addext 'keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment' \
          -addext 'extendedKeyUsage = serverAuth, clientAuth' \
          -addext "subjectAltName = DNS:${cn}, DNS:*.${cn}, DNS:*.localdomain, DNS:*.local, IP:127.0.0.1, ${ip%,}" \
        && openssl x509 -req -sha256 -days ${days} -copy_extensions 'copyall' \
          -key "${d}/_ssc/${f}.key" \
          -in "${d}/_ssc/${f}.csr" \
          -out "${d}/_ssc/${f}.crt" \
        && openssl x509 -in "${d}/_ssc/${f}.crt" -text -noout
    fi
  }

  function client_auth() {
    local d; d='/etc/ssl'; [[ ! -d "${d}" ]] && exit 1
    local f; f='auth.client'
    local days; days='3650'
    local country; country='RU'
    local state; state='Russia'
    local city; city='Moscow'
    local org; org='LocalHost'
    local ou; ou='IT Department'
    local cn; cn='localhost'
    local domain; domain=$( hostname -d ); [[ -z "${domain}" ]] && domain='localdomain' || domain="${domain}"
    local email; email="postmaster@${domain}"
    local host; IFS=' ' read -ra host <<< "$( hostname -I )" && printf -v ip 'IP:%s,' "${host[@]}"

    [[ ! -d "${d}/_ssc" ]] && mkdir "${d}/_ssc"
    if [[ ! -f "${d}/_ssc/${f}.key" || ! -f "${d}/_ssc/${f}.crt" ]]; then
      openssl ecparam -genkey -noout -name 'prime256v1' -out "${d}/_ssc/${f}.key" \
        && openssl req -new -sha256 -key "${d}/_ssc/${f}.key" -out "${d}/_ssc/${f}.csr" \
          -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/OU=${ou}/CN=${cn}/emailAddress=${email}" \
          -addext 'basicConstraints = critical, CA:FALSE' \
          -addext 'nsCertType = client, email' \
          -addext 'nsComment = OpenSSL Self-Signed Certificate' \
          -addext 'keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment' \
          -addext 'extendedKeyUsage = clientAuth, emailProtection' \
          -addext "subjectAltName = DNS:${cn}, DNS:*.${cn}, DNS:*.localdomain, DNS:*.local, IP:127.0.0.1, ${ip%,}" \
        && openssl x509 -req -sha256 -days ${days} -copy_extensions 'copyall' \
          -key "${d}/_ssc/${f}.key" \
          -in "${d}/_ssc/${f}.csr" \
          -out "${d}/_ssc/${f}.crt" \
        && openssl x509 -in "${d}/_ssc/${f}.crt" -text -noout
    fi
  }

  function dhparam() {
    local d; d='/etc/ssl'; [[ ! -d "${d}" ]] && exit 1
    [[ ! -d "${d}/_ssc" ]] && mkdir "${d}/_ssc"
    [[ ! -f "${d}/_ssc/dhparam.pem" ]] && openssl dhparam -out "${d}/_ssc/dhparam.pem" 4096
  }

  function _chmod() {
    local d; d='/etc/ssl'; [[ ! -d "${d}" ]] && exit 1
    [[ -d "${d}/_ssc" ]] && find "${d}/_ssc" -type f -print0 | xargs -0 chmod 644
  }

  function main() {
    server_auth && client_auth; dhparam; _chmod
  }; main
}

function main() {
  case "${OS_ID}" in
    'debian') debian ;;
    *) echo >&2 'OS is not supported!'; exit 1 ;;
  esac
}; main "$@"
