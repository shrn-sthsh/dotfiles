#!/bin/bash


# run main boot volume picker
volume_source_file="$HOME/.dotfiles/boot/macOS/select-volume.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $volume_source_file " ]]; then

  if [ -f $volume_source_file ]; then
    source $volume_source_file    

  else
    if [[ $- != *i* ]]; then
      echo "ERROR: macOS volume selection script is missing"
    fi

    return 1
  fi
fi

# reboot if option set
if [[ "$1" == "-r" ]]; then
  sudo shutdown -r now &> /dev/null
fi
