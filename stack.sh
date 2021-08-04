#!/usr/bin/env bash

################################################################################
#
# Bash stack data structure
#
# WARNING: This is not an executable script. This script is meant to be used as
# a utility by sourcing this script for efficient bash script writing.
#
################################################################## Functions ###
#
# stack_new()
# stack_destroy()
# stack_push()
# stack_print()
# stack_size()
# stack_pop()
# no_such_stack()
# stack_exists()
#
# Sample usage: Push "item1 item2 item3" into "new_stack" stack
#
# stack_new new_stack
# stack_push new_stack "item1 item2 item3"
#
################################################################################
# Author : Mark Lucernas <https://github.com/marklcrns>
# Date   : 2021-06-01
################################################################################
# Credits: https://gist.github.com/bmc/1323553
################################################################################


if [ "${0##*/}" == "${BASH_SOURCE[0]##*/}" ]; then
  echo "WARNING: $(realpath -s $0) is not meant to be executed directly!" >&2;
  echo "Use this script only by sourcing it." >&2;
  exit 1
fi

# Header guard
[[ -z "${COMMON_STACK_SH_INCLUDED+x}" ]] \
  && readonly COMMON_STACK_SH_INCLUDED=1 \
  || return 0


# Usage: stack_new name
#
# Example: stack_new x

# Create a new stack.
# @param $1   Stack variable name
# @return     Return 0 if stack exists, else 1
function stack_new {
  : ${1?'Missing stack name'}

  if stack_exists ${1}; then
    echo "Stack already exists -- $1" >&2
    return 1
  fi

  eval "declare -ag _stack_$1"
  eval "declare -ig _stack_$1_i"
  eval "let _stack_$1_i=0"
  return 0
}

#
# Destroy a stack
# @param $1   Stack variable name
# @return     Return 0
function stack_destroy {
  : ${1?'Missing stack name'}
  eval "unset _stack_$1 _stack_$1_i"
  return 0
}

# Push one or more element into a stack.
# @param $1   Stack variable name
# @param $2   Element(s) to push
# @return     Return 0 if push successful, else 1
function stack_push {
  : ${1?'Missing stack name'}
  : ${2?'Missing element(s) to push'}

  if no_such_stack $1; then
    echo "No such stack -- $1" >&2
    return 1
  fi

  _stack=$1
  shift 1

  while (( $# > 0 )); do
    eval '_i=$'"_stack_${_stack}_i"
    eval "_stack_${_stack}[$_i]='$1'"
    eval "let _stack_${_stack}_i+=1"
    shift 1
  done

  unset _i
  return 0
}

# Print a stack to stdout.
# @param $1   Stack variable name
# @return     Return 0 if print successful, else 1
function stack_print {
  : ${1?'Missing stack name'}

  if no_such_stack $1; then
    echo "No such stack -- $1" >&2
    return 1
  fi

  tmp=""
  eval 'let _i=$'_stack_$1_i
  while (( $_i > 0 )); do
    let _i=${_i}-1
    eval 'e=$'"{_stack_$1[$_i]}"
    tmp="$tmp $e"
  done
  echo "(" $tmp ")"

  return 0
}

# Get the size of a stack
# @param $1   Stack variable name
# @param $2   Variable name to store stack size
# @return     Return 0 if stack exist, else 1
function stack_size {
  : ${1?'Missing stack name'}
  : ${2?'Missing name of variable for stack size result'}

  if no_such_stack $1; then
    echo "No such stack -- $1" >&2
    return 1
  fi

  eval "$2"='$'"{#_stack_$1[*]}"
  return 0
}

# Pop the top element from the stack.
# @param $1   Stack variable name
# @param $2   Variable name to store stack element
# @return     Return 0 if stack exist, else 1
function stack_pop {
  : ${1?'Missing stack name'}
  : ${2?'Missing name of variable for popped result'}

  eval 'let _i=$'"_stack_$1_i"
  if no_such_stack $1; then
    echo "No such stack -- $1" >&2
    return 1
  fi

  if [[ "$_i" -eq 0 ]]; then
    echo "Empty stack -- $1" >&2
    return 1
  fi

  let _i-=1
  eval "$2"='$'"{_stack_$1[$_i]}"
  eval "unset _stack_$1[$_i]"
  eval "_stack_$1_i=$_i"
  unset _i

  return 0
}

# Check if stack variable already exists
# @param $1   Stack variable name
# @return     Return 1 if stack exist, else 0
function stack_exists {
  : ${1?'Missing stack name'}

  eval '_i=$'"{_stack_$1_i:-}"
  [[ -z "$_i" ]] && return 1 || return 0
}

# Check if stack variable does not exists
# @param $1   Stack variable name
# @return     Return 0 if stack exist, else 1
function no_such_stack {
  : ${1?'Missing stack name'}
  stack_exists $1
  ret=$?
  declare -i x
  let x="1-$ret"

  return $x
}

