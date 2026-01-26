#!/bin/bash

echo "Stopping claude-sandbox container..."
docker stop claude-sandbox 2>/dev/null

echo "Removing claude-sandbox container..."
docker rm claude-sandbox 2>/dev/null

echo ""
echo "✓ Sandbox cleaned up successfully!"
echo ""
echo "Note: This removes the container and all data inside it."
echo "Your Docker images inside the sandbox are also removed."
echo ""
echo "To remove the sandbox image from your host, run:"
echo "  docker rmi claude-sandbox"
echo ""
echo "To start a fresh sandbox, run:"
echo "  ./start.sh"