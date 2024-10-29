#!/bin/bash

# echo only in interactive shell
function safe_echo()
{
  if [[ $- == *i* ]]; then
    echo "$@"
  fi

  return 0
}
