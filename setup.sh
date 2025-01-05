#!/bin/bash


# top level directories and paths
CURRENT_DIR=$(pwd)
PROJECT_DIR="$HOME/.dotfiles"
IGNORE_FILE="$PROJECT_DIR/packages/.gitignore"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.backup"


## Ensure dotfiles' root at home
# check if already correct
if [ "$CURRENT_DIR" != "$PROJECT_DIR" ]; then
  if [[ $- != *i* ]]; then
    echo "NOTE:   Moving repository to $HOME"
  fi

  mv "$CURRENT_DIR" "$PROJECT_DIR"
fi


## Backup all configurations and apply new ones
# make backup dotfile directory at root
if ! [ -d "$BACKUP_DIR" ] || ! [ -d "$BACKUP_DIR/.config" ]; then
  mkdir -p "$BACKUP_DIR/.config"
fi

# backup configurations and link non-overridden ones to new config directory
if [ -d "$CONFIG_DIR" ]; then

  # set up git ignore file
  if ! [ -f "$IGNORE_FILE" ]; then
    if ! [ -d $(dirname "$IGNORE_FILE") ]; then
      mkdir -p $(dirname "$IGNORE_FILE")
    fi

    touch "$IGNORE_FILE"
  fi
  if [ -s "$IGNORE_FILE" ]; then
    : > "$IGNORE_FILE"
  fi
  echo "# Ignore configurations not provieded by dotfiles \$HOME/.config" >> "$IGNORE_FILE"

  # backup all configurations files
  if [[ $- != *i* ]]; then
    echo "STATUS: Copying over existing configurations not set by dotfiles"
  fi

  for directory in "$CONFIG_DIR"/* "$CONFIG_DIR"/.*; do
    if ! [ -e "$directory" ]; then
      continue
    fi

    package=$(basename "$directory")
    backup="$BACKUP_DIR/config/$package"
    target="$PROJECT_DIR/packages/$package"

    # backup package configuration to .backup
    mv "$directory" "$backup"

    # link non-overidden packages and add to git ignore
    if ! [ -e "$target" ]; then
      ln -s "$backup" "$target"
      echo "/$package" >> "$GITIGNORE_FILE"
    fi
  done
fi

# clean up .config
if [ -e "$CONFIG_DIR" ]; then
  if [ -z "$(ls -A "$CONFIG_DIR")" ]; then
    rmdir "$CONFIG_DIR"

  # move to a reaminder directory if .config is not empty
  else 
    REMAIN_DIR="$BACKUP_DIR/residual"
    if ! [ -d "$REMAIN_DIR" ]; then
      mkdir -r "$REMAIN_DIR"
    fi

    mv "$CONFIG_DIR" "$REMAIN_DIR"
  fi
fi


## Backup special files & directories and replace with symbolic links
# backup target and repalce path with source
function save_and_link() 
{
  local source=$1
  local target=$2

  # validate arguments
  if ! [ -e "$source" ] || ! [ -e "$target" ]; then
    return 1
  fi

  # save non-link items and unlink links
  if ! [ -L "$target" ]; then
    mv "$target" "$BACKUP_DIR/$(echo "$target" | sed 's/^\.//')"
  else
    unlink "$target"
  fi

  # link non-link source as target 
  if [[ $- != *i* ]]; then
    echo "STATUS: Linking $source as $target"
  fi 
  ln -s "$source" "$target"
}

save_and_link "$PROJECT_DIR/shell/run.sh"  "$HOME/.bashrc"
save_and_link "$HOME/.config/mozilla"      "$HOME/.mozilla"
save_and_link "$HOME/.config/tmux"         "$HOME/.tmux"
save_and_link "$HOME/.config/tmux/config"  "$HOME/.tmux.conf"
save_and_link "$HOME/.config/conda/config" "$HOME/.condarc"


# Reload config
source "$HOME/.bashrc"
