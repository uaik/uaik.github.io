#!/usr/bin/env -S bash -e
#
# Configuration script.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# Checking commands.
cmd_check() { command -v "${1}" > /dev/null 2>&1 || { echo >&2 "Required: '${1}'."; exit 1; }; }

# Apps.
bash=$( command -v 'bash' ); cmd_check 'bash'
curl=$( command -v 'curl' ); cmd_check 'curl'

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() { conf "${1}"; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATIONS.
# -------------------------------------------------------------------------------------------------------------------- #

conf() {
  local c; c="${1}"; IFS=';' read -ra c <<< "${c}"

  for i in "${c[@]}"; do
    if local s; s=$( ${curl} -fsL "https://uaik.github.io/conf/${i}.sh" ); then
      echo "--- [${i^^}] Installing a configuration..."
      ${bash} -s <<< "${s}"
    else
      echo "--- [${i^^}] Configuration not found!"
      exit 1
    fi
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@" && exit 0 || exit 1
