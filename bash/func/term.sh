#!/bin/bash

# status + clear
function clean ()
{
  clear
  echo ""
  fastfetch
  echo ""
}

# current python environment
function parse_python_env ()
{
  if [ -z "$VIRTUAL_ENV" ]; then
    echo ""
  else
    echo "{`basename \"VIRTUAL_ENV\"`} "
  fi
}
