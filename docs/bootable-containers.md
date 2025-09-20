# Fedora Bootable Containers for LLM Training

## Overview

This project uses Fedora bootc (bootable containers) to create immutable, container-based operating systems optimized for LLM training workloads. Unlike traditional containers that run on top of an existing OS, bootable containers ARE the operating system.

## What are Bootable Containers?

Fedora bootc implements "transactional, in-place operating system updates via container images." This represents a paradigm shift in OS management:

- **Image-Based OS**: Container images become the unit of OS deployment
- **Transactional Updates**: Atomic filesystem updates with rollback capability
- **Immutable Base**: Read-only `/usr` with writable `/etc` and `/var`
- **Container-Native**: Standard OCI tooling for OS management
- **Reproducible**: Bit-for-bit identical deployments from same image

### Key Principles from Fedora Documentation

1. **Container images as OS distribution mechanism**
2. **Transactional updates via `bootc upgrade`**
3. **Integration with existing container ecosystems**
4. **Preservation of traditional Linux admin patterns**
5. **Support for both cloud and edge deployments**

## Architecture Benefits

### Traditional Approach
```
┌─────────────────────────────────┐
│        Application Layer        │
├─────────────────────────────────┤
│       Container Runtime         │
├─────────────────────────────────┤
│      Host Operating System      │
├─────────────────────────────────┤
│           Hardware              │
└─────────────────────────────────┘
```

### Bootable Container Approach
```
┌─────────────────────────────────┐
│    Application + OS (bootc)     │
├─────────────────────────────────┤
│           Hardware              │
└─────────────────────────────────┘
```

## Implementation Details

### Container Structure

Our Fedora bootc container follows the standard pattern:

```dockerfile
FROM quay.io/fedora/fedora-bootc:42

# Install system agents and dependencies
RUN dnf install -y [system packages] && dnf clean all

# Copy unpackaged applications
COPY training/ /opt/llm-training/
COPY scripts/ /opt/scripts/

# Copy configuration files
COPY config/systemd/ /etc/systemd/system/
COPY config/llm-training.conf /etc/llm-training/

# Run configuration scripts
RUN [setup scripts] && systemctl enable [services]
```

### Key Components

#### 1. System Agents
- **systemd**: Init system and service manager
- **openssh-server**: Remote access capability
- **podman**: Container runtime for nested containers
- **nvidia-container-toolkit**: GPU access for containers

#### 2. Application Layer
- **LLM Training Service**: Systemd-managed training process
- **Python ML Stack**: PyTorch, Transformers, etc.
- **Monitoring Tools**: TensorBoard, logging infrastructure

#### 3. Configuration Management
- **Systemd Units**: Service definitions for auto-start
- **Configuration Files**: Application-specific configs
- **User Management**: Dedicated service accounts

## Deployment Options

### 1. Direct Boot (Bare Metal/VM)
```bash
# Create bootable disk image
sudo podman run --rm --privileged --pull=newer \
  -v $(pwd):/output \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 \
  fedora-llm-bootc:42

# Boot the image directly
qemu-system-x86_64 -m 4G -smp 2 -hda disk.qcow2
```

### 2. AWS AMI Creation
```bash
# Create AMI from bootable container
sudo podman run --rm --privileged --pull=newer \
  -v $(pwd):/output \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type ami \
  fedora-llm-bootc:42

# Upload to AWS and create EC2 instances
```

### 3. Container Mode (Development)
```bash
# Run as regular container for testing
podman run -it --rm \
  --systemd=always \
  -v $(pwd)/training:/opt/llm-training \
  fedora-llm-bootc:42
```

## Service Management

### LLM Training Service

The training workload runs as a systemd service:

```ini
[Unit]
Description=Fedora LLM Training Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=llm-user
Group=llm-user
WorkingDirectory=/opt/llm-training
Environment=PYTHONPATH=/opt/llm-training
ExecStart=/usr/bin/python3 /opt/llm-training/train.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Service Operations
```bash
# Check service status
systemctl status llm-training.service

# Start/stop training
systemctl start llm-training.service
systemctl stop llm-training.service

# View logs
journalctl -u llm-training.service -f

# Enable auto-start
systemctl enable llm-training.service
```

## Updates and Maintenance

### Atomic Updates

Bootable containers support atomic updates:

```bash
# Pull new image version
podman pull fedora-llm-bootc:43

