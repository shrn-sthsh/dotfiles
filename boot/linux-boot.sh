#!/bin/bash

# Check if script is being run as root
if ! type sudo &>/dev/null; then
  echo -n "ERROR: \"sudo\" must be installed before running boot script"
  return 1
fi
sudoer=true
if ! sudo -v 2>/dev/null; then
  sudoer=false
fi 
if [ "$sudoer" = false ]; then
  echo -e "\nERROR: User must be on sudoer list to install packages"
  return 1
fi

# Run asahi bless executable
if ! type asahi-bless &>/dev/null; then
  echo -n "ERROR: \"asahi-bless\" must be installed before running boot script"
  return 1
fi
sudo asahi-bless

# Reboot
if [ "$1" == "-r" ]; then
  reboot
fi
