#!/usr/bin/env -S bash -e

init() {
  awk="$( command -v awk )"
  osId=$( ${awk} -F '=' '$1=="ID" { print $2 }' /etc/os-release )

  [[ "${osId}" == 'debian' ]] && { debianZfs; }
}

debianZfs() {
  apt install --yes linux-headers-amd64
  apt install --yes -t stable-backports zfsutils-linux zfs-dkms zfs-zed
}

init "$@"; exit 0
