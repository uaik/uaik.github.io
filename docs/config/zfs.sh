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
    local p; p=('openzfs-zfsutils' 'openzfs-zfs-dkms' 'openzfs-zfs-initramfs')

    ${apt} --yes install "${p[@]}"
  }

  default() {
    local p01; p01=('linux-headers-amd64')
    local p02; p02=('zfsutils-linux' 'zfs-dkms' 'zfs-zed')

    ${apt} install --yes "${p01[@]}" \
      && ${apt} install --yes -t 'stable-backports' "${p02[@]}"
  }

  man() {
    echo '' && echo '--- [ZFS] Creating the Pool'
    ${curl} -fsSL 'https://uaik.github.io/config/zfs/man.txt'
    echo ''
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
