#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  cat=$( command -v cat )
  curl=$( command -v curl )
  gpg=$( command -v gpg )

  # OS.
  osId=$( . '/etc/os-release' && echo "${ID}" )

  # Run.
  [[ "${osId}" == 'debian' ]] && { debian; }
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  local gpg_d='/etc/apt/keyrings'; local gpg_f='kernel.xanmod.gpg'; [[ ! -d "${gpg_d}" ]] && exit 1
  local list_d='/etc/apt/sources.list.d'; local list_f='kernel.xanmod.sources'; [[ ! -d "${list_d}" ]] && exit 1
  local key='https://dl.xanmod.org/archive.key'

  ${curl} -fsSL "${key}" | ${gpg} --dearmor -o "${gpg_d}/${gpg_f}"
  ${cat} > "${list_d}/${list_f}" <<EOF
X-Repolib-Name: Kernel (XanMod)
Enabled:        yes
Types:          deb
URIs:           http://deb.xanmod.org
Suites:         releases
Components:     main
Architectures:  $( dpkg --print-architecture )
Signed-By:      ${gpg_d}/${gpg_f}
EOF
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
