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
  case "${1}" in
    'ecc') openssl ecparam -noout -genkey -name 'prime256v1' -out "${2}.key" ;;
    'rsa') openssl genrsa -out "${2}.key" 2048 ;;
    *) echo "'TYPE' does not exist!"; exit 1 ;;
  esac
}

function _csr() {
  openssl req -new -sha256 -key "${1}.key" -out "${2}.csr" \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}" \
    -addext 'basicConstraints = critical, CA:FALSE' \
    -addext "nsCertType = ${3}" \
    -addext 'nsComment = OpenSSL Self-Signed Certificate' \
    -addext 'keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment' \
    -addext "extendedKeyUsage = ${4}" \
    -addext "subjectAltName = DNS:${CN}, DNS:*.${CN}, DNS:*.localdomain, DNS:*.local, IP:127.0.0.1, ${IP%,}"
}

function _crt() {
  openssl x509 -req -sha256 -days "${DAYS}" -copy_extensions 'copyall' \
    -key "${1}.key" -in "${2}.csr" -out "${3}.crt"
}

function _info() {
  openssl x509 -in "${1}.crt" -text -noout
}

function debian() {
  local d; d='/etc/ssl'; [[ ! -d "${d}" ]] && exit 1; [[ ! -d "${d}/_ssc" ]] && mkdir "${d}/_ssc"

  function _chmod() {
    [[ -d "${d}/_ssc" ]] && find "${d}/_ssc" -type f -print0 | xargs -0 chmod 644
  }

  function server_auth() {
    local f; f='auth.server'
    local t; t=('ecc' 'rsa')

    for i in "${t[@]}"; do
      if [[ ! -f "${d}/_ssc/${f}.${i}.key" || ! -f "${d}/_ssc/${f}.${i}.crt" ]]; then
        _key "${i}" "${d}/_ssc/${f}.${i}" \
          && _csr "${d}/_ssc/${f}.${i}" "${d}/_ssc/${f}" 'server, client' 'serverAuth, clientAuth' \
          && _crt "${d}/_ssc/${f}.${i}" "${d}/_ssc/${f}" "${d}/_ssc/${f}.${i}" \
          && _info "${d}/_ssc/${f}.${i}"
      fi
    done
  }

  function client_auth() {
    local f; f='auth.client'
    local t; t=('ecc' 'rsa')

    for i in "${t[@]}"; do
      if [[ ! -f "${d}/_ssc/${f}.${i}.key" || ! -f "${d}/_ssc/${f}.${i}.crt" ]]; then
        _key "${i}" "${d}/_ssc/${f}.${i}" \
          && _csr "${d}/_ssc/${f}.${i}" "${d}/_ssc/${f}" 'client, email' 'clientAuth, emailProtection' \
          && _crt "${d}/_ssc/${f}.${i}" "${d}/_ssc/${f}" "${d}/_ssc/${f}.${i}" \
          && _info "${d}/_ssc/${f}.${i}"
      fi
    done
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
