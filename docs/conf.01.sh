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

# Apps.
awk=$( command -v 'awk' )
cat=$( command -v 'cat' )
chown=$( command -v 'chown' )
chpasswd=$( command -v 'chpasswd' )
chsh=$( command -v 'chsh' )
curl=$( command -v 'curl' )
find=$( command -v 'find' )
head=$( command -v 'head' )
mkdir=$( command -v 'mkdir' )
mv=$( command -v 'mv' )
tr=$( command -v 'tr' )
useradd=$( command -v 'useradd' )
usermod=$( command -v 'usermod' )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() { root && u0001 && u0002 && u0000; }

# -------------------------------------------------------------------------------------------------------------------- #
# USER / ROOT.
# -------------------------------------------------------------------------------------------------------------------- #

root() {
  local user='root'
  local password

  # Changing password.
  echo "--- [${user^^}] Changing password."
  read -rp 'Password: ' password </dev/tty
  echo "${user}:${password}" | ${chpasswd}

  # Changing shell.
  echo "--- [${user^^}] Changing shell."
  ${chsh} -s '/bin/zsh' "${user}"

  # Installing 'grml' config.
  _grml "${user}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0000.
# -------------------------------------------------------------------------------------------------------------------- #

u0000() {
  local user='u0000'

  # Locking user.
  echo "--- [${user^^}] Locking user..."
  ${usermod} -L "${user}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0001.
# -------------------------------------------------------------------------------------------------------------------- #

u0001() {
  local user='u0001'
  local password; password=$( < /dev/urandom ${tr} -dc A-Za-z0-9 | ${head} -c8 )

  # Creating user.
  echo "--- [${user^^}] Adding user..."
  ${useradd} -m -p "${password}" -c "${user^^}" "${user}"

  # Generating password.
  local home; home=$( _home "${user}" )
  echo "${password}" > "${home}/.password"
  ${chown} ${user}:${user} "${home}/.password"

  # Changing shell.
  echo "--- [${user^^}] Changing shell..."
  ${chsh} -s '/bin/zsh' "${user}"

  # Locking user.
  echo "--- [${user^^}] Locking user..."
  ${usermod} -L "${user}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0002.
# -------------------------------------------------------------------------------------------------------------------- #

u0002() {
  local user='u0002'
  local password

  # Creating user.
  echo "--- [${user^^}] Adding user..."
  ${useradd} -m -c "${user^^}" "${user}"

  # Changing password.
  echo "--- [${user^^}] Changing password..."
  read -rp 'Password: ' password </dev/tty
  echo "${user}:${password}" | ${chpasswd}

  # Changing shell.
  echo "--- [${user^^}] Changing shell..."
  ${chsh} -s '/bin/zsh' "${user}"

  # Installing 'grml' config.
  _grml "${user}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER HOME DIRECTORY.
# -------------------------------------------------------------------------------------------------------------------- #

_home() {
  local user="${1}"
  local home; home=$( ${awk} -F ':' -v u="${user}" '{ if ($1==u) print $6 }' '/etc/passwd' )

  echo "${home}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# GRML.
# -------------------------------------------------------------------------------------------------------------------- #

_grml() {
  local user="${1}"; local uri='https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc'
  local home; home=$( _home "${user}" )
  local zshrc='/etc/zsh/zshrc.grml'

  # Downloading 'grml' config.
  if [[ ! -f "${zshrc}" || $( ${find} "${zshrc}" -mmin '+60' ) ]]; then
    ${mkdir} -p '/etc/zsh' && ${curl} -fsSLo "${zshrc}" "${uri}"
  fi

  # Installing 'grml' config.
  [[ -f "${home}/.zshrc" && ! -f "${home}/.zshrc.orig" ]] && { ${mv} "${home}/.zshrc" "${home}/.zshrc.orig"; }
  ${cat} > "${home}/.zshrc" <<EOF
. "${zshrc}"
export GPG_TTY=\$(tty)
EOF

  # Setting file owner.
  ${chown} ${user}:${user} "${home}/.zshrc"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
