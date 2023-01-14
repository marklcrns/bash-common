#!/usr/bin/env bash

################################################################################
#
# Defines include function that source script module if existing
#
# WARNING: This is not an executable script. This script is meant to be used as
# a utility by sourcing this script for efficient bash script writing.
#
################################################################################
# Author : Mark Lucernas <https://github.com/marklcrns>
# Date   : 2021-06-15
################################################################################

if [ "${0##*/}" == "${BASH_SOURCE[0]##*/}" ]; then
	echo "WARNING: $(realpath -s $0) is not meant to be executed directly!" >&2
	echo "Use this script only by sourcing it." >&2
	exit 1
fi

# Header guard
[[ -z "${COMMON_INCLUDE_SH_INCLUDED+x}" ]] &&
	readonly COMMON_INCLUDE_SH_INCLUDED=1 ||
	return 0

source "${BASH_SOURCE%/*}/log.sh"

include() {
	local module="${1:-}"

	if [[ -z "${module}" ]]; then
		log 'warn' "Empty include module"
		return
	fi

	if [[ -e "${module}" ]]; then
		source "${module}"
	else
		log 'error' "${module} module does not exist"
		exit 1
	fi
}
