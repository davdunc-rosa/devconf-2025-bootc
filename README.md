# Fedora LLM Training Platform

A comprehensive platform for training and serving Large Language Models (LLMs) using Fedora bootable containers on Amazon EC2 infrastructure. The project leverages Red Hat technologies to provide enterprise-ready AI infrastructure with container-native model management.

## Project Overview

This platform demonstrates enterprise-ready AI solutions built on Red Hat/Fedora open source foundations, featuring:

- **Bootable Container Architecture**: Uses Fedora bootc for immutable, reproducible deployments
- **Container-Native LLM Management**: Integrates RamaLama for seamless model serving and management
- **Cloud-Ready Infrastructure**: Terraform-based AWS EC2 deployment with cloud-init automation
- **Enterprise Integration**: Systemd services, Kubernetes support, and Red Hat technology stack
- **GPU Acceleration**: Optimized for NVIDIA GPU instances with CUDA support

## Key Features

### Core Technologies
- **Base OS**: Fedora bootc 42 (bootable containers)
- **Container Runtime**: Podman with systemd integration
- **LLM Framework**: RamaLama for container-native model management
- **ML Libraries**: PyTorch, Transformers, Datasets, Accelerate
- **Infrastructure**: Terraform + AWS EC2
- **Orchestration**: Kubernetes (optional), systemd services

### Target Use Cases
- Enterprise LLM training and fine-tuning
- Container-native AI model deployment
- Scalable inference serving with OpenAI-compatible APIs
- Red Hat ecosystem AI solutions
- Educational and research AI infrastructure

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

4. **Start Training and Serving**:
   ```bash
   # SSH to your EC2 instance
   ssh -i ~/.ssh/your-key.pem fedora@<instance-ip>
   
   # Training starts automatically via systemd service
   sudo systemctl start llm-training.service
   
   # Start RamaLama inference server
   ramalama serve --port 8080 --host 0.0.0.0 llama2:7b-chat
   
   # Or use systemd service
   sudo systemctl start ramalama-inference.service
   ```

### RamaLama Integration

This platform integrates RamaLama for container-native LLM management:

```bash
# Pull and serve models
ramalama pull llama2:7b-chat
ramalama serve --port 8080 --host 0.0.0.0 llama2:7b-chat

# OpenAI-compatible API
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2:7b-chat",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# Systemd service management
systemctl status ramalama-inference.service
journalctl -u ramalama-inference.service -f
```

See [`examples/ramalama-usage.md`](examples/ramalama-usage.md) for comprehensive usage examples.

### Development Workflow

1. Set up Fedora bootable containers for EC2
2. Configure training environment with systemd services
3. Deploy LLM training workloads as system services
4. Integrate RamaLama for model serving and inference
5. Set up Kubernetes cluster integration (optional)

## Project Structure

```
├── config/                 # System and application configurations
│   ├── cloud-init/         # Cloud-init configuration files
│   ├── systemd/            # Systemd service definitions
│   ├── llm-training.conf   # Main training configuration (INI)
│   └── ramalama.conf       # RamaLama model serving config (INI)
├── containers/             # Container definitions
│   └── Containerfile.fedora-llm  # Main bootc container definition
├── docs/                   # Documentation
│   └── bootable-containers.md    # Detailed bootc implementation guide
├── examples/               # Usage examples and guides
│   └── ramalama-usage.md   # RamaLama integration examples
├── infrastructure/         # Terraform infrastructure as code
│   ├── ec2-fedora.tf       # Main EC2 infrastructure
│   ├── user-data.sh        # Cloud-init shell script
│   └── user-data.yaml      # Cloud-init YAML configuration
├── kubernetes/             # Kubernetes manifests
│   └── llm-agent-deployment.yaml
├── presentation/           # Presentation materials
│   ├── slides.md           # Main presentation deck
│   ├── executive-summary.md
│   ├── technical-appendix.md
│   └── README.md           # Presentation usage guide
├── scripts/                # Automation and build scripts
│   ├── build-container.sh  # Standard container build
│   ├── build-bootc-container.sh  # Bootable container build
│   ├── deploy-ec2.sh       # Infrastructure deployment
│   └── setup-llm-environment.sh  # Environment setup
└── training/               # ML training code and configs
    ├── config.yaml         # Training parameters (YAML)
    ├── requirements.txt    # Python dependencies
    └── train.py            # Main training script
```

## Documentation

### Core Documentation
- **[Bootable Containers Guide](docs/bootable-containers.md)** - Comprehensive guide to Fedora bootc implementation
- **[RamaLama Usage Examples](examples/ramalama-usage.md)** - Container-native LLM management examples
- **[Executive Summary](presentation/executive-summary.md)** - Business value and strategic overview
- **[Technical Presentation](presentation/slides.md)** - Complete technical presentation deck

### Configuration References
- **System Config**: `config/llm-training.conf` (INI format)
- **RamaLama Config**: `config/ramalama.conf` (INI format)  
- **Training Config**: `training/config.yaml` (YAML format)
- **Cloud-init**: `infrastructure/user-data.yaml`

### Quick References
- **Build Commands**: `./scripts/build-container.sh` or `./scripts/build-bootc-container.sh`
- **Deploy Infrastructure**: `./scripts/deploy-ec2.sh`
- **Service Management**: `systemctl status llm-training.service`
- **RamaLama Commands**: `ramalama pull/serve/list`

## Technology Partnership

Built on Red Hat/Fedora technologies to demonstrate enterprise-ready AI solutions with open source foundations, supporting Red Hat partnership initiatives while maintaining complete open-source alignment.