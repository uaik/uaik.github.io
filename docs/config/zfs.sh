#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #

OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID

function debian() {
  function xanmod() {
    echo "ZFS is not compatible with this kernel version (${k})!" && exit 1
  }

  function zabbly() {
    local p; p=('openzfs-zfsutils' 'openzfs-zfs-dkms' 'openzfs-zfs-initramfs')
    apt --yes install "${p[@]}"
  }

  function default() {
    local p00; p00=('linux-headers-amd64')
    local p01; p01=('zfsutils-linux' 'zfs-dkms' 'zfs-zed')
    apt install --yes "${p00[@]}" \
      && apt install --yes -t 'stable-backports' "${p01[@]}"
  }

  function main() {
    local k; k="$( uname -r )"
    case "${k}" in
      *'xanmod'*) xanmod ;;
      *'zabbly'*) zabbly ;;
      *) default ;;
    esac
  }; main
}

function main() {
  case "${OS_ID}" in
    'debian') debian ;;
    *) echo >&2 'OS is not supported!'; exit 1 ;;
  esac
}; main "$@"
