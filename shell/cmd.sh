#!/bin/sh


# import installer
installer_source_file="$HOME/.dotfiles/shell/util/install.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $installer_source_file " ]]; then

  if [ -f "$installer_source_file" ]; then
    source "$installer_source_file"

  else
    if [[ $- != *i* ]]; then
      echo "ERROR: Aliasing requires installer"
    fi 
    return 1
  fi
fi


## Aliasing control
# Run aliasing
function set_aliasing()
{
  # check for cache folder
  cache="$HOME/.dotfiles/shell/.cache"
  if ! [ -d "$cache" ]; then
    mkdir $cache
  fi 

  # check for alias cache
  alias_cache="$cache/alias.cache"
  if [[ -f "$alias_cache" ]]; then
    touch $alias_cache
  fi

  # set aliasing on and run
  echo "Y" > $alias_cache 
  source "$HOME/.bashrc"
}

# Run unaliasing
function unset_aliasing()
{
  # check for cache folder
  cache="$HOME/.dotfiles/shell/.cache"
  if ! [ -d "$cache" ]; then
    mkdir $cache
  fi 

  # check for alias cache
  alias_cache="$cache/alias.cache"
  if [[ -f "$alias_cache" ]]; then
    touch $alias_cache
  fi

  # set aliasing on and run
  echo "N" > $alias_cache 
  unalias -a
  source "$HOME/.bashrc"
}

function status_aliasing()
{
  # can only be run in interactive sessions
  if [[ $- != *i* ]]; then
    return 1
  fi

  # check for cache folder
  cache="$HOME/.dotfiles/shell/.cache"
  if ! [ -d "$cache" ]; then
    mkdir $cache
  fi 

  # check for alias cache
  alias_cache="$cache/alias.cache"
  if ! [[ -f "$alias_cache" ]]; then
    echo "ERROR: No alias cache" 
    return 0
  fi

  # read alias cache
  read -r alias_state < $alias_cache
  if [[ "$alias_state" == "Y" ]]; then
    echo "STATUS: Aliasing set ON"
  else
    echo "STATUS: Aliasing set OFF"
  fi 
}

# New or reset machine interaction
if [[ $- == *i* ]]; then

  # check for cache folder
  cache="$HOME/.dotfiles/shell/.cache"
  if ! [ -d "$cache" ]; then
    mkdir $cache
  fi

  # read alias cache
  alias_cache="$cache/alias.cache"
  if [ -f "$alias_cache" ]; then
    read -r alias_state < $alias_cache
  else
    alias_state="" 
  fi
  
  # option is never been set
  if [ -z "$alias_state" ]; then
    # greeting
    echo ""
    echo "       /\$\$   /\$\$ /\$\$\$\$\$\$ /\$\$"
    echo "      | \$\$  | \$\$|_  \$\$_/| \$\$"
    echo "      | \$\$  | \$\$  | \$\$  | \$\$"
    echo "      | \$\$\$\$\$\$\$\$  | \$\$  | \$\$"
    echo "      | \$\$__  \$\$  | \$\$  |__/"
    echo "      | \$\$  | \$\$  | \$\$      "
    echo "      | \$\$  | \$\$ /\$\$\$\$\$\$ /\$\$"
    echo "      |__/  |__/|______/|__/"
    echo ""
    echo ""

    # find out whether to alias or not
    echo "You're seeing this message becuase aliasing has not been set for this machine."
    echo "Do you want turn on the suggested aliasing?"
    echo -e "\nNote, this may prompt 'sudo' to install if aliasing requires package"

    # set state 
    read -t 10 -p "Answer within 10 seconds [y/N]: " input
    if [[ -f "$alias_cache" ]]; then
      touch $alias_cache
    fi

    # save and run aliasing
    echo "$alias_cache"
    if [[ "$input" == "y" || "$input" == "Y" ]]; then 
      echo "Y" > $alias_cache

      echo -e "\nSet aliasing ON for this machine."
      echo "Note, you can always change the aliasing option by running 'set_aliasing' or unset_aliasing'."

      echo -n "Aliasing in "
      for second in {3..1}; do
        echo -n "$second.."
        sleep 1
      done
      echo "0" 
      
    # save and do not alias
    else
      echo "N" > $alias_cache

      echo -e "\nSet aliasing OFF for this machine."
      echo "Note, you can always change the aliasing option by running 'set_aliasing' or 'unset_aliasing'."
      
      unset alias_cache
      sleep 3

      return 0
    fi
    
  # option set to do not alias
  elif [[ "$alias_state" == "N" ]]; then
    unset alias_cache
    return 0
  fi

  unset alias_cache

