#!/bin/bash


# import print utilities
terminal_source_file="$HOME/.dotfiles/bash/util/terminal.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $terminal_source_file " ]]; then

  if [ -f $terminal_source_file ] ; then
    source $terminal_source_file

  else
    if [[ $- != *i* ]]; then
      echo "ERROR: VPN commands require 'safe_echo' command from terminal utility"
    fi

    return 1
  fi
fi


# vpn service
alias openconnect='sudo openconnect --background'
function vpn()
{
  if [ $# -eq 0 ]; then
    safe_echo "ERROR: Subcommand must be provided"
    return 1
  fi

  # status
  if [ $1 == "status" ] || [ $1 == "stat" ]; then
    vpn-status

  # key
  elif [ "$1" == "key" ]; then
    vpn-key $2 $3

  # connect
  elif [ $1 == "connect" ] || [ $1 == "conn" ]; then
    vpn-connect ${@:2}

  # disconnect
  elif [ $1 == "disconnect" ] || [ $1 == "disc" ]; then
    vpn-disconnect 

  # unknown command
  else
    safe_echo "ERROR: Unknown command [$1]"
  fi

  return 0
}

function vpn-status()
{
  local pids=$(pgrep openconnect)
    if [ -n "$pids" ]; then
      safe_echo "STATUS: connected to VPN"
    else
      safe_echo "STATUS: not connected to VPN"
    fi
  
  return 0
}

function vpn-key()
{
  if [ -z "$1" ]; then
    safe_echo "ERROR: Must provide path to key or known vpn hostkey"
    return 1
  elif [ "$1" == "gt" ]; then
    local keypath="$HOME/Projects/gtvpn.zip"
    local keyfile="gtvpnkey"
  else
    local keypath="$2"
    local keyfile=$(basename "$HOME/Projects/vpn.zip" .zip | sed 's/^//;s/.*\///')
  fi 

  if ! [ -f $keypath ]; then
    safe_echo "ERROR: path to key specifed doesn't exist"
    return 1
  fi

  if [ "$2" == "-v" ] || [ "$2" == "--verbose" ]; then
    unzip $keypath $keyfile && \
      cat $keyfile && rm $keyfile

  elif [[ "$OSTYPE" == "darwin"* ]]; then
    unzip $keypath $keyfile && \
      cat $keyfile | pbcopy && \
      rm $keyfile

  elif [ "$OSTYPE" == "linux-gnu" ]; then
    if [[ $(tty) =~ "/dev/tty" ]]; then
      unzip $keypath $keyfile && \
        cat $keyfile && rm $keyfile 

    elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
      unzip $keypath $keyfile && \
        cat $keyfile | wl-copy && \
        rm $keyfile 

    else 
      zip $keypath $keyfile && \
        cat $keyfile | xsel --clipboard && \
        rm $keyfile
    fi
  fi

  return 0
}

function vpn-connect()
{
  local pids=$(pgrep openconnect)

  if [ -n "$pids" ]; then
    safe_echo "ERROR: Already connected to VPN"
    return 1
  fi

  if [ $# -lt 1 ]; then
    safe_echo "ERROR: connection arguments must be provided"
    return 1
  fi

  if [ "$1" == "gt" ]; then
    local keypath="$HOME/Projects/gtvpn.zip"
    local keyfile="gtvpnkey"

    if ! [ -f $keypath ]; then
      safe_echo -e "WARNING: path to vpn key doesn't exist; must enter passkey manually\n"

      openconnect --protocol=gp \
        --server=vpn.gatech.edu \
        --user=ssathish6 \
        --authgroup=DC
    else
      unzip $keypath $keyfile > /dev/null
      (cat $keyfile; rm $keyfile; sleep 1; safe_echo "push") | \
      openconnect --protocol=gp \
        --server=vpn.gatech.edu \
        --user=ssathish6 \
        --authgroup=DC \
        --passwd-on-stdin
    fi

  else
    openconnect ${@:1}
  fi

  return 0
}

function vpn-disconnect()
{
  local pids=$(pgrep openconnect)

  if [ -n "$pids" ]; then
    local alive=$(wc -w <<< $pids)
    for pid in $pids; do
      sudo kill -9 "$pid"
      ((alive--)) 
    done

    if [ "$alive" -eq 0 ]; then
      safe_echo "STATUS: VPN connection closed"
    else
      safe_echo "STATUS: Unable to close VPN instance"
    fi
  else
    safe_echo "STATUS: not connected to VPN"
  fi

  return 0
}
