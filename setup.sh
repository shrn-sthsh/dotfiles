#!/bin/bash


# top level directories and paths
SOURCE_DIR=$(pwd)
TARGET_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.backup"
GIT_IGNORE="$TARGET_DIR/packages/.gitignore"


# Ensure correct placement of dotfiles
if [ "$SOURCE_DIR" != "$TARGET_DIR" ]; then
  if [[ $- != *i* ]]; then
    echo "NOTE:   Moving repository to $HOME"
  fi

  mv "$SOURCE_DIR" "$TARGET_DIR"
fi


# Backup of current configurations
if ! [ -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
fi


# Copy non-overidden configurations
if [ -d "$HOME/.config" ]; then
  if [[ $- != *i* ]]; then
    echo "STATUS: Copying over existing configurations not set by dotfiles"
  fi

  # move over non-overrided files
  if ! [ -d "$TARGET_DIR/logs" ]; then
    mkdir -p "$TARGET_DIR/logs"
  fi
  BACKUP_LOG="$TARGET_DIR/logs/setup_rsync.log"
  rsync -a --ignore-existing --log-file="$BACKUP_LOG" "$HOME/.config/" "$TARGET_DIR/packages/"
  if [[ $- != *i* ]]; then
    echo "NOTE:   Saving synchronization log as $BACKUP_LOG"
  fi

  # set up git ignore file
  if ! [ -f "$GIT_IGNORE" ]; then
    if ! [ -d $(dirname "$GIT_IGNORE") ]; then
      mkdir -p $(dirname "$GIT_IGNORE")
    fi

    touch "$GIT_IGNORE"
  fi
  if [ -s "$GIT_IGNORE" ]; then
    : > "$GIT_IGNORE"
  fi

  # update .gitignore with copied packages
  if [[ $- != *i* ]]; then
    echo -e "STATUS: Updating git ignore with non-overidden packages\n"
  fi 
  echo "# Ignore configurations not provieded by dotfiles \$HOME/.config" >> "$GIT_IGNORE"
  grep '^>f' "$BACKUP_LOG" | awk '{print $2}' | sed 's/\//g' >> "$GIT_IGNORE"
fi


# Backup directories and replace with symbolic links
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
    mv "$target" "$BACKUP_DIR"
  else
    unlink "$target"
  fi

  # link non-link source as target 
  if [[ $- != *i* ]]; then
    echo "STATUS: Linking $source as $target"
  fi 
  ln -s "$source" "$target"
}

save_and_link "$TARGET_DIR/shell/run.sh"   "$HOME/.bashrc"
save_and_link "$TARGET_DIR/packages"       "$HOME/.config"
save_and_link "$HOME/.config/mozilla"      "$HOME/.mozilla"
save_and_link "$HOME/.config/tmux"         "$HOME/.tmux"
save_and_link "$HOME/.config/tmux/config"  "$HOME/.tmux.conf"
save_and_link "$HOME/.config/conda/config" "$HOME/.condarc"


# Reload config
source "$HOME/.bashrc"
