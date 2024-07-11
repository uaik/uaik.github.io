#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# Apps.
curl=$( command -v 'curl' )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() { config; }

# -------------------------------------------------------------------------------------------------------------------- #
# SYSCTL.
# -------------------------------------------------------------------------------------------------------------------- #

config() {
  local d; d='/etc/sysctl.d'; [[ ! -d "${d}" ]] && exit 1
  local f; f=( '00-sysctl.local.conf' )
  for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/sysctl/${i}"; done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
