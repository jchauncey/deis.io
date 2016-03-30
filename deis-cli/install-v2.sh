#!/usr/bin/env bash

# Invoking this script:
#
# curl https://deis.io/deis-cli/install-v2-alpha.sh | sh
#
# - download deis file
# - making sure deis is executable
# - explain what was done
#

set -eo pipefail -o nounset

function check_platform_arch {
  local supported="linux-amd64 darwin-amd64"

  if ! echo "${supported}" | tr ' ' '\n' | grep -q "${PLATFORM}-${ARCH}"; then
    cat <<EOF

${PROGRAM} is not currently supported on ${PLATFORM}-${ARCH}.

See https://github.com/deis/workflow for more information.

EOF
  fi
}

function get_latest_version {
  local url="${1}"
  local version
  version="$(curl -sI "${url}" | grep "Location:" | sed -n 's%.*deis/%%;s%/view.*%%p' )"

  if [ -z "${version}" ]; then
    echo "There doesn't seem to be a version of ${PROGRAM} avaiable at ${url}." 1>&2
    return 1
  fi

  url_decode "${version}"
}

function url_decode {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}

PLATFORM="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
DEIS_ARTIFACT_REPO="${DEIS_ARTIFACT_REPO:-"deisci"}"
DEIS_VERSION_URL="https://bintray.com/deis/${DEIS_ARTIFACT_REPO}/deis/_latestVersion"
DEIS_BIN_URL_BASE="https://dl.bintray.com/deis/${DEIS_ARTIFACT_REPO}"

if [ "${ARCH}" == "x86_64" ]; then
  ARCH="amd64"
fi

check_platform_arch

VERSION="$(get_latest_version "${DEIS_VERSION_URL}")"
DEIS_CLI="deis-${VERSION}-${PLATFORM}-${ARCH}"

echo "Downloading ${DEIS_CLI} from Bintray... ${DEIS_BIN_URL_BASE}/${DEIS_CLI}"
curl -L -k "${DEIS_BIN_URL_BASE}/${DEIS_CLI}" -O

chmod +x "${DEIS_CLI}"
mv "${DEIS_CLI}" deis

cat <<EOF

deis is now available in your current directory.

To learn more about deis, execute:

    $ ./deis --help

EOF
