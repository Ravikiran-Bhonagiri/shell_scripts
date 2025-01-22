#!/bin/bash

# Update the system
sudo apt-get update && sudo apt-get upgrade -y

# Download and run the Docker installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add the current user to the Docker group to run Docker without sudo
sudo usermod -aG docker $USER