# Non iteractive sessions can not alias
else
    unset alias_cache
  return 0
fi


## Safe alias requirements
# status of any aliases failing
status=0

# cargo
export PATH=$PATH:$HOME/.cargo/bin/

# pacman
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias pacman="pacapt"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pacman="pacaptr"
fi

## Device control
# display & keyboard
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  last=0

  safe_alias dsp="brightnessctl set" || last=1
  if [ "$last" -eq 0 ]; then
    alias kbd="brightnessctl --device='kbd_backlight' set" || status=1

  elif [ "$last" == 1 ]; then
    status=1
  fi
fi

# audio
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias vol="wpctl set-volume -l 1.0 @DEFAULT_SINK@" || status=1
fi

# boot volume
if [[ "$OSTYPE" == "darwin"* ]]; then
  safe_alias boot="sudo bash $HOME/.dotfiles/boot/macOS/osx-boot.sh"   || status=1
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias boot="sudo bash $HOME/.dotfiles/boot/Linux/linux-boot.sh" || status=1
fi


## Commands
# status
safe_alias fetch="fastfetch" || status=1

# files
if [[ "$OSTYPE" == "darwin"* ]]; then
  last=0

  safe_alias ls="eza" || last=1
  if [ "$last" -eq 0 ]; then
    alias ll="eza -lh"
    alias tree="eza --tree"

  elif [ "$last" == 1 ]; then
    status=1
  fi

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  last=0

  safe_alias ls="exa" || last=1
  if [ "$last" -eq 0 ]; then
    alias ll="exa -lh"
    alias tree="exa --tree"

  elif [ "$last" == 1 ]; then
    status=1
  fi
fi

# file content
safe_alias cat="bat --theme=ansi" || status=1

# changing directories
last=0
install_required_package "zoxide" || last=1
if [ "$last" -eq 0 ]; then
  eval "$(zoxide init bash)"

  function cd()
  {
    if [[ "$1" == "..." ]]; then
      z ..
    elif [[ "$1" == "...." ]]; then
      z ../..
    elif [[ "$1" == "....." ]]; then
      z ../../..
    else
      z "$@"
    fi
  }

else
  if [ "$last" == 1 ]; then
    status=1
  fi

  function cd() 
  {
    if [[ "$1" == "..." ]]; then
      builtin cd ../..
    elif [[ "$1" == "...." ]]; then
      builtin cd ../../..
    elif [[ "$1" == "....." ]]; then
      builtin cd ../../..
    else
      builtin cd "$@"
    fi
  }
fi 

# moving files
function cmv() 
{
    local source="$1"
    local target="$2"

    mv "$source" "$target" && cd "$target"
}

# file browsers
safe_alias fb="ranger" || status=1

# file viewer
install_required_package "zathura" || status=1
function fw()
{
  if [ "$#" -eq 0 ]; then
    if [[ $- == *i* ]]; then
      echo "ERROR: no file path provided"
    fi

    return 1
  fi

  zathura "$@" &> /dev/null &
}

# line count
safe_alias lc="xargs wc -l" || status=1

# docker
safe_alias docker="sudo docker" || status=1

# system drivers
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias driver="systemctl" || status=1
  safe_alias dvrctl="systemctl" || status=1
fi

# gui tools
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias open="xdg-open" || status=1
fi

# network
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias wifi="nmcli device wifi" || status=1
fi

# neovim
last=0
safe_alias vim="nvim" || last=1
if [ "$last" -eq 0 ]; then
  alias vimdiff="nvim -d"
  alias nvimdiff="nvim -d"

elif [ "$last" == 1 ]; then
  status=1
fi

# tmux
last=0
safe_alias list-sessions="tmux list-sessions"  || last=1
if [ "$last" -eq 0 ]; then
  alias new-session="tmux new -t"
  alias attach-session="tmux attach -t"
  alias kill-session="tmux kill-session -t"
  alias kill-server="tmux kill-server"

elif [ "$last" == 1 ]; then
  status=1
fi

# lock screen
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias lockscreen="vlock" || status=1
fi

## Languages
# Python
safe_alias python="python3" || status=1
if ! type py &> /dev/null; then
  safe_alias py="python3" || status=1
fi
if type module &> /dev/null; then
  load_package_module "anaconda3" || status=1
fi

# C/C++
install_required_package "cmake" || status=1


# return status of aliases
return $status
