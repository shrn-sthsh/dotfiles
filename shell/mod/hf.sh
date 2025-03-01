#!/bin/sh


# known key paths and filenames
hf_key_comp="$HOME/.keys/hf.zip"
hf_key_file="hfkey"

# Hugging Face master API
function hf()
{
  if [ "$1" == "key" ];
  then
    if [ "$2" == "-v" ] || [ "$2" == "--verbose" ];
    then
      unzip "$hf_key_comp" "$hf_key_file" && \
        cat hfkey && rm hfkey

    elif [[ "$OSTYPE" == "darwin"* ]];
    then
      unzip "$hf_key_comp" "$hf_key_file" && \
        cat hfkey | pbcopy && \
        rm hfkey

    elif [ "$OSTYPE" == "linux-gnu" ];
    then
      if [[ $(tty) =~ "/dev/tty" ]];
      then
        unzip "$hf_key_comp" "$hf_key_file" && \
          cat hfkey && rm hfkey

      elif [ "$XDG_SESSION_TYPE" == "wayland" ];
      then
        unzip "$hf_key_comp" "$hf_key_file" && \
          cat hfkey | wl-copy && \
          rm hfkey 

      else 
        zip "$hf_key_comp" "$hf_key_file" && \
          cat hfkey | xsel --clipboard && \
          rm hfkey
      fi
    fi

  else
    if type huggingface-cli &> /dev/null;
    then
      command huggingface-cli "$@"

    elif [[ $- != *i* ]];
    then
      echo "ERROR: Hugging Face CLI is not installed"
      return 1

    else
      return 1
    fi
  fi
}
