#!/bin/bash


# import print utilities
terminal_source_file="$HOME/.dotfiles/shell/util/terminal.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $terminal_source_file " ]]; then

  if [ -f $terminal_source_file ]; then
    source $terminal_source_file

  else
    if [[ $- != *i* ]]; then
      echo "ERROR: VPN commands require 'safe_echo' command from terminal utility"
    fi

    return 1
  fi
fi


## Default universal X clipboard
# try xsel then xclip if fails
status=0
safe_alias sclip="xsel -b" || status=1
if [ "$status" -ne 0 ]; then
  safe_alias sclip="xclip" || status=1
fi


## SSH with better clipboard
# SSH with pipe clipboard exit
function terminate_ssh_socket() 
{
  local socket="$1"
  local HOST="$2"
  local remote_clipboard="$3"

  # wait until no other processes are using the socket
  while true; do
    local active_sessions
    active_sessions=$(pgrep -af "ssh .* -oControlPath=$socket" | wc -l)

    if [[ "$active_sessions" -le 1 ]]; then
      break
    fi

    # spin for a period before checking again
    sleep 1
  done

  # delete the remote clipboard pipe
  command ssh -oControlPath="$socket" "$HOST" "rm -f $remote_clipboard"

  # close primary connection
  command ssh -oControlPath="$socket" -O exit "$HOST"
}

# SSH with pipe clipboard
function csh()
{ 
  # parse arguments and options
  local HOST=""
  local ARGS=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -*) ARGS+=("$1") ;; # options
      *)  HOST="$1" ;;    # arguments
    esac
    shift
  done

  # ensure a host argument is provided
  if [[ -z "$1" ]]; then
    safe_echo "Error: No host specified"
    return 1
  fi

  # socket file and primary connection
  local socket=$(mktemp -u --tmpdir ssh.sock.XXXXXXXXXX)
  command ssh -f -oControlMaster=yes -oControlPath=$socket "$HOST" tail\ -f\ /dev/null || return 1

  # set local variables
  local LOCAL_HOME="$HOME"
  local local_clipboard="$LOCAL_HOME/.clipboard"

  # set remote variables
  local REMOTE_HOME=$(command ssh -X -S$socket "$HOST" 'echo $HOME')
  local remote_clipboard="$REMOTE_HOME/.clipboard"

  # fifo file on the remote server
  command ssh -X -S"$socket" "$HOST" "bash -c 'mkdir -p $REMOTE_HOME && \
    [ -p $REMOTE_HOME/.clipboard ] || mkfifo $REMOTE_HOME/.clipboard'" \
    || { terminate_ssh_socket "$socket" "$HOST" "$remote_clipboard"; return 1; }

  # silent clipboard listener: read remote pipe and sync to local clipboard
  (
    set -e
    set -o pipefail

    while true; do
      if [[ "$OSTYPE" == "darwin"* ]]; then
        command ssh -X -S$socket -tt "$HOST" "cat $remote_clipboard" 2> /dev/null | pbcopy
      else
        command ssh -X -S$socket -tt "$HOST" "cat $remote_clipboard" 2> /dev/null | xsel -b
      fi
    done &
  )

  # open actual SSH session
  safe_echo "$@"
  command ssh -X -S$socket "$HOST" "$@" \
    || { terminate_ssh_socket $socket $HOST $remote_clipboard; return 1; }

  # remove the remote named pipe and close master connection
  command ssh -X -S$socket "$HOST" "rm -f $REMOTE_HOME/.clipboard"
  terminate_ssh_socket $socket $HOST $remote_clipboard
}
