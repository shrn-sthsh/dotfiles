#!/bin/bash

# vpn service
alias openconnect='sudo openconnect --background'
function vpn ()
{
  if [ $# -eq 0 ]; then
    echo "ERROR: Subcommand must be provided"
    return
  fi

  # key
  if [ "$1" == "key" ]; then
    if [ "$2" == "gt" ]; then
      local keypath="$HOME/Projects/gtvpn.zip"
      local keyfile="gtvpnkey"
    else
      local keypath="$2"
      local keyfile=$(basename "$HOME/Projects/vpn.zip" .zip | sed 's/^//;s/.*\///')
    fi 

    if [ "$3" == "-v" ] || [ "$3" == "--verbose" ]; then
      unzip $keypath $keyfile && \
        cat $keyfile && rm $keyfile
    elif [ "$OSTYPE" == "darwin"* ]; then
      unzip $keypath $keyfile && \
        cat $keyfile | wl-copy && \
        rm $keyfile
    elif [ "$OSTYPE" == "linux-gnu" ]; then
      if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        unzip $keypath $keyfile && \
          cat $keyfile | wl-copy && \
          rm $keyfile 
      else 
        zip $keypath $keyfile && \
          cat $keyfile | xsel --clipboard && \
          rm $keyfile
      fi
    fi

  # connect
  elif [ $1 == "connect" ] || [ $1 == "conn" ]; then
    local pids=$(pgrep openconnect)
    if [ -n "$pids" ]; then
      echo "ERROR: Already connected to VPN"
      return
    fi

    if [ $# -lt 2 ]; then
      echo "ERROR: connection arguments must be provided"
      return
    fi

    if [ "$2" == "gt" ]; then
      openconnect --protocol=gp --server=vpn.gatech.edu --user=ssathish6 --authgroup=DC
    else
      openconnect ${@:2}
    fi

  # disconnect
  elif [ $1 == "disconnect" ] || [ $1 == "disc" ]; then
    local pids=$(pgrep openconnect)
    if [ -n "$pids" ]; then
      local alive=$(wc -w <<< $pids)
      for pid in $pids; do
        sudo kill -9 "$pid"
        ((alive--)) 
      done

      if [ "$alive" -eq 0 ]; then
        echo "STATUS: VPN connection closed"
      else
        echo "STATUS: Unable to close VPN instance"
      fi
    else
      echo "STATUS: not connected to VPN"
    fi

  # status
  elif [ $1 == "status" ] || [ $1 == "stat" ]; then
    local pids=$(pgrep openconnect)
    if [ -n "$pids" ]; then
      echo "STATUS: connected to VPN"
    else
      echo "STATUS: not connected to VPN"
    fi

  else
    echo "ERROR: Unknown command [$1]"

  fi
}
