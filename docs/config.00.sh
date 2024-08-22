#!/usr/bin/env -S bash -e
#
# Configuration script.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2020/06/59781965-afe7-5dd5-9798-d1c5ba6cdafd/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# OS.
osId=$( . '/etc/os-release' && echo "${ID}" )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() { pkg && root && u000X && u0002; }

# -------------------------------------------------------------------------------------------------------------------- #
# PACKAGES
# -------------------------------------------------------------------------------------------------------------------- #

pkg() {
  case "${osId}" in
    'debian') apt update && apt install --yes zsh ;;
    *) echo 'OS is not supported!' && exit 1 ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / ROOT
# -------------------------------------------------------------------------------------------------------------------- #

root() {
  local user; user='root'
  local password

  # Changing password.
  echo "--- [${user^^}] Changing password."
  read -rp 'Password: ' password </dev/tty
  echo "${user}:${password}" | chpasswd

  # Changing shell.
  echo "--- [${user^^}] Changing shell."
  chsh -s '/bin/zsh' "${user}"

  # Installing 'grml' config.
  _grml "${user}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / [0000 | 0001]
# -------------------------------------------------------------------------------------------------------------------- #

u000X() {
  local user; user=( 'u0000' 'u0001' )

  for i in "${user[@]}"; do
    if ! id -u "${i}" >/dev/null 2>&1; then
      local password; password=$( < /dev/urandom tr -dc A-Za-z0-9 | head -c8 )

      # Creating user.
      echo "--- [${i^^}] Adding user..."
      useradd -m -p "${password}" -c "${i^^}" "${i}"

      # Saving password.
      local home; home=$( _home "${i}" )
      echo "${password}" > "${home}/.password"
      chown ${i}:${i} "${home}/.password"
    fi

    # Changing shell.
    echo "--- [${i^^}] Changing shell..."
    chsh -s '/bin/zsh' "${i}"

    # Locking user.
    echo "--- [${i^^}] Locking user..."
    usermod -L "${i}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0002
# -------------------------------------------------------------------------------------------------------------------- #

u0002() {
  local user; user='u0002'
  local password

  # Creating user.
  echo "--- [${user^^}] Adding user..."
  useradd -m -c "${user^^}" "${user}"

  # Changing password.
  echo "--- [${user^^}] Changing password..."
  read -rp 'Password: ' password </dev/tty
  echo "${user}:${password}" | chpasswd

  # Changing shell.
  echo "--- [${user^^}] Changing shell..."
  chsh -s '/bin/zsh' "${user}"

  # Installing 'grml' config.
  _grml "${user}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER HOME DIRECTORY
# -------------------------------------------------------------------------------------------------------------------- #

_home() {
  local user; user="${1}"
  local home; home=$( awk -F ':' -v u="${user}" '{ if ($1==u) print $6 }' '/etc/passwd' )
  echo "${home}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# GRML
# -------------------------------------------------------------------------------------------------------------------- #

_grml() {
  local user; user="${1}"
  local uri; uri='https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc'
  local home; home=$( _home "${user}" )
  local zshrc; zshrc='/etc/zsh/zshrc.grml'

  # Downloading 'grml' config.
  if [[ ! -f "${zshrc}" || $( find "${zshrc}" -mmin '+60' ) ]]; then
    mkdir -p '/etc/zsh' && curl -fsSLo "${zshrc}" "${uri}"
  fi

  # Installing 'grml' config.
  [[ -f "${home}/.zshrc" && ! -f "${home}/.zshrc.orig" ]] && { mv "${home}/.zshrc" "${home}/.zshrc.orig"; }
  cat > "${home}/.zshrc" <<EOF
. "${zshrc}"
export GPG_TTY=\$(tty)
EOF

  # Setting file owner.
  chown ${user}:${user} "${home}/.zshrc"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
