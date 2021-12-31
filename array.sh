#!/usr/bin/env bash

################################################################################
#
# Bash array manipulation utility functions
#
# WARNING: This is not an executable script. This script is meant to be used as
# a utility by sourcing this script for efficient bash script writing.
#
################################################################## Functions ###
#
# array_has_element()
# print_array_column()
#
################################################################################
# Author : Mark Lucernas <https://github.com/marklcrns>
# Date   : 2021-06-01
################################################################################


if [ "${0##*/}" == "${BASH_SOURCE[0]##*/}" ]; then
  echo "WARNING: $(realpath -s $0) is not meant to be executed directly!" >&2;
  echo "Use this script only by sourcing it." >&2;
  exit 1
fi

# Header guard
[[ -z "${COMMON_ARRAY_SH_INCLUDED+x}" ]] \
  && readonly COMMON_ARRAY_SH_INCLUDED=1 \
  || return 0


# Check if an element is in array
# @param $1   Element to find
# @param $2   Array variable to search from
# @return     Return 0 if the element is in array, else 1
array_has_element() {
  local __match="$1"
  shift 1

  local arr=
  for arr; do
    [[ "${arr}" == "${__match}" ]] && return 0
  done
  return 1
}


# Print array in columns with 8 character padding. Uses column utility.
# @param $@   Array
print_array_column() {
  local __array=("${@}")

  for value in "${__array[@]}"; do
    printf "%-8s\n" "${value}"
  done | column
}


array_unique() {
  : ${1:?Missing array name}
  local __unique=( $(eval "echo \${$1[*]} | tr ' ' '\012' | uniq") )
  eval "${1}=( ${__unique[@]} )"
}
