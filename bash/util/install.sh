#!/bin/bash

function install_command_package() 
{
  local cmd=$1

  # Pacman alias command
  if ! type pacman &>/dev/null || [ "$cmd" == "pacman" ]; then
    if ! type sudo &>/dev/null; then
      echo -n "ERROR: \"sudo\" must be installed before running installation script"
      return 1
    fi
    if ! type cargo &>/dev/null; then
      echo "ERROR: Cargo must be installed before running installation script"
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
  if ! sudo -v 2>/dev/null; then
    sudoer=false
  fi 
  if [ "$sudoer" = false ]; then
    echo -e "\nERROR: User must be on sudoer list to install packages"
    return 1
  fi

  # Attempt to install the command
  if ! sudo -n -v 2>/dev/null; then
    echo "" && sudo -v && echo ""
  fi
  if ! sudo -n -v 2>/dev/null; then
    echo -e "\nERROR: Need super user priviledges to install source packages"
    return 1
  fi
  sudo pacman -S "$cmd" -- -q -y > /dev/null 2>&1

  # Recheck if the command exists after installation
  if ! type "$cmd" &>/dev/null; then
    echo -e "FAILURE\n--> Unable find or install source package with '$cmd'"
    return 1
  fi

  echo "SUCCESS"
  return 0
}

function install_required_package()
{
  local cmd=$1

  install_code=0
  if ! type "$cmd" &>/dev/null; then
    echo -n "Command '$cmd' not found; attempting to install source package... "
    install_command_package $cmd
    install_code=$?
  fi

  return $install_code
}

function safe_alias() 
{
  local name="$1"
  local cmd="$2"
  local env="$3"

  # Install source package of commands if it doesn't exist
  local base=$(echo "$cmd" | awk '{print $1}')
  install_required_package $base 
  
  if [ "$?" -eq 1 ]; then
    echo "NOTE: Please install package for $base manually and rerun script for aliasing"
    return 1
  fi
  
  # Define the alias
  if [[ -n $env ]]; then 
    alias "$name"="$env $cmd"
  else
    alias "$name"="$cmd"
  fi

  return 0
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
  variables="$(echo -e "${variables}" | sed -e 's/^[[:space:]]*//')"

  # Remainder is command
  command="$(echo -e "${full_command}" | sed -e 's/^[[:space:]]*//')"

  # Install source package of commands if it doesn't exist
  local base=$(echo "$command" | awk '{print $1}')
  install_required_package $base 
  
  if [ "$?" -eq 1 ]; then
    echo -e "NOTE: Please install package for $base manually and rerun script for aliasing\n"
    return 1
  fi

  # Create the alias
  if [ -z "$variables" ]; then
    alias "$alias_name"="$command"
  else
    alias "$alias_name"="$variables $command"
  fi
}
