#!/bin/bash

# Define the image name and tag
IMAGE_NAME="bhonagiri/sound_anomaly"
IMAGE_TAG="multistage"

# Pull the image from Docker Hub
echo "Pulling image $IMAGE_NAME:$IMAGE_TAG from Docker Hub..."
docker pull $IMAGE_NAME:$IMAGE_TAG

# Run the image
echo "Running the Docker image..."
docker run -it --rm $IMAGE_NAME:$IMAGE_TAG

# End of script
