#!/bin/bash

# Step 1: Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt-get update && sudo apt-get upgrade -y

# Step 2: Install Docker using the official convenience script
echo "Downloading and installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Step 3: Add the current user to the Docker group for non-root access
echo "Adding the current user to the Docker group for non-root access..."
sudo usermod -aG docker $USER

# Step 4: Enable Docker to start on boot
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker
sudo systemctl start docker

# Step 5: Verify Docker installation
echo "Verifying Docker installation..."
docker --version && echo "Docker is installed successfully!"

# Step 6: Test Docker with the hello-world container
echo "Testing Docker with the hello-world container..."
docker run hello-world && echo "Docker is working correctly!"

# Step 7 (Optional): Install Docker Compose
echo "Installing Docker Compose..."
sudo apt-get install -y libffi-dev libssl-dev python3 python3-pip
sudo pip3 install docker-compose
docker-compose --version && echo "Docker Compose installed successfully!"

# Step 8: Clean up the installation script
echo "Cleaning up the installation script..."
rm get-docker.sh

# Step 9: Print success message
echo "Docker and Docker Compose installation is complete! Log out and log back in for changes to take effect."
