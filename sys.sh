#!/usr/bin/env bash

################################################################################
#
# Bash system utility functions
#
# WARNING: This is not an executable script. This script is meant to be used as
# a utility by sourcing this script for efficient bash script writing.
#
################################# Functions ###################################
#
# is_wsl()
# set_nameserver()
# restore_nameserver()
#
################################################################################
# Author:   Mark Lucernas <https://github.com/marklcrns>
# Date:     2021-05-31
################################################################################

if [ "${0##*/}" == "${BASH_SOURCE[0]##*/}" ]; then
	echo "WARNING: $(realpath -s "$0") is not meant to be executed directly!" >&2
	echo "Use this script only by sourcing it." >&2
	exit 1
fi

# Header guard
[[ -z "${COMMON_SYSTEM_SH_INCLUDED+x}" ]] &&
	readonly COMMON_SYSTEM_SH_INCLUDED=1 ||
	return 0

is_wsl() {
	(grep -qEi "(microsoft|WSL)" /proc/version &>/dev/null) &&
		return 0 ||
		return 1
}

is_wsl2() {
	(grep -qEi "(WSL2)" /proc/version &>/dev/null) &&
		return 0 ||
		return 1
}

# Ref: https://unix.stackexchange.com/a/6348
os_release() {
	if [[ -f '/etc/os-release' ]]; then
		# freedesktop.org and systemd
		. /etc/os-release
		OS_DISTRIB_ID="${NAME}"
		OS_DISTRIB_RELEASE="${VERSION_ID}"
		OS_DISTRIB_CODENAME="${VERSION_CODENAME}"
	elif type lsb_release >/dev/null 2>&1; then
		# linuxbase.org
		OS_DISTRIB_ID="$(lsb_release -si)"
		OS_DISTRIB_RELEASE="$(lsb_release -sr)"
		OS_DISTRIB_CODENAME="$(lsb_release -sc)"
	elif [[ -f '/etc/lsb-release' ]]; then
		# For some versions of Debian/Ubuntu without lsb_release command
		. /etc/lsb-release
		OS_DISTRIB_ID="${DISTRIB_ID}"
		OS_DISTRIB_RELEASE="${DISTRIB_RELEASE}"
		OS_DISTRIB_CODENAME="${DISTRIB_CODENAME}"
	else
		# Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
		OS_DISTRIB_ID=$(uname -s)
		OS_DISTRIB_RELEASE=$(uname -r)
		OS_DISTRIB_CODENAME=""
	fi

	# lowercase
	OS_DISTRIB_ID=$(echo "${OS_DISTRIB_ID}" | tr '/A-Z/' '/a-z/')
	OS_DISTRIB_CODENAME=$(echo ${OS_DISTRIB_CODENAME} | tr '/A-Z/' '/a-z/')
}

is_darwin() {
	[[ "$(uname)" == "Darwin" ]] &&
		return 0 ||
		return 1
}

is_mac_os() {
	is_darwin
	return $?
}

is_linux() {
	[[ "$(expr substr "$(uname -s)" 1 5)" == "Linux" ]] &&
		return 0 ||
		return 1
}

# Set nameserver to $1 after backing up resolve.conf to /tmp/nameserver.bak
# Setting nameserver to "8.8.8.8" fixes connection issue when updating apt packages
set_nameserver() {
	if ! is_wsl; then
		echo "ERROR: Not running in Microsoft WSL" >&2
		exit 1
	fi

	local nameserver="${1:-8.8.8.8}"
	local nameserver_path="/etc/resolv.conf"
	local nameserver_bak="nameserver.bak"
	local nameserver_bak_dir="/tmp"

	cat "${nameserver_path}" >"${nameserver_bak_dir}/${nameserver_bak}"
	echo "nameserver ${nameserver}" | sudo tee "${nameserver_path}" &>/dev/null
}

restore_nameserver() {
	if ! is_wsl; then
		echo "ERROR: Not running in Microsoft WSL" >&2
		exit 1
	fi

	local nameserver_path="/etc/resolv.conf"
	local nameserver_bak="nameserver.bak"
	local nameserver_bak_dir="/tmp"

	[[ -e "${nameserver_bak_dir}/${nameserver_bak}" ]] &&
		cat "${nameserver_bak_dir}/${nameserver_bak}" |
		sudo tee "${nameserver_path}" &>/dev/null |
			rm "${nameserver_bak_dir}/${nameserver_bak}"
}
