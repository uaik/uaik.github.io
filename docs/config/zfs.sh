#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  case "${osId}" in
    'debian') debian ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  run() {
    local k; k=$( uname -r )

    case "${k}" in
      *'xanmod'*) xanmod ;;
      *'zabbly'*) zabbly ;;
      *) default ;;
    esac
  }

  xanmod() {
    echo "ZFS is not compatible with this kernel version (${k})!" && exit 1
  }

  zabbly() {
    local p; p=('openzfs-zfsutils' 'openzfs-zfs-dkms' 'openzfs-zfs-initramfs')

    apt --yes install "${p[@]}"
  }

  default() {
    local p00; p00=('linux-headers-amd64')
    local p01; p01=('zfsutils-linux' 'zfs-dkms' 'zfs-zed')

<<<<<<< HEAD
    apt install --yes "${p01[@]}" \
      && apt install --yes -t 'stable-backports' "${p02[@]}"
  }

  man() {
    echo '' && echo '--- [ZFS] Creating the Pool'
    curl -fsSL 'https://uaik.github.io/config/zfs/man.txt'
    echo ''
=======
    ${apt} install --yes "${p00[@]}" \
      && ${apt} install --yes -t 'stable-backports' "${p01[@]}"
>>>>>>> a57709a6d782bb0644498bedd37e5f7909c6e64c
  }

  run
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
