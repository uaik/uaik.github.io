#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  cat="$( command -v cat )"
  curl="$( command -v curl )"

  # OS.
  osId=$(. '/etc/os-release' && echo "${ID}")
  osCodeName=$(. '/etc/os-release' && echo "${VERSION_CODENAME}")

  # Run.
  [[ "${osId}" == 'debian' ]] && { debian; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  local gpg_d='/etc/apt/keyrings'; local gpg_f='kernel.zabbly.asc'; [[ ! -d "${gpg_d}" ]] && exit 1
  local list_d='/etc/apt/sources.list.d'; local list_f='kernel.zabbly.sources'; [[ ! -d "${list_d}" ]] && exit 1

  ${curl} -fsSLo "${gpg_d}/${gpg_f}" 'https://pkgs.zabbly.com/key.asc'
  ${cat} > "${list_d}/${list_f}" <<EOF
Enabled:        yes
Types:          deb deb-src
URIs:           https://pkgs.zabbly.com/kernel/stable
Suites:         ${osCodeName}
Components:     main zfs
Architectures:  $( dpkg --print-architecture )
Signed-By:      ${gpg_d}/${gpg_f}
EOF
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
