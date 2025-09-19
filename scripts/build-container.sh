#!/bin/bash

set -e

PROJECT_NAME="fedora-llm-training"
CONTAINER_NAME="fedora-llm"
TAG="latest"

echo "Building Fedora LLM training container..."

# Build the container
podman build -t ${CONTAINER_NAME}:${TAG} -f containers/Containerfile.fedora-llm .

echo "Container built successfully: ${CONTAINER_NAME}:${TAG}"

# Optional: Run a test
echo "Testing container..."
podman run --rm ${CONTAINER_NAME}:${TAG} python3 --version

echo "Build complete!"
echo ""
echo "To run the container:"
echo "  podman run -it --rm -v \$(pwd)/training:/opt/llm-training ${CONTAINER_NAME}:${TAG} bash"
echo ""
echo "To start training:"
echo "  podman run -it --rm -v \$(pwd)/training:/opt/llm-training ${CONTAINER_NAME}:${TAG} python3 train.py"