#!/bin/sh


## Alias calls
# echo
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias echo="echo -e"
fi

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
  echo "N" > "$setup_cache"
elif ! [ -s "$setup_cache" ]; then
  echo "N" > "$setup_cache"
fi

# exit if setup script has already been run
setup_state="$(sed -n  '1p' "$setup_cache")"
if [[ "$setup_state" == "Y" ]]; then
  if [[ $- != *i* ]]; then
    echo "NOTE:   Initial setup has already been done;"
    echo "\trerun will check for new packages to backup and link\n"
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
  echo "STAGE:  Ensuring dotfiles is dot folder at user root"
fi 

# check if already correct
if [ "$CURRENT_DIR" != "$PROJECT_DIR" ]; then
  if [[ $- != *i* ]]; then
    echo "STATUS: dotfiles moved into $HOME as .dotfiles\n"
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

  # get index into file if non-empty
  header="# Ignore configurations not provieded by dotfiles \$HOME/.config"
  if grep -qF "$header" "$IGNORE_FILE"; then
    cursor=$(grep -nF "$header" "$IGNORE_FILE" | cut -d: -f1)
  else
    echo "$header" >> "$IGNORE_FILE"
    cursor=2 # files are one-indexed
  fi

  # backup all configurations files
  if [[ $- != *i* ]]; then
    echo "STAGE:  Creating new .config with dotfiles custom configurations"
    echo "\tand linking all existing configurations not set by dotfiles"

    echo "NOTE:   All prior configurations will be saved in $BACKUP_DIR"
  fi

  backed=0
  linked=0
  for node in "$CONFIG_DIR"/* "$CONFIG_DIR"/.*; do
    package=$(basename "$node")
    target="$PACKAGE_DIR/$package"
    backup="$BACKUP_DIR/config/$package"

    # skip already linked or backed up package directories
    if [ -L "$node" ] || [ -d "$backup" ]; then
      continue

    # skip the package if it's the git ignore file
    elif [[ "$package" == "$(basename "$IGNORE_FILE")" ]]; then
      continue
      
    # skip if the package is tracked by git (not a new package)
    elif git ls-files --error-unmatch "$target" &> /dev/null; then
      continue
    fi

    # backup package configuration to .backup
    mv "$node" "$backup"
    backed=$((backed+1))

    # link non-overidden packages and add to git ignore
    if ! [ -e "$target" ]; then
      ln -s "$backup" "$target"
      linked=$((linked+1))

      if ! grep -qF "$package" "$IGNORE_FILE"; then
        sed -i '' "${cursor}a /$package" "$IGNORE_FILE"
        cursor=$((cursor+1))
      fi 
    fi
  done
  if [[ $- != *i* ]]; then
    echo "STATUS: Backed up $backed configurations out of which $linked were originals\n"
  fi 

  # update packages' metadata in cache
  linked_state="$(sed -n '2p' "$setup_cache")"
  backed_state="$(sed -n '3p' "$setup_cache")"
  if [ -z "$linked_state" ] || [ -z "$backed_state" ]; then
    echo "$linked" >> "$setup_cache"
    echo "$backed" >> "$setup_cache"

  else
    if [ "$linked" -gt "$linked_state" ]; then
      sed -i '' "2s/.*/$linked/" "$setup_cache"
    fi
    if [ "$backed" -gt "$backed_state" ]; then
      sed -i '' "3s/.*/$backed/" "$setup_cache"
    fi
  fi

  # clean up remaining gitignore
  if [ -e "$CONFIG_DIR/.gitignore" ]; then
    mv "$CONFIG_DIR/.gitignore" "$BACKUP_DIR/config/"
  fi
  
  # replace prior .config with packages
  if [ -z "$(ls -A "$CONFIG_DIR")" ]; then
    rmdir "$CONFIG_DIR"

  # move to a reaminder directory if .config is not empty
  elif ! [ -L "$CONFIG_DIR" ]; then
    REMAIN_DIR="$BACKUP_DIR/residual"
    if ! [ -d "$REMAIN_DIR" ]; then
      mkdir -p "$REMAIN_DIR"
    fi

    mv "$CONFIG_DIR"/* "$REMAIN_DIR"
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
  local targets=${@:2}

  # validate arguments
  if ! [ -e "$source" ]; then
    return 1
  fi

  # save non-link items and unlink links
  for target in $targets; do
    if [ -e "$target" ]; then
      if ! [ -L "$target" ]; then
        mv "$target" "$BACKUP_DIR/$(echo "$(basename "$target")" | sed 's/^\.//')"
      else
        unlink "$target"
      fi
    fi
  done

  # link non-link source as target 
  if [[ $- != *i* ]]; then
    if [ "${#targets[@]}" -gt 1 ]; then
      echo "STATUS: Linking $source as ["$(${targets[@]} | tr ' ' ,)"]"
    else
      echo "STATUS: Linking $source as $targets"
    fi
  fi 
  for target in $targets; do
    ln -s "$source" "$target"
  done
}

# backup and link special targets
if [[ $- != *i* ]]; then
  echo "STAGE:  Saving and linking special files and directories"
fi
save_and_link "$PROJECT_DIR/shell/run.sh"  "$HOME/.bashrc"    "$HOME/.zshrc"
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
if [[ "$0" == *zsh* ]]; then
  source "$HOME/.zshrc"
elif [[ "$0" == *bash* ]]; then
  source "$HOME/.bashrc"
fi

## Unalias calls
# echo
unalias echo
