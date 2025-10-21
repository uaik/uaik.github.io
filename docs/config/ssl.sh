#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID
DAYS='3650'
COUNTRY='SC'
STATE='Victoria'
CITY='Victoria'
ORG='LocalHost'
OU='IT Department'
CN='localhost'
DOMAIN=$( hostname -d ); [[ -z "${DOMAIN}" ]] && DOMAIN='localdomain' || DOMAIN="${DOMAIN}"
EMAIL="postmaster@${DOMAIN}"
IFS=' ' read -ra HOST <<< "$( hostname -I )" && printf -v IP 'IP:%s,' "${HOST[@]}"

function _key() {
  openssl ecparam -noout -genkey -name 'prime256v1' -out "${1}"
}

function _csr() {
  openssl req -new -sha256 -key "${1}" -out "${2}" \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}" \
    -addext 'basicConstraints = critical, CA:FALSE' \
    -addext "nsCertType = ${3}" \
    -addext 'nsComment = OpenSSL Self-Signed Certificate' \
    -addext 'keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment' \
    -addext "extendedKeyUsage = ${4}" \
    -addext "subjectAltName = DNS:${CN}, DNS:*.${CN}, DNS:*.localdomain, DNS:*.local, IP:127.0.0.1, ${IP%,}"
}

function _crt() {
  openssl x509 -req -sha256 -days "${DAYS}" -copy_extensions 'copyall' -key "${1}" -in "${2}" -out "${3}"
}

function _info() {
  openssl x509 -in "${1}" -text -noout
}

function debian() {
  local d; d='/etc/ssl'; [[ ! -d "${d}" ]] && exit 1; [[ ! -d "${d}/_ssc" ]] && mkdir "${d}/_ssc"

  function _chmod() {
    [[ -d "${d}/_ssc" ]] && find "${d}/_ssc" -type f -print0 | xargs -0 chmod 644
  }

  function server_auth() {
    local f; f='auth.server'

    if [[ ! -f "${d}/_ssc/${f}.key" || ! -f "${d}/_ssc/${f}.crt" ]]; then
      _key "${d}/_ssc/${f}.key" \
        && _csr "${d}/_ssc/${f}.key" "${d}/_ssc/${f}.csr" 'server, client' 'serverAuth, clientAuth' \
        && _crt "${d}/_ssc/${f}.key" "${d}/_ssc/${f}.csr" "${d}/_ssc/${f}.crt" \
        && _info "${d}/_ssc/${f}.crt"
    fi
  }

  function client_auth() {
    local f; f='auth.client'

    if [[ ! -f "${d}/_ssc/${f}.key" || ! -f "${d}/_ssc/${f}.crt" ]]; then
      _key "${d}/_ssc/${f}.key" \
        && _csr "${d}/_ssc/${f}.key" "${d}/_ssc/${f}.csr" 'client, email' 'clientAuth, emailProtection' \
        && _crt "${d}/_ssc/${f}.key" "${d}/_ssc/${f}.csr" "${d}/_ssc/${f}.crt" \
        && _info "${d}/_ssc/${f}.crt"
    fi
  }

  function dhparam() {
    [[ ! -f "${d}/_ssc/dhparam.pem" ]] && openssl dhparam -out "${d}/_ssc/dhparam.pem" 4096
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
