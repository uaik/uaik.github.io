#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# Apps.
curl=$( command -v 'curl' )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

run() { config; }

# -------------------------------------------------------------------------------------------------------------------- #
# SSHD.
# -------------------------------------------------------------------------------------------------------------------- #

config() {
  local d; d='/etc/ssh/sshd_config.d'; [[ ! -d "${d}" ]] && exit 1
  local f; f=('00-sshd.local.conf')
  for i in "${f[@]}"; do ${curl} -fsSLo "${d}/${i}" "https://uaik.github.io/conf/ssh/${i}"; done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
