#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# Apps.
apt=$( command -v 'apt' )
curl=$( command -v 'curl' )
uname=$( command -v 'uname' )

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
  run() {
    local k; k=$( ${uname} -r )

    case "${k}" in
      *'xanmod'*) xanmod ;;
      *'zabbly'*) zabbly && man ;;
      *) default && man ;;
    esac
  }

  xanmod() {
    echo "ZFS is not compatible with this kernel version (${k})!" && exit 1
  }

  zabbly() {
    ${apt} --yes install openzfs-zfsutils openzfs-zfs-dkms openzfs-zfs-initramfs
  }

  default() {
    ${apt} install --yes linux-headers-amd64 \
      && ${apt} install --yes -t stable-backports zfsutils-linux zfs-dkms zfs-zed
  }

  man() {
    echo '' && echo '--- [ZFS] Creating the Pool'
    ${curl} -fsSL 'https://uaik.github.io/conf/zfs/man.txt'
    echo ''
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
