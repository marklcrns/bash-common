#!/usr/bin/env bash

################################################################################
#
# Common scripting utilities.
#
# WARNING: This is not an executable script. This script is meant to be used as
# a utility by sourcing this script for efficient bash script writing.
#
################################################################################
# Author : Mark Lucernas <https://github.com/marklcrns>
# Date   : 2021-06-15
################################################################################

set -o pipefail
set -o nounset

if [ "${0##*/}" == "${BASH_SOURCE[0]##*/}" ]; then
  echo "WARNING: $(realpath -s $0) is not meant to be executed directly!" >&2;
  echo "Use this script only by sourcing it." >&2;
  exit 1
fi

# Header guard
[[ -z "${COMMON_COMMON_SH_INCLUDED+x}" ]] \
  && readonly COMMON_COMMON_SH_INCLUDED=1 \
  || return 0


source "${BASH_SOURCE%/*}/sys.sh"
source "${BASH_SOURCE%/*}/colors.sh"
source "${BASH_SOURCE%/*}/log.sh"


usage_generic() {
  local scriptpath="$(realpath -- "${0}")"

cat <<- EOF
$(basename -- "${scriptpath}")

USAGE:

./$(basename -- "${scriptpath}") [ -hvxy ]

OPTIONS:

  -v --verbose   verbose output
  -x --debug     debug
  -y --skip      skip confirmation
  -h --help      show usage
EOF
}

handle_args_generic() {
  local arg=
  for arg; do
    local delim=""
    case "${arg}" in
      --verbose)        args="${args:-}-v ";;
      --debug)          args="${args:-}-x ";;
      --skip-confirm)   args="${args:-}-y ";;
      --help)           args="${args:-}-h ";;
      *)
        [[ "${arg:0:1}" == "-" ]] || delim="\""
        args="${args:-}${delim}${arg}${delim} ";;
    esac
  done

  eval set -- ${args:-}

  [[ -z "${SKIP_CONFIRM+x}" ]]    && SKIP_CONFIRM=false
  [[ -z "${VERBOSE+x}" ]]         && VERBOSE=false
  [[ -z "${DEBUG+x}" ]]           && DEBUG=false
  [[ -z "${LOG_DEBUG_LEVEL+x}" ]] && LOG_DEBUG_LEVEL=3

  OPTIND=1
  while getopts "m:p:vxyh" opt; do
    case ${opt} in
      v)
        [[ -z "${VERBOSE+x}" ]] && VERBOSE=true
        ;;
      x)
        [[ -z "${DEBUG+x}" ]]           && DEBUG=true
        [[ -z "${LOG_DEBUG_LEVEL+x}" ]] && LOG_DEBUG_LEVEL=7
        ;;
      y)
        [[ -z "${SKIP_CONFIRM+x}" ]] && SKIP_CONFIRM=true
        ;;
      h)
        usage; exit 0
        ;;
    esac
  done
  shift "$((OPTIND-1))"

  readonly SKIP_CONFIRM
  readonly VERBOSE
  readonly DEBUG
  readonly LOG_DEBUG_LEVEL

  return 0
}


script_vars() {
  SCRIPT_PATH="$(realpath -- "${0}")"
  while [ -h "${SCRIPT_PATH}" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
    SCRIPT_PATH="$(readlink "${SCRIPT_PATH}")"
    [[ "${SCRIPT_PATH}" != /* ]] && SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_PATH}"
  done
  SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
  SCRIPT_NAME="$(basename -- "${SCRIPT_PATH}")"

  readonly SCRIPT_PATH
  readonly SCRIPT_DIR
  readonly SCRIPT_NAME
}


confirm() {
  local prompt="${1:-Do you wish to continue? (Y/y): }"

  if ! ${SKIP_CONFIRM}; then
    ${BASH_SOURCE%/*}/confirm "${COLOR_YELLOW}${prompt}${COLOR_NC}"
    if [[ "${?}" -eq 1 ]]; then
      log 'warn' "${SCRIPT_PATH}: Aborted."
      exit 0
    elif [[ "${?}" -eq 2 ]]; then
      log 'error' "${SCRIPT_PATH}: Unsupported shell" 1
    fi
  fi
}

