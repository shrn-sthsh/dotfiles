#!/bin/sh

## Terminal
# default editor
export VISUAL="nvim"
export EDITOR="$VISUAL"

## Files
# shell configurations
if [[ "$0" == *zsh* ]];
then
  export rc="$HOME/.zshrc"
  export pf="$HOME/.zshenv"

elif [[ "$0" == *bash* ]];
then
  export rc="$HOME/.bashrc"
  export pf="$HOME/.bash_profile"
fi

## Directories
# common
if [ -d "$HOME/.dotfiles" ];
then
  export dot="$HOME/.dotfiles"
fi
if [ -d "$HOME/Desktop" ];
then
  export desk="$HOME/Desktop"
fi
if [ -d "$HOME/Documents" ];
then
  export docs="$HOME/Documents"
fi
if [ -d "$HOME/Downloads" ];
then
  export down="$HOME/Downloads"
fi
if [ -d "$HOME/Music" ];
then
  export musi="$HOME/Music"
fi
if [ -d "$HOME/Projects" ];
then
  export proj="$HOME/Projects"
fi
if [ -d "$HOME/Public" ];
then
  export pub="$HOME/Public"
fi
if [ -d "$HOME/School" ];
then
  export sch="$HOME/School"
fi
if [ -d "$HOME/System" ];
then
  export sys="$HOME/System"
fi
if [ -d "$HOME/Videos" ];
then
  export vids="$HOME/Videos"
fi
