#!/bin/bash

external_display="card0-HDMI-A-1"
tty_set="/dev/tty[1-6]"

# check if lid is closed
lid_closed=false
if command -v upower >/dev/null; 
then
  if upower -d | grep -q "lid-is-closed: *yes"; 
  then
    lid_closed=true
  fi
fi

echo "$lid_closed !!"

# check if external display is connected
external_connected=false
if [ -f "/sys/class/drm/$external_display/status" ]; 
then
  if grep -q "connected" "/sys/class/drm/$external_display/status"; 
  then
    external_connected=true
  fi
fi

echo "$external_connected??"

# turn off internal display
if $lid_closed && $external_connected; 
then
  for tty in $tty_set; do
    setterm --blank force --powerdown 1 --term linux < "$tty"
  done
fi

