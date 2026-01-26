#!/bin/bash

# Build the image if it doesn't exist
if [[ "$(docker images -q claude-sandbox 2> /dev/null)" == "" ]]; then
    echo "Building claude-sandbox image..."
    docker build -t claude-sandbox .
fi

# Check if container exists
if [ "$(docker ps -aq -f name=claude-sandbox)" ]; then
    echo "Starting existing container..."
    docker start -ai claude-sandbox
else
    echo "Creating new container..."
    docker run -it \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /path/to/your/project:/workspace/mounted-project \
        --name claude-sandbox \
        claude-sandbox
fi