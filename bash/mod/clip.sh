#!/bin/bash

function _dt_term_socket_ssh() 
{
	ssh -oControlPath=$1 -O exit DUMMY_HOST
}

function ssh-with-clipboard()
{
	local temporary=$(mktemp -u --tmpdir ssh.sock.XXXXXXXXXX)
	local clipboard="$HOME/clip"

  # Make master connection and create socket file
	ssh -f -oControlMaster=yes -oControlPath=$temporary $@ tail\ -f\ /dev/null || return 1

  # Create fifo file
	ssh -S$temporary DUMMY_HOST "bash -c 'if ! [ -p $clipboard ]; then mkfifo $clipboard; fi'" \
		|| { _dt_term_socket_ssh $temporary; return 1; }

  # Silent clipboard listener 
	(
    set -e
    set -o pipefail
    while [ 1 ]; do
      ssh -S$temporary -tt DUMMY_HOST "cat $clipboard" 2> /dev/null | xclip -selection clipboard
    done &
	)

  # Make actual session
	ssh -S$temporary DUMMY_HOST \
		|| { _dt_term_socket_ssh $temporary; return 1; }

  # Clean up on exit
	ssh -S$temporary DUMMY_HOST "command rm $clipboard"
	_dt_term_socket_ssh $temporary
}
