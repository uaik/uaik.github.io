#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  cat=$( command -v cat )

  # OS.
  osId=$( . '/etc/os-release' && echo "${ID}" )
  osCodeName=$( . '/etc/os-release' && echo "${VERSION_CODENAME}" )

  # Run.
  case "${osId}" in
    'debian')
      debian
      ;;
    *)
      echo 'OS is not supported!' && exit 1
      ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# DEBIAN.
# -------------------------------------------------------------------------------------------------------------------- #

debian() {
  init() {
    conf && repo
  }

  conf() {
    local d='/etc/apt/apt.conf.d'; [[ ! -d "${d}" ]] && exit 1

    echo 'APT::Install-Suggests "false";' \
      > "${d}/00InstallSuggests"
  }

  repo() {
    local d='/etc/apt/sources.list.d'; [[ ! -d "${d}" ]] && exit 1

    ${cat} > "${d}/debian.backports.sources" <<EOF
X-Repolib-Name: Debian Backports
Enabled:        yes
Types:          deb
URIs:           http://deb.debian.org/${osId}
Suites:         ${osCodeName}-backports
Components:     main contrib non-free
Architectures:  $( dpkg --print-architecture )
EOF
  }

  init
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
