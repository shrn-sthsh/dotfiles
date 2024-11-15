#!/bin/bash

# Script only for Linux Systems
if ! [[ "$OSTYPE" == "linux-gnu" ]]; then
  return 0
fi

# List of window-managers availible
managers=( 'sway' 'gnome' )

# Sway set up
export PATH="$PATH:$HOME/System/sway"

# GNOME setup
function gnome() 
{
  if [ "$1" == "exit" ]; then
    gnome-session-quit --logout --no-prompt
  else
    XDG_SESSION_TYPE=wayland dbus-run-session gnome-session
  fi
}

# Switch between window-managers and TTY
function mode()
{
  if [ -z "$1" ]; then
    echo "ERROR: Must provide a window manager to switch to"
    return 1
  fi

  # exit directly to tty
  if [[ "$1" == "tty" ]]; then
    for manager in "${managers[@}]}"; do
      if pgrep -x "$1" > /dev/null; then
        if ! $manager exit 2> /dev/null; then
          pkill -x "$manager"
        fi
      fi
    done
  fi

  for manager in "${managers[@}]}"; do
    if [[ "$1" == "$manager" ]]; then

      # if already running check before relaunching
      if pgrep -x "$1" > /dev/null; then
        read -p "$manager is already running. Do you want to relaunch? [y/N]: " choice

        # affirmitve relaunch
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
          if ! $manager exit 2> /dev/null; then
            pkill -x "$manager"
          fi
          exec "$@"

        # do not relaunch
        else
          echo "Aborting relaunch"
          exit 0
        fi        

      # switch to manager if not already running
      else   
        for other in "${managers[@}]}"; do
          if pgrep -x "$1" > /dev/null; then
            if ! $other exit 2> /dev/null; then
              pkill -x "$other"
            fi
          fi
        done

        exec "$@"
      fi

      return 0
    fi
  done
  
  echo "ERROR: Provided window manager is unknown"
}
