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
  if [[ "$1" == "-n" ]]; then
    local cmd=$2
    local sub=true

  else
    local cmd=$1
    if [[ "$2" == "-n" ]]; then local sub=true 
    else local sub=false; fi
  fi

  if [ -z "$cmd" ]; then
      safe_echo -n "ERROR: No command provided"
      if [ "$sub" = true ]; then safe_echo ""; fi
      return 1
  fi

  # Pacman alias command
  if ! type pacman &> /dev/null || [ "$cmd" == "pacman" ]; then
    if ! type sudo &> /dev/null; then
      safe_echo -n "ERROR: \"sudo\" must be installed before running installation script"
      if [ "$sub" = true ]; then safe_echo ""; fi
      return 1
    fi
    if ! type cargo &> /dev/null; then
      safe_echo "ERROR: Cargo must be installed before running installation script"
      if [ "$sub" = true ]; then safe_echo ""; fi
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

  # Attempt to install the command 
  if ! sudo -v 2> /dev/null; then
    safe_echo -e "\nERROR: Must be a sudoer to install source packages"
    safe_echo -e "NOTE: Adding binaries to ~/.bin is an alternative if not a sudoer"

    if [ "$sub" = true ]; then safe_echo ""; fi
    return 1
  fi
  sudo pacman -S "$cmd" -- -q -y > /dev/null 2>&1

  # Recheck if the command exists after installation
  if ! type "$cmd" &> /dev/null; then
    safe_echo -e "FAILURE: Unable find or install source package with '$cmd'"
    safe_echo -e "NOTE: Try updating package manager and if that fails consider a package binary for ~/.bin"

    if [ "$sub" = true ]; then safe_echo ""; fi
    return 1
  fi

  safe_echo "SUCCESS"
  if [ "$sub" = true ]; then safe_echo ""; fi
  return 0
}

function install_required_package()
{
  if [[ "$1" == "-n" ]]; then
    local cmd=$2
    local sub=true

  else
    local cmd=$1
    if [[ "$2" == "-n" ]]; then local sub=true
    else local sub=false; fi
  fi

  if [ -z "$cmd" ]; then
      safe_echo -n "ERROR: No command provided"
      if [ "$sub" = true ]; then safe_echo ""; fi
      return 1
  fi

  install_code=0
  if ! type "$cmd" &> /dev/null; then
    safe_echo -n "Command '$cmd' not found; attempting to install source package... "

    if [ "$sub" = true ]; then
      install_command_package -n "$cmd"
      install_code=$?

    else
      install_command_package "$cmd"
      install_code=$?
    fi
  fi

  return $install_code
}

function load_package_module() 
{
  local mod=$1
  if [ -z "$mod" ]; then
      safe_echo -n "ERROR: No module provided"
      return 1
  fi

  safe_echo -n "Loading module '$mod'... "

  # check if can be loaded as module
  if type module &> /dev/null; then

    # check if module is already loaded
    if module list 2>&1 | grep "$mod" &> /dev/null; then
      safe_echo -e "SUCCESS\nNOTE: Module was already loaded"
      return 0
    fi

    # load module
    module load "$mod" &> /dev/null

    # check now if module is loaded
    if ! module list 2>&1 | grep "$mod" &> /dev/null; then
      safe_echo -e "\nFAILURE: Unable find or load package module '$mod'"
      return 1
    fi

    safe_echo "SUCCESS"
    return 0

  else
    safe_echo -e "\nERROR: System does not support modules"
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
