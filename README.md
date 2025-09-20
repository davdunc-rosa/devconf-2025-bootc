# Fedora LLM Training on AWS EC2

A project for training and serving LLM models using Fedora bootable containers on Amazon EC2 instances, featuring RamaLama for container-native LLM management.

## Project Overview

- **Base OS**: Fedora bootc (bootable containers)
- **Container Runtime**: Podman with RamaLama integration
- **LLM Management**: RamaLama for container-native model serving
- **Target Platform**: Amazon EC2 with cloud-init
- **Goal**: Enterprise-ready LLM infrastructure with Red Hat technologies

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EC2 Instance  │    │   EC2 Instance  │    │   EC2 Instance  │
│ Fedora bootc 42 │    │ Fedora bootc 42 │    │ Fedora bootc 42 │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │LLM Service│  │    │  │LLM Service│  │    │  │LLM Service│  │
│  │(systemd)  │  │    │  │(systemd)  │  │    │  │(systemd)  │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Kubernetes    │
                    │    Cluster      │
                    └─────────────────┘
```

## Getting Started

### Quick Start

1. **Deploy Infrastructure**:
   ```bash
   export KEY_NAME="your-key-pair-name"
   ./scripts/deploy-ec2.sh
   ```

2. **Build Bootable Container**:
   ```bash
   ./scripts/build-bootc-container.sh
   ```

3. **Create Bootable AMI** (optional):
   ```bash
   sudo podman run --rm --privileged --pull=newer \
     -v $(pwd):/output \
     quay.io/centos-bootc/bootc-image-builder:latest \
     --type ami \
     fedora-llm-bootc:42
   ```

4. **Start Training**:
   ```bash
   # SSH to your EC2 instance
   ssh -i ~/.ssh/your-key.pem fedora@<instance-ip>
   
   # Training starts automatically via systemd service
   # Or run manually:
   sudo systemctl start llm-training.service
   ```

### Development Workflow

1. Set up Fedora bootable containers for EC2
2. Configure training environment with systemd services
3. Deploy LLM training workloads as system services
4. Set up Kubernetes cluster integration

## Components

- `/infrastructure/` - Terraform for EC2 setup with cloud-init
- `/containers/` - Fedora bootc container definitions
- `/training/` - LLM training scripts and configurations
- `/config/` - System services, cloud-init, and RamaLama configuration
- `/scripts/` - Automation scripts for deployment and management
- `/examples/` - RamaLama usage examples and integration guides
- `/kubernetes/` - K8s manifests and cluster setup