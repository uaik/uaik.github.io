#!/usr/bin/env -S bash -e

osId=$( awk -F '=' '$1=="ID" { print $2 }' /etc/os-release )

if [[ "${osId}" == 'debian' ]]; then
  apt install --yes linux-headers-amd64
  apt install --yes -t stable-backports zfsutils-linux zfs-dkms zfs-zed
fi

exit 0
