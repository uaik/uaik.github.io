#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION SCRIPT
# -------------------------------------------------------------------------------------------------------------------- #
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2020/06/59781965-afe7-5dd5-9798-d1c5ba6cdafd/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# Variables.
OS_ID="$( . '/etc/os-release' && echo "${ID}" )"; readonly OS_ID

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function _home() {
  local user; user="${1}"
  local home; home="$( awk -F ':' -v u="${user}" '{ if ($1==u) print $6 }' '/etc/passwd' )"
  echo "${home}"
}

function _zshrc() {
  local user; user="${1}"
  local home; home="$( _home "${user}" )"
  local grml; grml='/etc/zsh/zshrc.grml'

  # Downloading 'grml' config.
  if [[ ! -f "${grml}" || $( find "${grml}" -mmin '+60' ) ]]; then
    mkdir -p '/etc/zsh' && curl -fsSLo "${grml}" 'https://uaik.github.io/config/zsh/zshrc.grml'
  fi

  # Downloading 'zsh' config.
  [[ -f "${home}/.zshrc" && ! -f "${home}/.zshrc.orig" ]] && { mv "${home}/.zshrc" "${home}/.zshrc.orig"; }
  curl -fsSLo "${home}/.zshrc" 'https://uaik.github.io/config/zsh/zshrc' && chown "${user}":"${user}" "${home}/.zshrc"
}

function pkg() {
  case "${OS_ID}" in
    'debian') apt update && apt install --yes zsh ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

function dirs() {
  local d; d='/home/common'
  local d_apps; d_apps="${d}/apps"
  local d_docs; d_docs="${d}/docs"

  [[ ! -d "${d_apps}" ]] && mkdir -p "${d_apps}"
  [[ ! -d "${d_docs}" ]] && mkdir -p "${d_docs}"
}

function root() {
  local user; user='root'
  local password

  # Changing password.
  echo "--- [${user^^}] Changing password."
  read -rp 'Password: ' password </dev/tty
  echo "${user}:${password}" | chpasswd

  # Changing shell.
  echo "--- [${user^^}] Changing shell."
  chsh -s '/bin/zsh' "${user}"

  # Installing 'zsh' config.
  _zshrc "${user}"
}

function u000X() {
  local user; user=('u0000' 'u0001')

  for i in "${user[@]}"; do
    if ! id -u "${i}" >/dev/null 2>&1; then
      local password; password="$( < /dev/urandom tr -dc A-Za-z0-9 | head -c8 )"

      # Creating user.
      echo "--- [${i^^}] Adding user..."
      useradd -m -p "$( openssl passwd -6 ${password} )" -G sudo -c "${i^^}" "${i}"

      # Saving password.
      local home; home="$( _home "${i}" )"
      echo "${password}" > "${home}/.password"
      chown "${i}":"${i}" "${home}/.password"
    fi

    # Changing shell.
    echo "--- [${i^^}] Changing shell..."
    chsh -s '/bin/zsh' "${i}"

    # Locking user.
    echo "--- [${i^^}] Locking user..."
    usermod -L "${i}"
  done
}

function u0002() {
  local user; user='u0002'
  local password

  # Creating user.
  echo "--- [${user^^}] Adding user..."
  useradd -m -G sudo -c "${user^^}" "${user}"

  # Changing password.
  echo "--- [${user^^}] Changing password..."
  read -rp 'Password: ' password </dev/tty
  echo "${user}:${password}" | chpasswd

  # Changing shell.
  echo "--- [${user^^}] Changing shell..."
  chsh -s '/bin/zsh' "${user}"

  # Installing 'zsh' config.
  _zshrc "${user}"
}

function main() { pkg && dirs && root && u000X && u0002; }; main "$@"
