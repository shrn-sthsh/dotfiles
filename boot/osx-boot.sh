#!/bin/bash

# Check on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "ERROR: script is only for macOS boot"
  return 1
fi

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

# Get the current boot volume and device identifier
current_volume=$(bless --info --getBoot)
current_device=$(bless --info --getBoot | sed 's/.*\(\/dev\/[^ ]*\).*/\1/')
current_volume=$(diskutil info "$current_device" | grep "Volume Name:" | awk '{for (i=3; i<=NF; i++) printf "%s ", $i; print ""}' | awk '{$1=$1};1')

# Collect bootable volumes
boot_volumes=()
while IFS= read -r volume; do
  # Check if the volume name does not contain "Data"
  if [[ ! $volume =~ Data ]]; then
    boot_volumes+=("$volume")
fi
done < <(ls /Volumes)

# Display the volumes
echo "Available Bootable Volumes:"
for i in "${!boot_volumes[@]}"; do
  volume=${boot_volumes[$i]}

  # Mark the current boot volume with an asterisk
  if [[ "$current_volume" == "$volume" ]]; then
    echo "* $((i+1))) $volume"
  else
    echo "  $((i+1))) $volume"
  fi
done

# User selection
read -p "Choose volume for next boot: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#boot_volumes[@]}" ]; then
  echo "Invalid selection"
  exit 1
fi
selected_volume=${boot_volumes[$((choice-1))]}
VOLUME_PATH="/Volumes/$selected_volume"

# Set the boot volume with bless
set_message="\nSetting boot volume to $selected_volume"
echo -ne "$set_message"
mkfifo passwordpipe
bless --mount "$VOLUME_PATH" --setBoot < passwordpipe &
echo "" > passwordpipe
rm passwordpipe

# Overwrite sudo password ask when already given macOS bug
sleep 0.00001
printf "\r%$(( $(whoami | wc -c) + 14 + ${#set_message}))s"
stty sane
stty echo

# Countdown to give bless time
echo -ne "\rSetting boot volume to $selected_volume"
for i in {1..5}; do
  echo -n "."
  sleep 1
done
echo -n " done!"

# Reboot
if [ "$1" == "-r" ]; then
  echo -e "\nRebooting... "
  sleep 2
  reboot
fi
