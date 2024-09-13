#!/bin/bash

# status + clear
function clean ()
{
  clear
  echo ""
  fastfetch
  echo ""
}

# toggle between TTY and window-manager
function switch_graphical_mode ()
{
  if pgrep -x sway > /dev/null; then
    sway exit
  else
    sway
  fi
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
