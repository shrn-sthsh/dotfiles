#!/bin/bash

# toggle between TTY and window-manager
function switch_graphical_mode ()
{
  if pgrep -x sway > /dev/null; then
    sway exit
  else
    sway
  fi
}
