#!/usr/bin/env bash

################################################################################
#
# Bash utility constants
#
# WARNING: This is not an executable script. This script is meant to be used as
# a utility by sourcing this script for efficient bash script writing.
#
################################################################################
# Author:   Mark Lucernas <https://github.com/marklcrns>
# Date:     2022-01-01
################################################################################

if [ "${0##*/}" == "${BASH_SOURCE[0]##*/}" ]; then
	echo "WARNING: $(realpath -s $0) is not meant to be executed directly!" >&2
	echo "Use this script only by sourcing it." >&2
	exit 1
fi

# Header guard
[[ -z "${COMMON_CONST_SH_INCLUDED+x}" ]] &&
	readonly COMMON_CONST_SH_INCLUDED=1 ||
	return 0

# Special meaning exit codes
# https://tldp.org/LDP/abs/html/exitcodes.html
readonly BASH_EX_OK=0              # successful termination
readonly BASH_EX_GENERAL=1         # catchall for general errors
readonly BASH_EX_MISUSE=2          # misuse of shell builtins (e.g., missing arg or permission problem)
readonly BASH_EX_TIMEOUT=124       # command timout (unresponsive)
readonly BASH_EX_EXECERR=126       # command invoked cannot execute
readonly BASH_EX_NOTFOUND=127      # command not found
readonly BASH_EX_INVALIDEXARG=128  # invalid argument to 'exit'
readonly BASH_EX_SIGFATAL_BASE=128 # fatal error signal "n"
readonly BASH_EX_TERMCTRLC=130     # terminated by Ctrl-c

# sysexits.h
# /usr/include/sysexits.h/ or `man sysexits`
readonly BASH_SYS_EX__BASE=64       # base value for error messages
readonly BASH_SYS_EX_USAGE=64       # command line usage error
readonly BASH_SYS_EX_DATAERR=65     # data format error
readonly BASH_SYS_EX_NOINPUT=66     # cannot open input
readonly BASH_SYS_EX_NOUSER=67      # addressee unknown
readonly BASH_SYS_EX_NOHOST=68      # host name unknown
readonly BASH_SYS_EX_UNAVAILABLE=69 # service unavailable
readonly BASH_SYS_EX_SOFTWARE=70    # internal software error
readonly BASH_SYS_EX_OSERR=71       # system error (e.g., can't fork)
readonly BASH_SYS_EX_OSFILE=72      # critical OS file missing
readonly BASH_SYS_EX_CANTCREAT=73   # can't create (user) output file
readonly BASH_SYS_EX_IOERR=74       # input/output error
readonly BASH_SYS_EX_TEMPFAIL=75    # temp failure; user is invited to retry
readonly BASH_SYS_EX_PROTOCOL=76    # remote error in protocol
readonly BASH_SYS_EX_NOPERM=77      # permission denied
readonly BASH_SYS_EX_CONFIG=78      # configuration error
readonly BASH_SYS_EX__MAX=78        # maximum listed value
