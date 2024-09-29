#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
  echo "Must be root to set boot volume"
  exit 1
fi

# Get the current boot volume
current_volume=$(bless --info --getBoot)

# Get the current boot volume device identifier
current_device=$(bless --info --getBoot | sed 's/.*\(\/dev\/[^ ]*\).*/\1/')

# Translate the device identifier to a volume name
current_volume=$(diskutil info "$current_device" | grep "Volume Name:" | awk '{for (i=3; i<=NF; i++) printf "%s ", $i; print ""}' | awk '{$1=$1};1')

# Use an array to store bootable volumes
boot_volumes=()
while IFS= read -r volume; do
  # Check if the volume name does not contain "Data"
  if [[ ! $volume =~ Data ]]; then
    boot_volumes+=("$volume")
fi
done < <(ls /Volumes)

# Display the volumes in a numbered list and let the user select
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

# Use the bless command to set the boot volume
echo -n "\nSetting boot volume to $selected_volume... "
mkfifo passwordpipe
bless --mount "$VOLUME_PATH" --setBoot < passwordpipe &
rm passwordpipe
echo "done!"

# Reboot
if [ "$1" == "-r" ]; then
  reboot
fi
