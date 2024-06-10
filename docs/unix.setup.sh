#!/usr/bin/env -S bash -e
#
# "First steps" setup script.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2020/06/59781965-afe7-5dd5-9798-d1c5ba6cdafd/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  chsh="$( command -v chsh )"
  chpasswd="$( command -v chpasswd )"
  useradd="$( command -v useradd )"
  usermod="$( command -v usermod )"

  # Run.
  root && u0002
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / ROOT.
# -------------------------------------------------------------------------------------------------------------------- #

root() {
  local name='root'
  local password

  echo "--- [${name^^}] Changing password for '${name^^}'..."
  read -rp 'Password: ' password </dev/tty
  echo "${name}:${password}" | ${chpasswd}

  echo "--- [${name^^}] Changing shell for '${name^^}'..."
  ${chsh} -s '/bin/zsh' "${name}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0002.
# -------------------------------------------------------------------------------------------------------------------- #

u0002() {
  local name='u0002'
  local password

  echo "--- [${name^^}] Adding user '${name^^}'..."
  ${useradd} -mc "${name^^}" "${name}"

  echo "--- [${name^^}] Changing password for '${name^^}'..."
  read -rp "Password: " password </dev/tty
  echo "${name}:${password}" | ${chpasswd}

  echo "--- [${name^^}] Changing shell for '${name^^}'..."
  ${chsh} -s '/bin/zsh' "${name}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
