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

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function _err() {
  echo >&2 "[$( date +'%Y-%m-%dT%H:%M:%S%z' )]: $*"; exit 1
}

function _title() {
  echo '' && echo "${1}" && echo ''
}

function config() {
  local c; c="${1}"; IFS=';' read -ra c <<< "${c}"

  for i in "${c[@]}"; do
    if local s; s="$( curl -fsL "https://uaik.github.io/config/${i}.sh" )"; then
      _title "--- [${i^^}] Installing a configuration..."; bash -s <<< "${s}"
    else
      _err "Configuration '${i^^}' not found!"
    fi
  done
}

function main() { config "${1}"; }; main "$@"
