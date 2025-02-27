#!/bin/sh


# import print utilities
terminal_source_file="$HOME/.dotfiles/shell/util/terminal.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $terminal_source_file " ]];
then

  if [ -f $terminal_source_file ] ;
  then
    source $terminal_source_file

  else
    echo "ERROR: VPN commands require 'safe_echo' command from terminal utility"
    return 1
  fi
fi


## package cache
# cache
package_cache="$HOME/.dotfiles/shell/.cache/package.cache"

# reset cache
function reset_package_cache()
{
  if [ -f "$package_cache" ];
  then
    : > "$package_cache"
    return 0
  fi

  safe_echo "ERROR: Can not find package cache"
  return 1
}


## Package and Module commands
# install package which provides a command
function install_command_package() 
{
  if [[ "$1" == "-n" ]];
  then
    local cmd=$2
    local top=false

  else
    local cmd=$1
    if [[ "$2" == "-n" ]];
    then local top=false 
    else local top=true; fi
  fi

  if [ -z "$cmd" ];
  then
      safe_echo -n "ERROR: No command provided"
      if [ "$top" = true ];
      then safe_new_line; fi
      return 1
  fi

  # pacman alias command
  if ! type pacman &> /dev/null || [ "$cmd" == "pacman" ];
  then
    if ! type sudo &> /dev/null;
    then
      safe_echo -n "ERROR: \"sudo\" must be installed before running installation script"
      if [ "$top" = true ];
      then safe_new_line; fi

      return 1
    fi
    if ! type cargo &> /dev/null;
    then
      safe_echo "ERROR: Cargo must be installed before running installation script"
      if [ "$top" = true ];
      then safe_new_line; fi

      return 1
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]];
    then
      cargo install pacapt
      alias pacman='pacapt'
    else
      cargo install pacaptr
      alias pacman='pacaptr'
    fi
  fi

  # attempt to install the command 
  if ! sudo -v 2> /dev/null;
  then
    safe_echo -e "ERROR: Must be a sudoer to install source packages"
    safe_echo -e "NOTE: Adding binaries to ~/.bin is an alternative if not a sudoer"

    if [ "$top" = true ];
    then safe_new_line; fi
    return 1
  fi
  sudo pacman -S "$cmd" -- -q -y > /dev/null 2>&1

  # recheck if the command exists after installation
  if ! type "$cmd" &> /dev/null;
  then
    safe_echo -e "FAILURE: Unable find or install source package with '$cmd'"
    safe_echo -e "NOTE: Try updating package manager and if that fails consider a package binary for ~/.bin"

    if [ "$top" = true ];
    then safe_new_line; fi
    return 1
  fi

  safe_echo "SUCCESS: Source package installed"
  if [ "$top" = true ];
  then safe_new_line; fi
  return 0
}

# install required package for a command
function install_required_package()
{
  if [[ "$1" == "-n" ]];
  then
    local cmd="$2"
    local top=false

  else
    local cmd="$1"
    if [[ "$2" == "-n" ]];
    then 
      local top=false
    else 
      local top=true; 
    fi
  fi

  if [ -z "$cmd" ];
  then
      safe_echo -n "ERROR: No command provided"
      if [ "$top" = true ];
      then safe_new_line; fi
      return 1
  fi

  # attempt to install required package
  install_code=0
  if ! type "$cmd" &> /dev/null;
  then

    # exit if known package (can not be installed)
    if [ -f "$package_cache" ];
    then
      if grep -Fxq "$cmd" "$package_cache";
      then
        return 2
      fi 
    
    # make a package cache if not available
    else
      touch "$package_cache" || echo "ERROR: Unable to find or create package cache" && return 1
    fi

    # try installing base package
    safe_echo "Command '$cmd' not found; attempting to install source package... "
    if [ "$top" = true ];
    then
      install_command_package "$cmd"
      install_code=$?
    else
      install_command_package -n "$cmd"
      install_code=$?
    fi

    # save to failed packages if installation fails
    if [ "$install_code" -eq 1 ];
    then
      echo "$cmd" >> "$package_cache"
      sort "$package_cache" -o "$package_cache"
    fi
  fi

  return $install_code
}

