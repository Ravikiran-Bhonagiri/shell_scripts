#!/bin/bash

# Variables
IMAGE_NAME="bhonagiri/sound_anomaly"
IMAGE_TAG="latest"
CONTAINER_NAME="sound_anomaly_container"

# Step 1: Stop and remove any running containers with the same name
echo "Stopping any running containers..."
docker ps -q --filter "name=$CONTAINER_NAME" | xargs -r docker stop
docker ps -aq --filter "name=$CONTAINER_NAME" | xargs -r docker rm

# Step 2: Remove the existing image
echo "Removing existing image $IMAGE_NAME:$IMAGE_TAG..."
docker images -q $IMAGE_NAME:$IMAGE_TAG | xargs -r docker rmi -f

# Step 3: Pull the latest image from Docker Hub
echo "Pulling the latest image $IMAGE_NAME:$IMAGE_TAG from Docker Hub..."
docker pull $IMAGE_NAME:$IMAGE_TAG

# Step 4: Run the container
echo "Running the new container..."
docker run -it --rm --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_TAG

# End of script
