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
# display
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias dsp="brightnessctl set"
fi

# audio
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias vol="wpctl set-volume -l 1.0 @DEFAULT_SINK@"
fi

# keyboard
if [[ "$OSTYPE" == "linux-gnu" ]]; then 
  safe_alias kbd="brightnessctl --device='kbd_backlight' set"
fi

# boot volume
if [[ "$OSTYPE" == "darwin"* ]]; then
  safe_alias boot="sudo bash $HOME/.dotfiles/boot/osx-boot.sh"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias boot="sudo bash $HOME/.dotfiles/boot/linux-boot.sh"
fi

## Commands
# status
safe_alias fetch="fastfetch"

# files
if [[ "$OSTYPE" == "darwin"* ]]; then
  safe_alias ls="eza"
  safe_alias ll="eza -lh"
  safe_alias tree="eza --tree"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias ls="exa"
  safe_alias ll="exa -lh"
  safe_alias tree="exa --tree"
fi

# file content
safe_alias cat="bat --theme=ansi"

# changing directories
eval "$(zoxide init bash)"
safe_alias cd="z"

# file browsers
safe_alias fb="ranger"

# line count
safe_alias lc="xargs wc -l"

# docker
safe_alias docker="sudo docker"

# system drivers
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias driver="systemctl"
  safe_alias dvrctl="systemctl"
fi

# gui tools
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias open="xdg-open"
fi

# network
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias wifi="nmcli device wifi"
fi

# neovim
safe_alias vim="nvim"
safe_alias vimdiff="nvim -d"
safe_alias nvimdiff="nvim -d"

# tmux
safe_alias list-sessions="tmux list-sessions"
safe_alias new-session="tmux new -t"
safe_alias attach-session="tmux attach -t"
safe_alias kill-session="tmux kill-session -t"
safe_alias kill-server="tmux kill-server"

# lock screen
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias lockscreen="vlock"
fi

## Languages
# Python
safe_alias python="python3"
if ! type py &> /dev/null; then
  safe_alias py="python3"
fi
if type module &> /dev/null; then
  load_package_module "anaconda3"
fi

# C/C++
install_required_package "cmake"
