#!/bin/bash

# Script to upgrade Raspberry Pi OS from Buster to Bullseye

echo "========================================="
echo "Raspberry Pi OS Upgrade: Buster to Bullseye"
echo "========================================="

# Step 1: Backup important configuration files
BACKUP_DIR=~/os_backup_$(date +%Y%m%d%H%M%S)
echo "Creating backup directory: $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
sudo cp /etc/apt/sources.list "$BACKUP_DIR"
sudo cp /etc/apt/sources.list.d/raspi.list "$BACKUP_DIR"
echo "Backup completed. Configuration files saved in $BACKUP_DIR."

# Step 2: Update the package list and upgrade current packages
echo "Updating and upgrading current packages..."
sudo apt update && sudo apt full-upgrade -y

# Step 3: Update sources.list to point to Bullseye
echo "Updating sources.list and raspi.list to Bullseye..."
sudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list
sudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/raspi.list

# Step 4: Update the package list with Bullseye sources
echo "Fetching Bullseye package list..."
sudo apt update

# Step 5: Perform a full upgrade to Bullseye
echo "Upgrading the system to Bullseye. This may take a while..."
sudo apt full-upgrade -y

# Step 6: Clean up unused packages and dependencies
echo "Cleaning up unused packages and dependencies..."
sudo apt autoremove -y && sudo apt autoclean -y

# Step 7: Verify the new OS version
echo "Verifying the OS version..."
OS_VERSION=$(lsb_release -a 2>/dev/null)
echo "Current OS Version:"
echo "$OS_VERSION"

# Step 8: Prompt for system reboot
echo "Upgrade to Bullseye is complete. A reboot is required to apply changes."
read -p "Do you want to reboot now? (y/n): " REBOOT

if [[ "$REBOOT" == "y" || "$REBOOT" == "Y" ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Please reboot the system manually later to complete the upgrade."
fi

echo "========================================="
echo "Upgrade to Bullseye Completed Successfully"
echo "========================================="
