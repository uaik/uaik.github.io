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
  awk="$( command -v awk )"
  cat="$( command -v cat )"
  chown="$( command -v chown )"
  chpasswd="$( command -v chpasswd )"
  chsh="$( command -v chsh )"
  head="$( command -v head )"
  tr="$( command -v tr )"
  useradd="$( command -v useradd )"
  usermod="$( command -v usermod )"
  wget="$( command -v wget )"
  mv="$( command -v mv )"

  # Run.
  root && u0001 && u0002 && u0000 && conf
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / ROOT.
# -------------------------------------------------------------------------------------------------------------------- #

root() {
  local u='root'
  local p

  # Changing password.
  echo "--- [${u^^}] Changing password."
  read -rp 'Password: ' p </dev/tty
  echo "${u}:${p}" | ${chpasswd}

  # Changing shell.
  echo "--- [${u^^}] Changing shell."
  ${chsh} -s '/bin/zsh' "${u}"

  # GRML Zsh.
  _grml "${u}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0000.
# -------------------------------------------------------------------------------------------------------------------- #

u0000() {
  local u='u0000'

  # Locking user.
  echo "--- [${u^^}] Locking user..."
  ${usermod} -L "${u}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0001.
# -------------------------------------------------------------------------------------------------------------------- #

u0001() {
  local u='u0001'
  local p; p=$( < /dev/urandom ${tr} -dc A-Za-z0-9 | ${head} -c8 )

  # Creating user.
  echo "--- [${u^^}] Adding user..."
  ${useradd} -m -p "${p}" -c "${u^^}" "${u}"

  # Generating password.
  local d; d=$( _home "${u}" )
  echo "${p}" > "${d}/.password"
  ${chown} ${u}:${u} "${d}/.password"

  # Changing shell.
  echo "--- [${u^^}] Changing shell..."
  ${chsh} -s '/bin/zsh' "${u}"

  # Locking user.
  echo "--- [${u^^}] Locking user..."
  ${usermod} -L "${u}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER / 0002.
# -------------------------------------------------------------------------------------------------------------------- #

u0002() {
  local u='u0002'
  local p

  # Creating user.
  echo "--- [${u^^}] Adding user..."
  ${useradd} -m -c "${u^^}" "${u}"

  # Changing password.
  echo "--- [${u^^}] Changing password..."
  read -rp 'Password: ' p </dev/tty
  echo "${u}:${p}" | ${chpasswd}

  # Changing shell.
  echo "--- [${u^^}] Changing shell..."
  ${chsh} -s '/bin/zsh' "${u}"

  # GRML Zsh.
  _grml "${u}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION SCRIPTS.
# -------------------------------------------------------------------------------------------------------------------- #

conf() {
  local conf=(
    'apt'
    'ssh'
    'sysctl'
  )

  for i in "${conf[@]}"; do
    echo "--- [${i^^}] Installing a configuration..."
    curl -sL "https://uaik.github.io/conf/${i}.sh" | bash -
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# USER HOME DIRECTORY.
# -------------------------------------------------------------------------------------------------------------------- #

_home() {
  local u="${1}"
  local d; d=$( ${awk} -F ':' -v u="${u}" '{if ($1==u) print $6}' '/etc/passwd' )

  echo "${d}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# GRML.
# -------------------------------------------------------------------------------------------------------------------- #

_grml() {
  local u="${1}"
  echo "--- [${u^^}] Download 'grml-zsh-config' for '${u^^}'..."
  local d; d=$( _home "${u}" )
  [[ -f "${d}/.zshrc" ]] && ${mv} "${d}/.zshrc" "${d}/.zshrc.orig"
  ${wget} -O "${d}/.zshrc.grml" 'https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc'
  ${cat} > "${d}/.zshrc" <<EOF
. "\${HOME}/.zshrc.grml"
export GPG_TTY=\$(tty)
EOF
  for i in '.zshrc' '.zshrc.grml'; do
    ${chown} ${u}:${u} "${d}/${i}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
