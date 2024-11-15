#!/bin/bash

# ensure git is installed
git_source_file="$HOME/.dotfiles/bash/util/install.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $git_source_file " ]]; then

  if [ -f $git_source_file ]; then
    source $git_source_file    
    install_required_package "git"

  else
    echo "ERROR: Unable to check if git is installed"
    return 1
  fi
fi


# git with github key
function git-key()
{
  if [ "$1" == "-v" ] || [ "$1" == "--verbose" ]; then
    unzip $HOME/Projects/git.zip gitkey && \
      cat gitkey && rm gitkey

  elif [[ "$OSTYPE" == "darwin"* ]]; then
    unzip $HOME/Projects/git.zip gitkey && \
      cat gitkey | pbcopy && \
      rm gitkey

  elif [ "$OSTYPE" == "linux-gnu" ]; then
    if [[ $(tty) =~ "/dev/tty" ]]; then
      unzip $HOME/Projects/git.zip gitkey && \
        cat gitkey && rm gitkey

    elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
      unzip $HOME/Projects/git.zip gitkey && \
        cat gitkey | wl-copy && \
        rm gitkey 

    else 
      zip $HOME/Projects/git.zip gitkey && \
        cat gitkey | xsel --clipboard && \
        rm gitkey
    fi
  fi
}

function git()
{
  if [[ "$1" == "key" ]]; then
    git-key "${@:2}"

  elif [[ "$1" == "lc" ]]; then
    git ls-files | xargs wc -l

  else
    command git "$@"
  fi
}

# lines in a project
safe_alias git-lc='git ls-files | xargs wc -l'
