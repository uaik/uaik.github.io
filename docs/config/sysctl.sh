#!/usr/bin/env -S bash -e
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() { sysctl && gai; }

# -------------------------------------------------------------------------------------------------------------------- #
# SYSCTL
# -------------------------------------------------------------------------------------------------------------------- #

sysctl() {
  local d; d='/etc/sysctl.d'; [[ ! -d "${d}" ]] && exit 1
  local f; f=('00-sysctl.local.conf')

  for i in "${f[@]}"; do
    curl -fsSLo "${d}/${i}" "https://uaik.github.io/config/sysctl/${i}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# GAI
# -------------------------------------------------------------------------------------------------------------------- #

gai() {
  local f; f='/etc/gai.conf'; [[ ! -f "${f}" ]] && exit 1

  sed -i -e 's|#precedence ::ffff:0:0/96  100|precedence ::ffff:0:0/96  100|g' "${f}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
