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

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  # Apps.
  bash="$( command -v 'bash' )"
  curl="$( command -v 'curl' )"

  # Run.
  conf "${1}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION SCRIPTS.
# -------------------------------------------------------------------------------------------------------------------- #

conf() {
  local conf; conf="${1}"; IFS=';' read -ra conf <<< "${conf}"

  for i in "${conf[@]}"; do
    if local script; script=$( ${curl} --fail -sL "https://uaik.github.io/conf/${i}.sh" ); then
      echo "--- [${i^^}] Installing a configuration..."
      ${bash} -s <<< "${script}"
    else
      echo "--- [${i^^}] Configuration not found!"
      exit 1
    fi
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run "$@"; exit 0
