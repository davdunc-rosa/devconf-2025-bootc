#!/bin/bash

set -e

PROJECT_NAME="fedora-llm-bootc"
CONTAINER_NAME="fedora-llm-bootc"
TAG="42"

echo "Building Fedora bootable container for LLM training..."

# Build the bootable container
podman build -t ${CONTAINER_NAME}:${TAG} -f containers/Containerfile.fedora-llm .

echo "Bootable container built successfully: ${CONTAINER_NAME}:${TAG}"

# Test the container
echo "Testing bootable container..."
podman run --rm ${CONTAINER_NAME}:${TAG} python3 --version
podman run --rm ${CONTAINER_NAME}:${TAG} systemctl --version

echo "Build complete!"
echo ""
echo "To create bootable disk images:"
echo ""
echo "  # For AWS AMI:"
echo "  sudo podman run --rm --privileged --pull=newer \\"
echo "    -v \$(pwd):/output \\"
echo "    quay.io/centos-bootc/bootc-image-builder:latest \\"
echo "    --type ami \\"
echo "    ${CONTAINER_NAME}:${TAG}"
echo ""
echo "  # For QEMU/KVM (qcow2):"
echo "  sudo podman run --rm --privileged --pull=newer \\"
echo "    -v \$(pwd):/output \\"
echo "    quay.io/centos-bootc/bootc-image-builder:latest \\"
echo "    --type qcow2 \\"
echo "    ${CONTAINER_NAME}:${TAG}"
echo ""
echo "  # For ISO installer:"
echo "  sudo podman run --rm --privileged --pull=newer \\"
echo "    -v \$(pwd):/output \\"
echo "    quay.io/centos-bootc/bootc-image-builder:latest \\"
echo "    --type iso \\"
echo "    ${CONTAINER_NAME}:${TAG}"
echo ""
echo "To run as a regular container for testing:"
echo "  podman run -it --rm -v \$(pwd)/training:/opt/llm-training ${CONTAINER_NAME}:${TAG} bash"