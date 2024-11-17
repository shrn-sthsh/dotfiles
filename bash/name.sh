#!/bin/bash

# import installer
installer_source_file="$HOME/.dotfiles/bash/util/install.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $installer_source_file " ]]; then

  if [ -f "$installer_source_file" ]; then
    source "$installer_source_file"

  else
    echo "ERROR: Unable to check if command source packages exist before aliasing"
    return 1
  fi
fi

# import print utilities
terminal_source_file="$HOME/.dotfiles/bash/util/terminal.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $terminal_source_file " ]]; then

  if [ -f $terminal_source_file ]; then
    source $terminal_source_file

  else
    echo "ERROR: VPN commands require 'safe_echo' command from terminal utility"
    return 1
  fi
fi

## Safe alias requirements
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

  safe_alias dsp="brightnessctl set" || last=0
  if [ "$last" -eq 0 ]; then
    alias kbd="brightnessctl --device='kbd_backlight' set" || status=1

  else
    status=1
  fi
fi

# audio
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias vol="wpctl set-volume -l 1.0 @DEFAULT_SINK@" || status=1
fi

# boot volume
if [[ "$OSTYPE" == "darwin"* ]]; then
  safe_alias boot="sudo bash $HOME/.dotfiles/boot/osx-boot.sh"   || status=1
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias boot="sudo bash $HOME/.dotfiles/boot/linux-boot.sh" || status=1
fi

# status of any aliases failing
status=0

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

  else
    status=1
  fi

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  last=0

  safe_alias ls="exa" || last=1
  if [ "$?" -eq 0 ]; then
    alias ll="exa -lh"
    alias tree="exa --tree"

  else
    status=1
  fi
fi

# file content
safe_alias cat="bat --theme=ansi" || status=1

# changing directories
last=0
install_required_package -n "zoxide" || last=1
if [ "$last" -eq 0 ]; then
  eval "$(zoxide init bash)"
  alias cd="z"

else
  status=1
fi

# file browsers
safe_alias fb="ranger" || status=1

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

else
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

else
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
install_required_package -n "cmake" || status=1


# return status of aliases
return $status
