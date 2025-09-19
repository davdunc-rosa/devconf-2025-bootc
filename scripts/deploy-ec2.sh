#!/bin/bash

set -e

# Configuration
AWS_REGION=${AWS_REGION:-us-west-2}
KEY_NAME=${KEY_NAME:-""}
PROJECT_NAME="fedora-llm-training"

echo "Deploying Fedora LLM training infrastructure to AWS..."

if [ -z "$KEY_NAME" ]; then
    echo "Error: Please set KEY_NAME environment variable or provide it as argument"
    echo "Usage: KEY_NAME=your-key-name ./scripts/deploy-ec2.sh"
    echo "   or: ./scripts/deploy-ec2.sh your-key-name"
    exit 1
fi

if [ ! -z "$1" ]; then
    KEY_NAME="$1"
fi

cd infrastructure

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Plan deployment
echo "Planning deployment..."
terraform plan \
    -var="aws_region=${AWS_REGION}" \
    -var="key_name=${KEY_NAME}" \
    -var="project_name=${PROJECT_NAME}"

# Ask for confirmation
read -p "Do you want to apply this plan? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying Terraform configuration..."
    terraform apply \
        -var="aws_region=${AWS_REGION}" \
        -var="key_name=${KEY_NAME}" \
        -var="project_name=${PROJECT_NAME}" \
        -auto-approve
    
    echo ""
    echo "Deployment complete!"
    echo "Instance details:"
    terraform output
else
    echo "Deployment cancelled."
fi

cd ..