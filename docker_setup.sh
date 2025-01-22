#!/bin/bash
# Exit on errors
set -e

# Check if script is run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Check for internet connectivity
if ! ping -c 1 google.com &> /dev/null; then
  echo "No internet connection. Please check your network and try again."
  exit 1
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
  echo "Docker is already installed: $(docker --version)"
else
  echo "Docker not found. Proceeding with installation..."
  # Update and upgrade system
  sudo apt-get update && sudo apt-get upgrade -y

  # Install Docker using the official convenience script
  echo "Downloading and installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
fi

# Add user to Docker group
echo "Adding the current user to the Docker group..."
sudo usermod -aG docker $USER
echo "Please log out and log back in to apply Docker group changes."

# Enable Docker at startup
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version && echo "Docker is installed successfully!"

# Test Docker
echo "Testing Docker with the hello-world container..."
docker run hello-world && echo "Docker is working correctly!"

# Prompt for Docker Compose installation
read -p "Do you want to install Docker Compose? (y/n): " INSTALL_COMPOSE
if [[ "$INSTALL_COMPOSE" =~ ^[Yy]$ ]]; then
  echo "Installing Docker Compose..."
  sudo apt-get install -y libffi-dev libssl-dev python3 python3-pip
  sudo pip3 install docker-compose
  docker-compose --version && echo "Docker Compose installed successfully!"
else
  echo "Skipping Docker Compose installation."
fi

# Cleanup
echo "Cleaning up temporary files..."
rm -f get-docker.sh
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Final message
echo "Docker setup is complete! Log out and log back in for changes to take effect."