# load a module which provides a package
function load_package_module() 
{
  local mod=$1
  if [ -z "$mod" ];
  then
      safe_echo -n "ERROR: No module provided"
      return 1
  fi

  safe_echo "Loading module '$mod'... "

  # check if can be loaded as module
  if type module &> /dev/null;
  then

    # check if module is already loaded
    if module list 2>&1 | grep "$mod" &> /dev/null;
    then
      safe_echo -e "SUCCESS: Module was already loaded"
      return 0
    fi

    # load module
    module load "$mod" &> /dev/null

    # check now if module is loaded
    if ! module list 2>&1 | grep "$mod" &> /dev/null;
    then
      safe_echo -e "FAILURE: Unable find or load package module '$mod'"
      return 1
    fi

    safe_echo "SUCCESS: Module loaded"
    return 0

  else
    safe_echo -e "ERROR: System does not support modules"
    return 1
  fi
}

# alias a command and install required command if necessary
function safe_alias() 
{
  # extract the alias name and command
  local alias_name="${1%%=*}"
  local full_cmd="${1#*=}"

  # extract environment variables
  local vars=""
  while [[ "$full_cmd" =~ ^[A-Za-z_]+[A-Za-z0-9_]*= ]]; 
  do
    var="${full_cmd%% *}"
    vars="$vars $var"
    full_cmd="${full_cmd#* }"
  done
  vars="$(safe_echo -e "${variables}" | sed -e 's/^[[:space:]]*//')"

  # remainder is command
  local cmd="$(safe_echo -e "${full_cmd}" | sed -e 's/^[[:space:]]*//')"

  # extract base command ignoring sudo
  if [[ "$cmd" =~ ^sudo[[:space:]]+ ]];
  then
    local base=$(safe_echo "$cmd" | awk '{for (i=2; i<=NF; i++) {print $i; exit}}')
  else
    local base=$(safe_echo "$cmd" | awk '{print $1}')
  fi

  # install source package of commands if it doesn't exist
  install_required_package -n "$base" 
  status="$?"
  
  if [ "$status" -eq 1 ];
  then
    safe_echo -e "NOTE: Please install package for $base manually and rerun script for aliasing\n"
    return 1
  elif [ "$status" -eq 2 ];
  then
    safe_echo -e "ERROR: Please install package for $base manually and rerun script for aliasing"
    return 2
  fi

  # create the alias
  if [ -z "$vars" ];
  then 
    alias "$alias_name"="$cmd"
  else 
    alias "$alias_name"="$vars $cmd"; 
  fi

  return 0
}

# safe alias command but ignore package cache
function force_alias()
{
  # extract the alias name and command
  local alias_name="${1%%=*}"
  local full_cmd="${1#*=}" 

  # extract environment variables
  local vars=""
  while [[ "$full_cmd" =~ ^[A-Za-z_]+[A-Za-z0-9_]*= ]]; 
  do
    var="${full_cmd%% *}"
    vars="$vars $var"
    full_cmd="${full_cmd#* }"
  done
  vars="$(safe_echo -e "${variables}" | sed -e 's/^[[:space:]]*//')"

  # remainder is command
  local cmd="$(safe_echo -e "${full_cmd}" | sed -e 's/^[[:space:]]*//')"

  # reset cache for this command
  if [ -f "$package_cache" ];
  then
    sed -i "/^$cmd$/d" "$package_cache"
  fi

  # extract base command ignoring sudo
  if [[ "$cmd" =~ ^sudo[[:space:]]+ ]];
  then
    local base=$(safe_echo "$cmd" | awk '{for (i=2; i<=NF; i++) {print $i; exit}}')
  else
    local base=$(safe_echo "$cmd" | awk '{print $1}')
  fi

  # install source package of commands if it doesn't exist
  install_required_package -n "$base" 
  
  if [ "$?" -eq 1 ];
  then
    safe_echo -e "NOTE: Please install package for $base manually and rerun script for aliasing\n"
    return 1
  elif [ "$?" -eq 2 ];
  then
    safe_echo -e "ERROR: Please install package for $base manually and rerun script for aliasing"
    return 2
  fi

  # create the alias
  if [ -z "$vars" ];
  then 
    alias "$alias_name"="$cmd"
  else 
    alias "$alias_name"="$vars $cmd"; 
  fi

  return 0
}
