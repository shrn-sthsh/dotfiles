#!/bin/bash


## Setup state check
if [[ $- != *i* ]]; then
  echo "STAGE:  Checking cache for setup status"
fi 

# check for cache folder
cache="$HOME/.dotfiles/shell/.cache"
if ! [ -d "$cache" ]; then
  mkdir $cache
fi 

# check for alias cache
setup_cache="$cache/setup.cache"
if ! [ -f "$setup_cache" ]; then
  touch "$setup_cache"
fi

# exit if setup script has already been run
read -r setup_state < $setup_cache
if [[ "$setup_state" == "Y" ]]; then
  if [[ $- != *i* ]]; then
    echo -e "NOTE:   Initial setup has already been done;\n\trerun will check for new packages to backup and link\n"
  fi
fi 


## Global variales
# top level directories and paths
CURRENT_DIR=$(pwd)
PROJECT_DIR="$HOME/.dotfiles"
PACKAGE_DIR="$PROJECT_DIR/packages"
IGNORE_FILE="$PACKAGE_DIR/.gitignore"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.backup"


## Ensure dotfiles' root at home
if [[ $- != *i* ]]; then
  echo -e "STAGE:  Ensuring dotfiles is dot folder at user root"
fi 

# check if already correct
if [ "$CURRENT_DIR" != "$PROJECT_DIR" ]; then
  if [[ $- != *i* ]]; then
    echo -e "STATUS: dotfiles moved into $HOME as .dotfiles\n"
  fi

  mv "$CURRENT_DIR" "$PROJECT_DIR"

elif [[ $- != *i* ]]; then
  echo ""
fi


## Backup all configurations and apply new ones
# make backup dotfile directory at root
if ! [ -d "$BACKUP_DIR" ] || ! [ -d "$BACKUP_DIR/config" ]; then
  mkdir -p "$BACKUP_DIR/config"
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
    echo -e "STAGE:  Creating new .config with dotfiles custom configurations\n\tand linking all existing configurations not set by dotfiles"
    echo "NOTE:   All prior configurations will be saved in $BACKUP_DIR"
  fi

  backed=0
  linked=0
  for node in "$CONFIG_DIR"/* "$CONFIG_DIR"/.*; do
    package=$(basename "$node")
    backup="$BACKUP_DIR/config/$package"

    # skip already symlinked package directories and those already backed up
    if [ -L "$node" ] || [ -d "$backup" ]; then
      continue
    fi

    # backup package configuration to .backup
    mv "$node" "$backup"
    backed=$((backed+1))

    # link non-overidden packages and add to git ignore
    target="$PACKAGE_DIR/$package"
    if ! [ -e "$target" ]; then
      ln -s "$backup" "$target"
      echo "/$package" >> "$IGNORE_FILE"
      
      linked=$((linked+1))
    fi
  done

  if [[ $- != *i* ]]; then
    echo -e "STATUS: Backed up $backed configurations out of which $linked were originals\n"
  fi 
fi

# replace prior .config with packages
if [ -e "$CONFIG_DIR" ]; then
  if [ -z "$(ls -A "$CONFIG_DIR")" ]; then
    rmdir "$CONFIG_DIR"

  # move to a reaminder directory if .config is not empty
  elif ! [ -L "$CONFIG_DIR" ]; then
    REMAIN_DIR="$BACKUP_DIR/residual"
    if ! [ -d "$REMAIN_DIR" ]; then
      mkdir -p "$REMAIN_DIR"
    fi

    mv "$CONFIG_DIR" "$REMAIN_DIR"
  fi
fi
if ! [ -e "$CONFIG_DIR" ]; then
  ln -s "$PACKAGE_DIR" "$CONFIG_DIR"
fi


## Backup special files & directories and replace with symbolic links
# routine to backup target and replace path with source
function save_and_link() 
{
  local source=$1
  local target=$2

  # validate arguments
  if ! [ -e "$source" ]; then
    return 1
  fi

  # save non-link items and unlink links
  if [ -e "$target" ]; then
    if ! [ -L "$target" ]; then
      mv "$target" "$BACKUP_DIR/$(echo "$target" | sed 's/^\.//')"
    else
      unlink "$target"
    fi
  fi

  # link non-link source as target 
  if [[ $- != *i* ]]; then
    echo "STATUS: Linking $source as $target"
  fi 
  ln -s "$source" "$target"
}

# backup and link special targets
if [[ $- != *i* ]]; then
  echo "STAGE:  Saving and linking special files and directories"
fi
save_and_link "$PROJECT_DIR/shell/run.sh"  "$HOME/.bashrc"
save_and_link "$HOME/.config/mozilla"      "$HOME/.mozilla"
save_and_link "$HOME/.config/tmux"         "$HOME/.tmux"
save_and_link "$HOME/.config/tmux/config"  "$HOME/.tmux.conf"
save_and_link "$HOME/.config/conda/config" "$HOME/.condarc"


## Cleanly exit
# set cache
if [[ "$setup_state" == "N" ]]; then
  echo "Y" > $setup_cache
fi

# reload config
source "$HOME/.bashrc"
