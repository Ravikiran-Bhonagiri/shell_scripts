#!/bin/bash

# Define the image name
IMAGE_NAME="sound_anomaly"

# Step 1: Stop all running containers using the image
echo "Stopping all running containers with image containing '$IMAGE_NAME'..."
docker ps -q --filter "ancestor=$IMAGE_NAME" | xargs -r docker stop

# Step 2: Remove all containers using the image
echo "Removing all containers with image containing '$IMAGE_NAME'..."
docker ps -aq --filter "ancestor=$IMAGE_NAME" | xargs -r docker rm

# Step 3: Remove all images with the specified name
echo "Removing all images containing '$IMAGE_NAME'..."
docker images -q $IMAGE_NAME | xargs -r docker rmi -f

echo "All containers and images related to '$IMAGE_NAME' have been stopped and removed."
