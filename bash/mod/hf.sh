#!/bin/bash


# Hugging Face master API
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
    if type huggingface-cli &> /dev/null; then
      command huggingface-cli "$@"

    elif [[ $- != *i* ]]; then
      echo "ERROR: Hugging Face CLI is not installed"
      return 1

    else
      return 1
    fi
  fi
}
