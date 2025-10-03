# Fedora LLM Training Platform Overview

## Platform Architecture

The Fedora LLM Training Platform provides a comprehensive, enterprise-ready solution for training and serving Large Language Models using Red Hat/Fedora technologies on AWS infrastructure.

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS EC2 Infrastructure                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Fedora bootc 42 │  │ Fedora bootc 42 │  │ Kubernetes   │ │
│  │                 │  │                 │  │ Cluster      │ │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ (Optional)   │ │
│  │ │LLM Training │ │  │ │RamaLama     │ │  │              │ │
│  │ │Service      │ │  │ │Inference    │ │  │              │ │
│  │ │(systemd)    │ │  │ │Server       │ │  │              │ │
│  │ └─────────────┘ │  │ └─────────────┘ │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

#### Base Infrastructure
- **Operating System**: Fedora bootc 42 (bootable containers)
- **Container Runtime**: Podman with systemd integration
- **Cloud Platform**: Amazon EC2 with GPU support
- **Infrastructure as Code**: Terraform with cloud-init

#### AI/ML Stack
- **LLM Framework**: RamaLama for container-native model management
- **ML Libraries**: PyTorch, Transformers, Datasets, Accelerate
- **Model Optimization**: bitsandbytes, PEFT (Parameter Efficient Fine-Tuning)
- **Training Framework**: TRL (Transformer Reinforcement Learning)

#### Enterprise Features
- **Service Management**: systemd services for process management
- **Orchestration**: Kubernetes support (optional)
- **Monitoring**: journalctl logging, system monitoring
- **Security**: SELinux, immutable filesystem, container isolation

## Key Features

### Bootable Container Architecture

The platform uses Fedora bootc to create immutable, container-based operating systems:

- **Image-Based OS**: Container images become the unit of OS deployment
- **Transactional Updates**: Atomic filesystem updates with rollback capability
- **Immutable Base**: Read-only `/usr` with writable `/etc` and `/var`
- **Container-Native**: Standard OCI tooling for OS management
- **Reproducible**: Bit-for-bit identical deployments from same image

### Container-Native LLM Management

RamaLama provides seamless model management within the container ecosystem:

- **Model Registry**: Pull/push models like container images
- **OpenAI-Compatible API**: Standard REST API for inference
- **Systemd Integration**: Native service management
- **GPU Acceleration**: Automatic GPU detection and utilization
- **Multi-Model Support**: Serve multiple models simultaneously

### Enterprise Integration

Built for enterprise deployment with Red Hat technologies:

- **Red Hat Ecosystem**: Fedora development → RHEL production path
- **Kubernetes Ready**: Native K8s deployment capabilities
- **Security First**: SELinux, container isolation, immutable infrastructure
- **Scalable Architecture**: Linear scaling across multiple instances
- **Monitoring & Observability**: Comprehensive logging and monitoring

## Deployment Models

### 1. Single Instance Development
```bash
# Quick development setup
./scripts/build-container.sh
podman run -it --systemd=always fedora-llm:latest
```

### 2. AWS EC2 Production
```bash
# Full infrastructure deployment
export KEY_NAME="your-key-pair"
./scripts/deploy-ec2.sh
```

### 3. Kubernetes Cluster
```bash
# Deploy to existing K8s cluster
kubectl apply -f kubernetes/llm-agent-deployment.yaml
```

### 4. Bootable Container Image
```bash
# Create bootable disk image
./scripts/build-bootc-container.sh
sudo podman run --rm --privileged \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type ami fedora-llm-bootc:42
```

## Use Cases

### Enterprise LLM Training
- Fine-tune models on proprietary datasets
- Scalable training across multiple GPU instances
- Reproducible training environments
- Integration with existing enterprise infrastructure

### Container-Native AI Deployment
- Deploy AI models as system services
- Immutable infrastructure for consistent deployments
- Container-based model distribution and updates
- Integration with container orchestration platforms

### Scalable Inference Serving
- OpenAI-compatible API endpoints
- Auto-scaling based on demand
- Multi-model serving capabilities
- High-availability deployment patterns

### Red Hat Ecosystem Solutions
- Demonstrate Red Hat technology capabilities
- Migration path from Fedora to RHEL
- Integration with OpenShift and other Red Hat products
- Support for Red Hat partnership initiatives

### Educational and Research
- Reproducible research environments
- Teaching container-native AI deployment
- Open-source AI infrastructure examples
- Community-driven development and contributions

## Benefits

### Technical Benefits
- **Immutable Infrastructure**: Consistent, reproducible deployments
- **Container-Native**: Leverage existing container expertise and tooling
- **GPU Optimization**: Efficient GPU utilization for training and inference
- **Scalable Architecture**: Linear performance scaling
- **Open Source**: No vendor lock-in, full transparency

### Business Benefits
- **Cost Efficiency**: Optimized resource utilization, spot instance support
- **Faster Time to Market**: Container-native development and deployment
- **Risk Mitigation**: Open-source stack eliminates vendor dependencies
- **Strategic Alignment**: Supports Red Hat partnership objectives
- **Future-Proof**: Built on industry-standard technologies

### Operational Benefits
- **Simplified Management**: systemd service management
- **Automated Deployment**: Infrastructure as Code with Terraform
- **Easy Updates**: Atomic updates with rollback capability
- **Comprehensive Monitoring**: Built-in logging and observability
- **Security**: Enterprise-grade security from day one

## Getting Started

### Prerequisites
- AWS account with EC2 permissions
- Terraform installed locally
- Podman or Docker for container builds
- SSH key pair for EC2 access

### Quick Start
1. **Clone Repository**: `git clone <repository-url>`
2. **Deploy Infrastructure**: `./scripts/deploy-ec2.sh`
3. **Build Containers**: `./scripts/build-container.sh`
4. **Start Training**: Connect to EC2 instance and start services

### Next Steps
- Review [Bootable Containers Guide](bootable-containers.md)
- Explore [RamaLama Usage Examples](../examples/ramalama-usage.md)
- Check [Presentation Materials](../presentation/README.md)
- Join the community and contribute

## Support and Community

### Documentation
- Comprehensive guides in `/docs` directory
- Usage examples in `/examples` directory
- Presentation materials in `/presentation` directory

### Community
- Open-source development model
- Community contributions welcome
- Regular updates and improvements
- Integration with Red Hat ecosystem

This platform represents the future of enterprise AI infrastructure, combining the power of Red Hat technologies with modern container-native approaches to deliver scalable, secure, and maintainable LLM training and serving capabilities.