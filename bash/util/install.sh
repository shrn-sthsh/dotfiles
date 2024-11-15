#!/bin/bash

# import print utilities
terminal_source_file="$HOME/.dotfiles/bash/util/terminal.sh"
if [[ ! " ${BASH_SOURCE[@]} " =~ " $terminal_source_file " ]]; then

  if [ -f $terminal_source_file ] ; then
    source $terminal_source_file

  else
    echo "ERROR: VPN commands require 'safe_echo' command from terminal utility"
    return 1
  fi
fi


function install_command_package() 
{
  local cmd=$1
  if [ -z "$cmd" ]; then
      safe_echo -n "ERROR: no command provided"
      return 1
  fi

  # Pacman alias command
  if ! type pacman &> /dev/null || [ "$cmd" == "pacman" ]; then
    if ! type sudo &> /dev/null; then
      safe_echo -n "ERROR: \"sudo\" must be installed before running installation script"
      return 1
    fi
    if ! type cargo &> /dev/null; then
      safe_echo "ERROR: Cargo must be installed before running installation script"
      return 1
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
      cargo install pacapt
      alias pacman='pacapt'
    else
      cargo install pacaptr
      alias pacman='pacaptr'
    fi
  fi

  # Check if user is sudoer
  local sudoer=true
  if ! sudo -v 2> /dev/null; then
    sudoer=false
  fi 
  if [ "$sudoer" = false ]; then
    safe_echo -e "\nERROR: User must be on sudoer list to install packages"
    return 1
  fi

  # Attempt to install the command
  if ! sudo -n -v 2> /dev/null; then
    safe_echo "" && sudo -v && safe_echo ""
  fi
  if ! sudo -n -v 2> /dev/null; then
    safe_echo -e "\nERROR: Need super user priviledges to install source packages"
    return 1
  fi
  sudo pacman -S "$cmd" -- -q -y > /dev/null 2>&1

  # Recheck if the command exists after installation
  if ! type "$cmd" &> /dev/null; then
    safe_echo -e "FAILURE\n--> Unable find or install source package with '$cmd'"
    return 1
  fi

  safe_echo "SUCCESS"
  return 0
}

function install_required_package()
{
  local cmd=$1
  if [ -z "$cmd" ]; then
      safe_echo -n "ERROR: no command provided"
      return 1
  fi

  install_code=0
  if ! type "$cmd" &> /dev/null; then
    safe_echo -n "Command '$cmd' not found; attempting to install source package... "
    install_command_package "$cmd"
    install_code=$?
  fi

  return $install_code
}

function load_package_module() 
{
  local mod=$1
  if [ -z "$mod" ]; then
      safe_echo -n "ERROR: no module provided"
      return 1
  fi

  safe_echo -n "Loading module '$mod'... "

  # check if can be loaded as module
  if type module &> /dev/null; then

    # check if module is already loaded
    if module list 2>&1 | grep "$mod" &> /dev/null; then
      safe_echo -e "\nSUCCESS: module already loaded"
      return 0
    fi

    # load module
    module load "$mod" &> /dev/null

    # check now if module is loaded
    if ! module list 2>&1 | grep "$mod" &> /dev/null; then
      safe_echo -e "\nFAILURE\n--> Unable find or load package module '$mod'"
      return 1
    fi

    safe_echo "SUCCESS"
    return 0

  else
    safe_echo -e "\nERROR: system does not support modules"
    return 1
  fi
}

function safe_alias() 
{
  # Extract the alias name and command
  local alias_name="${1%%=*}"
  local full_command="${1#*=}"

  # Extract environment variables
  local variables=""
  local command=""
  while [[ "$full_command" =~ ^[A-Za-z_]+[A-Za-z0-9_]*= ]]; do
    variable="${full_command%% *}"
    variables="$variables $variable"
    full_command="${full_command#* }"
  done
  variables="$(safe_echo -e "${variables}" | sed -e 's/^[[:space:]]*//')"

  # Remainder is command
  command="$(safe_echo -e "${full_command}" | sed -e 's/^[[:space:]]*//')"

  # Install source package of commands if it doesn't exist
  local base=$(safe_echo "$command" | awk '{print $1}')
  install_required_package "$base" 
  
  if [ "$?" -ne 0 ]; then
    safe_echo -e "NOTE: Please install package for $base manually and rerun script for aliasing\n"
    return 1
  fi

  # Create the alias
  if [ -z "$variables" ]; then
    alias "$alias_name"="$command"
  else
    alias "$alias_name"="$variables $command"
  fi

  return 0
}
