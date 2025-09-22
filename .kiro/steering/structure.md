# Project Structure

## Directory Organization

```
├── config/                 # System and application configurations
│   ├── cloud-init/         # Cloud-init configuration files
│   ├── systemd/            # Systemd service definitions
│   ├── llm-training.conf   # Main training configuration (INI)
│   └── ramalama.conf       # RamaLama model serving config (INI)
├── containers/             # Container definitions
│   └── Containerfile.fedora-llm  # Main bootc container definition
├── docs/                   # Documentation
│   └── bootable-containers.md
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

## File Naming Conventions

- **Scripts**: Use kebab-case with `.sh` extension (`build-container.sh`)
- **Configs**: Use kebab-case with appropriate extension (`llm-training.conf`)
- **Containers**: Use descriptive names (`Containerfile.fedora-llm`)
- **Documentation**: Use kebab-case markdown (`bootable-containers.md`)

## Configuration File Formats

- **System configs**: INI format (`.conf` files)
- **Training configs**: YAML format (`.yaml` files)
- **Infrastructure**: Terraform HCL (`.tf` files)
- **Cloud-init**: YAML format for user-data

## Key Paths

- **Working directory**: `/opt/llm-training` (in containers)
- **Model storage**: `/opt/llm-training/models`
- **Log directory**: `/var/log/llm-training`
- **Config directory**: `/etc/llm-training/`

## Architecture Patterns

- **Immutable Infrastructure**: Bootable containers for reproducible deployments
- **Configuration as Code**: All configs version controlled
- **Service-Oriented**: Systemd services for process management
- **Container-Native**: Podman-first approach with systemd integration