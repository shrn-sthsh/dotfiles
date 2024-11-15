#!/bin/bash

function hf()
{
  if [ "$1" == "key" ]; then
    if [ "$2" == "-v" ] || [ "$2" == "--verbose" ]; then
      unzip $HOME/Projects/hf.zip hfkey && \
        cat hfkey && rm hfkey

    elif [[ "$OSTYPE" == "darwin"* ]]; then
      unzip $HOME/Projects/hf.zip hfkey && \
        cat hfkey | pbcopy && \
        rm hfkey

    elif [ "$OSTYPE" == "linux-gnu" ]; then
      if [[ $(tty) =~ "/dev/tty" ]]; then
        unzip $HOME/Projects/hf.zip hfkey && \
          cat hfkey && rm hfkey

      elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        unzip $HOME/Projects/hf.zip hfkey && \
          cat hfkey | wl-copy && \
          rm hfkey 

      else 
        zip $HOME/Projects/hf.zip hfkey && \
          cat hfkey | xsel --clipboard && \
          rm hfkey
      fi
    fi

  else
    echo "ERROR: Unknown subcommand"
  fi
}
