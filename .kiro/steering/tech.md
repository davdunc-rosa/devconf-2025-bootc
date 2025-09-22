# Technology Stack

## Core Technologies

- **Base OS**: Fedora bootc 42 (bootable containers)
- **Container Runtime**: Podman with systemd integration
- **LLM Framework**: RamaLama for container-native model management
- **ML Libraries**: PyTorch, Transformers, Datasets, Accelerate
- **Infrastructure**: Terraform + AWS EC2
- **Orchestration**: Kubernetes (optional), systemd services

## Build System

### Container Builds
```bash
# Standard container build
./scripts/build-container.sh

# Bootable container build
./scripts/build-bootc-container.sh

# Build with Podman directly
podman build -t fedora-llm:latest -f containers/Containerfile.fedora-llm .
```

### Infrastructure Deployment
```bash
# Deploy EC2 infrastructure
export KEY_NAME="your-key-pair-name"
./scripts/deploy-ec2.sh

# Manual Terraform
cd infrastructure/
terraform init
terraform plan
terraform apply
```

## Python Dependencies

Core ML stack defined in `training/requirements.txt`:
- torch>=2.0.0
- transformers>=4.30.0
- datasets>=2.12.0
- accelerate>=0.20.0
- bitsandbytes>=0.39.0
- peft>=0.4.0 (Parameter Efficient Fine-Tuning)
- trl>=0.4.0 (Transformer Reinforcement Learning)

## Configuration Management

- **System Config**: `/config/llm-training.conf` (INI format)
- **RamaLama Config**: `/config/ramalama.conf` (INI format)
- **Training Config**: `training/config.yaml` (YAML format)
- **Cloud-init**: `infrastructure/user-data.yaml`

## Common Commands

### Development
```bash
# Test training locally
podman run -it --rm -v $(pwd)/training:/opt/llm-training fedora-llm:latest python3 train.py

# Start RamaLama inference server
ramalama serve --port 8080 --host 0.0.0.0 llama2:7b-chat

# Check systemd services
systemctl status llm-training.service
systemctl status ramalama-inference.service
```

### GPU Support
- NVIDIA Container Toolkit integration
- CUDA 11.8+ support
- Automatic GPU detection in containers