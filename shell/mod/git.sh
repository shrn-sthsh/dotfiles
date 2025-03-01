#!/bin/sh


# ensure git is installed
installer_source_file="$HOME/.dotfiles/shell/util/install.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $installer_source_file " ]];
then

  if [ -f $installer_source_file ];
  then
    source $installer_source_file    
    install_required_package "git"

  else
    if [[ $- != *i* ]];
    then
      echo "ERROR: Unable to check if git is installed"
    fi

    return 1
  fi
fi


# known key paths and filenames
git_key_comp="$HOME/.keys/git.zip"
git_key_file="gitkey"

# git with github key
function git-key()
{
  if [ "$1" == "-v" ] || [ "$1" == "--verbose" ];
  then
    unzip "$git_key_comp" "$git_key_file" && \
      cat "$git_key_file" && rm "$git_key_file"

  elif [[ "$OSTYPE" == "darwin"* ]];
  then
    unzip "$git_key_comp" "$git_key_file" && \
      cat "$git_key_file" | pbcopy && \
      rm "$git_key_file"

  elif [ "$OSTYPE" == "linux-gnu" ];
  then
    if [[ $(tty) =~ "/dev/tty" ]];
    then
      unzip "$git_key_comp" "$git_key_file" && \
        cat "$git_key_file" && rm "$git_key_file"

    elif [ "$XDG_SESSION_TYPE" == "wayland" ];
    then
      unzip "$git_key_comp" "$git_key_file" && \
        cat "$git_key_file" | wl-copy && \
        rm "$git_key_file" 

    else 
      zip "$git_key_file" && \
        cat "$git_key_file" | xsel --clipboard && \
        rm "$git_key_file"
    fi
  fi
}

function git()
{
  if [[ "$1" == "key" ]];
  then
    git-key "${@:2}"

  elif [[ "$1" == "lc" ]];
  then
    git ls-files | xargs wc -l

  else
    command git "$@"
  fi
}

# lines in a project
safe_alias git-lc='git ls-files | xargs wc -l'
