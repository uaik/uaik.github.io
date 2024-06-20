#!/usr/bin/env -S bash -e

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
apt=$( command -v 'apt' ); cmd_check 'apt'
uname=$( command -v 'uname' ); cmd_check 'uname'

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
  local k; k=$( ${uname} -r )

  xanmod() {
    echo "Zfs is not compatible with this kernel version (${k})!" && exit 1
  }

  zabbly() {
    ${apt} --yes install openzfs-zfsutils openzfs-zfs-dkms openzfs-zfs-initramfs
  }

  default() {
    ${apt} install --yes linux-headers-amd64 \
      && ${apt} install --yes -t stable-backports zfsutils-linux zfs-dkms zfs-zed
  }

  case "${k}" in
    *'xanmod'*) xanmod ;;
    *'zabbly'*) zabbly ;;
    *) default ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