# Stage update (doesn't affect running system)
bootc switch fedora-llm-bootc:43

# Reboot to apply update
systemctl reboot

# Rollback if needed
bootc rollback
```

### Configuration Changes

Since the filesystem is immutable, configuration changes require:

1. **Rebuild container** with new configuration
2. **Use /etc overlays** for runtime changes
3. **Mount external volumes** for persistent data

## Security Advantages

### Immutable Root Filesystem
- **Tamper Resistance**: Root filesystem cannot be modified at runtime
- **Consistent State**: System always matches the container image
- **Attack Surface Reduction**: Limited write access reduces vulnerability

### Atomic Updates
- **Rollback Capability**: Failed updates can be instantly reverted
- **Consistent Updates**: No partial update states
- **Verified Boot**: Cryptographic verification of system integrity

### Container Security
- **SELinux**: Enforcing mode by default
- **Minimal Attack Surface**: Only necessary packages installed
- **Isolation**: Clear separation between system and application layers

## Performance Characteristics

### Boot Time
- **Fast Boot**: Optimized for quick startup
- **Parallel Initialization**: Systemd parallel service startup
- **Minimal Services**: Only essential services enabled

### Resource Usage
- **Memory Efficient**: No container runtime overhead
- **CPU Optimized**: Direct hardware access
- **Storage Efficient**: Shared base layers, copy-on-write

### GPU Access
- **Direct Access**: Native GPU driver integration
- **Container Passthrough**: GPU access for nested containers
- **CUDA Support**: Full CUDA toolkit integration

## Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check service status
systemctl status llm-training.service

# Check logs
journalctl -u llm-training.service --no-pager

# Check dependencies
systemctl list-dependencies llm-training.service
```

#### GPU Not Available
```bash
# Check GPU detection
nvidia-smi

# Verify container toolkit
podman run --rm --device nvidia.com/gpu=all nvidia/cuda:11.8-base nvidia-smi

# Check user permissions
groups llm-user
```

#### Network Issues
```bash
# Check network status
systemctl status NetworkManager

# Test connectivity
ping -c 3 8.8.8.8

# Check firewall
firewall-cmd --list-all
```

### Debug Mode

For troubleshooting, boot into debug mode:

```bash
# Add to kernel command line
systemd.unit=rescue.target

# Or drop to emergency shell
systemd.unit=emergency.target
```

## Best Practices

### Container Design
1. **Minimize Layers**: Combine RUN commands to reduce image size
2. **Clean Package Cache**: Always run `dnf clean all`
3. **Use Specific Tags**: Avoid `latest` tags for reproducibility
4. **Security Scanning**: Scan images for vulnerabilities

### Service Configuration
1. **Non-Root Services**: Run applications as dedicated users
2. **Resource Limits**: Set appropriate CPU/memory limits
3. **Logging**: Configure structured logging
4. **Health Checks**: Implement service health monitoring

### Update Strategy
1. **Test Updates**: Validate new images in staging
2. **Gradual Rollout**: Update instances incrementally
3. **Monitoring**: Monitor system health during updates
4. **Rollback Plan**: Always have a rollback strategy

## Integration with Kubernetes

Bootable containers can be integrated with Kubernetes in several ways:

### 1. Node OS
Use bootable containers as the Kubernetes node operating system:
```yaml
apiVersion: v1
kind: Node
metadata:
  name: fedora-bootc-node
spec:
  # Node runs Fedora bootc as OS
```

### 2. Workload Containers
Run bootable containers as Kubernetes workloads:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llm-training
spec:
  template:
    spec:
      containers:
      - name: llm-trainer
        image: fedora-llm-bootc:42
        # Container runs in systemd mode
```

### 3. Hybrid Approach
Combine both approaches for maximum flexibility and control.

## Future Roadmap

### Planned Enhancements
- **Multi-arch Support**: ARM64 and x86_64 images
- **OCI Compliance**: Full OCI artifact support
- **Signed Images**: Cryptographic image signing
- **Automated Testing**: CI/CD pipeline integration

### Integration Opportunities
- **Red Hat OpenShift**: Native bootc support
- **Fedora CoreOS**: Migration path and compatibility
- **Edge Computing**: Optimized edge deployment
- **IoT Devices**: Lightweight IoT variants

This bootable container approach provides a modern, secure, and maintainable foundation for LLM training workloads while maintaining full compatibility with Red Hat's container ecosystem.