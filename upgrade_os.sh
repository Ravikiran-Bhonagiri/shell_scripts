#!/bin/bash

# Script to update and upgrade Raspberry Pi OS

echo "===================================="
echo "Raspberry Pi OS Upgrade Script"
echo "===================================="

# Step 1: Update the package list and upgrade existing packages
echo "Updating and upgrading current packages..."
sudo apt update && sudo apt full-upgrade -y

# Step 2: Backup current system configuration
BACKUP_DIR=~/os_backup_$(date +%Y%m%d%H%M%S)
echo "Backing up important system files to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
sudo cp /etc/apt/sources.list "$BACKUP_DIR"
sudo cp /etc/apt/sources.list.d/raspi.list "$BACKUP_DIR"
echo "Backup completed."

# Step 3: Update sources.list to point to the new OS version
echo "Updating sources to the new OS version (Bullseye)..."
sudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list
sudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/raspi.list

# Step 4: Update and upgrade to the new OS version
echo "Starting the distribution upgrade..."
sudo apt update && sudo apt full-upgrade -y

# Step 5: Clean up unnecessary packages
echo "Cleaning up unused packages and dependencies..."
sudo apt autoremove -y && sudo apt autoclean -y

# Step 6: Verify the OS version
echo "Verifying the new OS version..."
OS_VERSION=$(lsb_release -a 2>/dev/null)
echo "Current OS Version:"
echo "$OS_VERSION"

# Step 7: Prompt for a system reboot
echo "Upgrade process completed. A reboot is required to apply changes."
read -p "Do you want to reboot now? (y/n): " REBOOT

if [[ "$REBOOT" == "y" || "$REBOOT" == "Y" ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Please reboot the system manually later."
fi

echo "===================================="
echo "OS Upgrade Script Completed"
echo "===================================="
