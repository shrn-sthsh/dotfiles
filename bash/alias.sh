#!/bin/bash

# import installer
if [ -f ~/.dotfiles/bash/func/install.sh ]; then
  source ~/.dotfiles/bash/func/install.sh
else
  echo "ERROR: Unable to check if command source packages exist before aliasing"
  return 1
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
  safe_alias dsp "brightnessctl set"
fi

# audio
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias vol "wpctl set-volume -l 1.0 @DEFAULT_SINK@"
fi

# keyboard
if [[ "$OSTYPE" == "linux-gnu" ]]; then 
  safe_alias kbd "brightnessctl --device='kbd_backlight' set"
fi

# boot volume
if [[ "$OSTYPE" == "darwin"* ]]; then
  safe_alias boot "sudo bash $HOME/.dotfiles/boot/osx-boot.sh"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias boot "sudo bash $HOME/.dotfiles/boot/linux-boot.sh"
fi

## Commands
# status
safe_alias fetch "fastfetch"

# files
if [[ "$OSTYPE" == "darwin"* ]]; then
  safe_alias ls "eza"
  safe_alias ll "eza -lh"
  safe_alias tree "eza --tree"
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias ls "exa"
  safe_alias ll "exa -lh"
  safe_alias tree "exa --tree"
fi

# file content
safe_alias cat "bat --theme=ansi"

# changing directories
eval "$(zoxide init bash)"
safe_alias cd z

# file browsers
safe_alias fb "ranger"

# line count
safe_alias lc "xargs wc -l"

# docker
safe_alias docker "sudo docker"

# system drivers
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias driver "systemctl"
  safe_alias dvrctl "systemctl"
fi

# window managers
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  export PATH="$PATH:$HOME/System/sway"
  safe_alias startw "dbus-run-session gnome-session" "XDG_SESSION_TYPE=wayland"
fi

# gui tools
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias open "xdg-open"
fi

# network
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias wifi "nmcli device wifi"
fi

# neovim
safe_alias vim "nvim"
safe_alias vimdiff "nvim -d"
safe_alias nvimdiff "nvim -d"

# tmux
safe_alias list-sessions "tmux list-sessions"
safe_alias new-session "tmux new -t"
safe_alias attach-session "tmux attach -t"
safe_alias kill-session "tmux kill-session -t"
safe_alias kill-server "tmux kill-server"

# lock screen
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  safe_alias lockscreen "vlock"
fi
