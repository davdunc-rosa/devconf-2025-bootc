# Enterprise AI Inference with Fedora
## Building Production-Ready LLM Servers for Red Hat Enterprise

---

## 🎯 Interactive Workshop Format

### **Three Hands-On Exercises**
1. **🛠️ Build Bootable Container** - Experience Fedora bootc firsthand
2. **☁️ Configure Cloud-Init** - Set up automated deployment
3. **🦙 RamaLama Model Management** - Container-native LLM operations

### **Prerequisites Check**
- **Podman** or Docker installed
- **Git, curl, jq** available
- **Python 3.9+** for RamaLama
- **Setup script**: `./scripts/participant-setup.sh`

### **Repository**: `https://github.com/your-repo/fedora-llm-training`

---

## Agenda

1. **Enterprise AI Challenge**
2. **Red Hat's AI Strategy** 
3. **🛠️ Hands-On #1: Build Bootable Container**
4. **Fedora bootc Architecture**
5. **🛠️ Hands-On #2: Cloud-Init Configuration**
6. **RamaLama Integration**
7. **🛠️ Hands-On #3: Model Management**
8. **Production Deployment**
9. **Q&A & Next Steps**

---

## The Enterprise AI Challenge

### Current State of Enterprise AI
- **Vendor Lock-in**: Proprietary cloud AI services
- **Data Privacy**: Models trained on external infrastructure
- **Cost Escalation**: Pay-per-token pricing models
- **Compliance Gaps**: Regulatory requirements unmet

### What Enterprises Need
- **On-premises AI**: Full data control and privacy
- **Cost Predictability**: Fixed infrastructure costs
- **Enterprise Security**: Compliance-ready deployments
- **Open Source**: No vendor dependencies

### Red Hat's Opportunity
- **Trusted Platform**: RHEL + OpenShift foundation
- **Open Source Leadership**: Community-driven innovation
- **Enterprise Support**: Production-ready solutions
- **Hybrid Cloud**: Consistent across environments

---

## Red Hat's Enterprise AI Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Red Hat OpenShift Cluster                │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────┐ │
│  │  RHEL CoreOS    │    │  RHEL CoreOS    │    │   RHEL   │ │
│  │   Worker Node   │    │   Worker Node   │    │  CoreOS  │ │
│  │                 │    │                 │    │          │ │
│  │  ┌───────────┐  │    │  ┌───────────┐  │    │          │ │
│  │  │    LLM    │  │    │  │    LLM    │  │    │          │ │
│  │  │ Inference │  │    │  │ Inference │  │    │          │ │
│  │  │  Server   │  │    │  │  Server   │  │    │          │ │
│  │  └───────────┘  │    │  └───────────┘  │    │          │ │
│  └─────────────────┘    └─────────────────┘    └──────────┘ │
│           │                       │                   │     │
└───────────┼───────────────────────┼───────────────────┼─────┘
            │                       │                   │
            └───────────────────────┼───────────────────┘
                                    │
                       ┌─────────────────┐
                       │   Enterprise    │
                       │  Applications   │
                       │  (REST APIs)    │
                       └─────────────────┘
```

### Development → Production Pipeline
**Fedora** (Innovation) → **CentOS Stream** (Integration) → **RHEL** (Production)

---

## Red Hat Enterprise AI Stack

### Foundation Layer
- **Development**: Fedora 39 (Latest innovations)
- **Production**: RHEL 9 + OpenShift 4.14+
- **Container Runtime**: Podman + CRI-O
- **Orchestration**: OpenShift (Enterprise Kubernetes)

### AI/ML Framework
- **Inference Engine**: RamaLama (container-native LLM runner)
- **Model Format**: GGUF, ONNX, TensorRT
- **API Layer**: OpenAI-compatible endpoints via RamaLama
- **Container Integration**: Podman-native model management
- **Monitoring**: Prometheus + Grafana

### Enterprise Features
- **Security**: SELinux, Pod Security Standards
- **Networking**: OpenShift SDN, Service Mesh
- **Storage**: OpenShift Data Foundation
- **Observability**: OpenShift Logging + Monitoring
- **CI/CD**: OpenShift Pipelines (Tekton)

---

## What are Bootable Containers?

### Fedora bootc Principles

**"Transactional, in-place operating system updates via container images"**

### Traditional Container Model
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

### Bootable Container Model (bootc) On EC2
```
┌─────────────────────────────────┐
│  Container Image = OS + Apps    │
├─────────────────────────────────┤
│        bootc Runtime            │
├─────────────────────────────────┤
│     Amazon EC2 Instance         │
└─────────────────────────────────┘
```

**Container images become the unit of OS deployment and updates**

---

## Bootable Containers: Core Principles

### Fedora bootc Design Philosophy

**🔄 Transactional Updates**
- Atomic filesystem updates via container images
- Rollback to previous image on failure
- No partial update states

**📦 Image-Based OS**
- Container registry as OS distribution mechanism
- Standard container tooling for OS management
- Layered filesystem with copy-on-write

**🔒 Immutable Base**
- Read-only `/usr` filesystem
- Writable `/etc` and `/var` for configuration
- Persistent data in designated locations

**🛡️ Security by Design**
- Minimal base image attack surface
- SELinux enforcing by default
- Signed container images for verification

**🔧 Container-Native Operations**
- `podman` and `buildah` for image management
- Standard OCI container workflows
- Integration with Kubernetes/OpenShift

---

## Fedora bootc for Enterprise AI

### Why bootc for LLM Infrastructure?

**🎯 Purpose-Built for AI Workloads**
- GPU driver integration in base image
- ML/AI libraries as system components
- Optimized for long-running training jobs

**🔄 Rapid Innovation Cycle**
- Latest PyTorch, CUDA, and ML frameworks
- 6-month Fedora release cadence
- Early access to cutting-edge AI tools

**🛤️ Enterprise Migration Path**
```
Development:  Fedora bootc 42
Integration:  CentOS Stream bootc  
Production:   RHEL bootc (future)
```

**🏗️ Container-Native AI Operations**
- Model updates via container images
- GitOps workflows for AI infrastructure
- Kubernetes-native scaling and management

**📊 Operational Benefits**
- Consistent AI environments across dev/prod
- Atomic updates for critical AI systems
- Rollback capability for failed deployments

---

## Enterprise Inference Server Architecture

### Fedora Bootable Container
```dockerfile
FROM quay.io/fedora/fedora-bootc:42

# Install system agents and dependencies
RUN dnf install -y python3 python3-pip gcc systemd openssh-server \
    podman nvidia-container-toolkit && dnf clean all

# Copy unpackaged applications
COPY training/ /opt/llm-training/
COPY scripts/ /opt/scripts/

# Copy configuration files
COPY config/systemd/ /etc/systemd/system/
COPY config/llm-training.conf /etc/llm-training/

# Run configuration scripts
RUN /opt/scripts/setup-llm-environment.sh && \
    systemctl enable llm-training.service
```

### Key Features
- **Bootable**: True bootable container for bare metal/VM deployment
- **Cloud-Native**: Cloud-init integration for EC2 deployment
- **Container-Native LLMs**: RamaLama for Podman-integrated inference
- **System Services**: Systemd integration with LLM services
- **GPU Ready**: NVIDIA drivers and CUDA support
- **Production Ready**: SSH access, logging, monitoring
- **Immutable**: Container-based OS with atomic updates

---

## Bootable Container Implementation

### System Service Integration
```ini
[Unit]
Description=Fedora LLM Training Service
After=network.target gpu.target

[Service]
Type=simple
User=llm-user
WorkingDirectory=/opt/llm-training
Environment=PYTHONPATH=/opt/llm-training
Environment=CUDA_VISIBLE_DEVICES=0
ExecStart=/usr/bin/python3 train.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Deployment Options
- **AWS EC2**: AMI with cloud-init integration
- **Bare Metal**: Direct boot on physical hardware
- **Virtual Machines**: Boot as VM image (qcow2, vmdk)
- **Other Clouds**: Azure VHD, GCP image
- **Container Mode**: Development and testing

### Cloud-Init Integration
- **Instance Configuration**: Automatic EC2 metadata detection
- **User Management**: SSH key injection, user setup
- **GPU Detection**: Automatic GPU configuration for instance types
- **Service Startup**: Automatic LLM training service initialization

---

## RamaLama: Container-Native LLM Runner

### What is RamaLama?
**"The goal of RamaLama is to make AI even more boring"**

- **Container-Native**: Built for Podman/Docker ecosystems
- **Model Management**: Pull, run, and manage LLMs like container images
- **OpenAI Compatible**: Drop-in replacement for OpenAI API
- **Multi-Format**: Supports GGUF, ONNX, and other model formats

### RamaLama Commands
```bash
# Pull and run models like containers
ramalama pull llama2:7b-chat
ramalama serve --port 8080 llama2:7b-chat

# List available models
ramalama list

# Remove models
ramalama rm llama2:7b-chat
```

### Integration Benefits
- **Unified Tooling**: Same commands as Podman containers
- **Registry Support**: Store models in container registries
- **Systemd Integration**: Run as system services
- **Resource Management**: Container-level resource controls

---

## Operational Advantages

### Atomic Updates & Rollbacks
```bash
# Stage new version (no downtime)
bootc switch fedora-llm-bootc:43

# Apply update with reboot
systemctl reboot

# Instant rollback if issues
bootc rollback
systemctl reboot
```

### Immutable Infrastructure Benefits
- **Drift Prevention**: System state always matches image
- **Consistent Environments**: Dev/staging/prod identical
- **Security Hardening**: Read-only root filesystem
- **Simplified Debugging**: Known good state always available

### Container-Native Operations
- **Image Management**: Standard container registry workflows
- **Version Control**: Git-like versioning for OS updates
- **CI/CD Integration**: Automated testing and deployment
- **Multi-Architecture**: x86_64 and ARM64 support

---

## bootc Command Reference

### System Management
```bash
# Check current system status
bootc status

# Show available updates
bootc upgrade --check

# Apply updates (staged, requires reboot)
bootc upgrade

# Switch to different image
bootc switch quay.io/myorg/fedora-llm:v2.0

# Rollback to previous image
bootc rollback
```

### Image Operations
```bash
# Build bootable container
podman build -t fedora-llm-bootc:42 .

# Create disk images
bootc-image-builder --type qcow2 fedora-llm-bootc:42
bootc-image-builder --type ami fedora-llm-bootc:42
bootc-image-builder --type iso fedora-llm-bootc:42

# Push to registry
podman push fedora-llm-bootc:42 quay.io/myorg/fedora-llm:42
```
ENV VLLM_WORKER_MULTIPROC_METHOD=spawn
ENV CUDA_VISIBLE_DEVICES=0
EXPOSE 8000 9090

# Health checks and monitoring
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["python3", "-m", "vllm.entrypoints.openai.api_server"]
```

### Enterprise Features
- **High Performance**: vLLM for optimized inference
- **OpenAI Compatible**: Drop-in API replacement
- **Production Ready**: Health checks, metrics, logging
- **Secure**: Non-root execution, minimal attack surface

---

## OpenShift Deployment Strategy

### OpenShift Operator Pattern
```yaml
apiVersion: ai.redhat.com/v1
kind: LLMInferenceServer
metadata:
  name: enterprise-llm
spec:
  model:
    name: "llama-2-7b-chat"
    format: "gguf"
    source: "registry.redhat.io/models/llama-2-7b"
  
  inference:
    engine: "vllm"
    replicas: 3
    resources:
      gpu: 1
      memory: "16Gi"
  
  networking:
    service:
      type: "ClusterIP"
    route:
      enabled: true
      tls: true
```

### Enterprise Integration
- **GitOps**: ArgoCD-based deployment
- **Security**: Pod Security Standards, NetworkPolicies
- **Monitoring**: Built-in Prometheus metrics
- **Scaling**: Horizontal Pod Autoscaler

---

## Enterprise Model Pipeline

### Model Lifecycle Management
```python
# Enterprise model serving with vLLM
from vllm import LLM, SamplingParams

class EnterpriseInferenceServer:
    def __init__(self, model_path: str):
        self.llm = LLM(
            model=model_path,
            tensor_parallel_size=1,
            gpu_memory_utilization=0.8,
            enforce_eager=True,  # Production stability
        )
        
    def generate(self, prompts: List[str]) -> List[str]:
        sampling_params = SamplingParams(
            temperature=0.1,     # Consistent outputs
            max_tokens=512,
            stop_token_ids=[2],  # EOS token
        )
        return self.llm.generate(prompts, sampling_params)
```

### Production Optimizations
- **Batched Inference**: Higher throughput
- **Memory Management**: Efficient GPU utilization
- **Model Quantization**: INT8/INT4 for cost efficiency
- **Caching**: KV-cache optimization for repeated queries

---

## OpenShift Production Deployment

### Enterprise-Grade Inference Service
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: enterprise-llm-inference
  namespace: ai-workloads
spec:
  replicas: 3
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: llm-server
        image: registry.redhat.io/fedora-llm:latest
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        resources:
          requests:
            nvidia.com/gpu: 1
            memory: "16Gi"
          limits:
            nvidia.com/gpu: 1
            memory: "32Gi"
```

### Enterprise Features
- **Security**: Pod Security Standards, SELinux
- **Observability**: Distributed tracing, metrics
- **High Availability**: Multi-zone deployment
- **Disaster Recovery**: Backup and restore procedures

---

## 🛠️ Hands-On Exercise #1: Build Your First Bootable Container

### **Follow Along: Build Bootable Container**
*Participants: Open your terminals and follow these steps*

```bash
# 1. Clone the repository
git clone https://github.com/your-repo/fedora-llm-training
cd fedora-llm-training

# 2. Build Fedora bootc image
podman build -t fedora-llm-bootc:42 -f containers/Containerfile.fedora-llm .

# 3. Test as regular container (optional)
podman run -it --rm --systemd=always \
  -v $(pwd)/training:/opt/llm-training \
  fedora-llm-bootc:42 /bin/bash

# 4. Check what we built
podman images | grep fedora-llm-bootc
```

**Expected Output**: You should see your bootable container image listed
**Time**: ~5 minutes

### 2. Create Bootable Disk Images
```bash
# Create different bootable formats
sudo podman run --rm --privileged \
  -v $(pwd):/output \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 fedora-llm-bootc:42

# List created images
ls -lh *.qcow2
```

---

## 🛠️ Hands-On Exercise #2: Deploy and Configure Cloud-Init

### **Follow Along: Cloud-Init Configuration**
*Participants: Let's configure cloud-init for your environment*

```bash
# 1. Set your AWS key name
export KEY_NAME="your-aws-key-name"

# 2. Generate cloud-init user data
./scripts/generate-user-data.sh

# 3. Review the generated configuration
cat infrastructure/user-data-generated.yaml

# 4. Test cloud-init locally (simulation)
cloud-init schema --config-file infrastructure/user-data-generated.yaml

# 5. (Optional) Deploy to EC2 if you have AWS access
# ./scripts/deploy-ec2.sh
```

**Expected Output**: Valid cloud-init configuration file
**Time**: ~3 minutes

---

## 🛠️ Hands-On Exercise #3: RamaLama Model Management

### **Follow Along: Container-Native LLM Operations**
*Participants: Experience RamaLama in action*

```bash
# 1. Install RamaLama (if not in container)
pip3 install ramalama

# 2. Pull a small model for testing
ramalama pull tinyllama:1.1b-chat

# 3. List available models
ramalama list

# 4. Start inference server in background
ramalama serve --port 8080 --host 0.0.0.0 tinyllama:1.1b-chat &

# 5. Test the OpenAI-compatible API
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinyllama:1.1b-chat",
    "messages": [{"role": "user", "content": "Hello! Explain bootable containers in one sentence."}],
    "max_tokens": 50
  }' | jq '.choices[0].message.content'

# 6. Clean up
pkill -f ramalama
```

**Expected Output**: AI response about bootable containers
**Time**: ~4 minutes

---

## Results & Benefits

### Bootable Container Advantages
- **50% Faster Deployment**: No OS provisioning overhead
- **99.9% Consistency**: Identical systems across environments
- **Zero Configuration Drift**: Immutable infrastructure
- **Instant Rollbacks**: < 2 minute recovery time

### Enterprise Value Proposition
- **Reduced TCO**: Simplified operations and maintenance
- **Enhanced Security**: Immutable, tamper-resistant systems
- **Faster Innovation**: Rapid deployment of new AI models
- **Risk Mitigation**: Atomic updates with rollback capability

### Red Hat Ecosystem Benefits
- **Future-Proof**: Direct path to RHEL bootc
- **Container-Native**: Unified tooling with OpenShift
- **Open Source**: Community-driven innovation
- **Enterprise Support**: Production-ready foundation

### Technical Advantages
- **Reproducible**: Bit-for-bit identical deployments
- **Portable**: Run anywhere - bare metal, VM, cloud
- **Scalable**: Container registry distribution
- **Observable**: Built-in logging and monitoring

---

## Next Steps & Roadmap

### Phase 1: Bootable Container Foundation (Current)
- ✅ Fedora bootc LLM training system
- ✅ Systemd service integration
- ✅ Immutable infrastructure deployment
- ✅ AWS AMI generation pipeline

### Phase 2: Enterprise Integration (Next 30 days)
- 🔄 OpenShift bootc node support
- 🔄 Multi-architecture builds (x86_64, ARM64)
- 🔄 Signed container images
- 🔄 Advanced monitoring and observability

### Phase 3: Production Hardening (Next 60 days)
- 📋 RHEL bootc migration path
- 📋 Enterprise security compliance
- 📋 Automated testing and validation
- 📋 Disaster recovery procedures

### Phase 4: Ecosystem Expansion (Next 90 days)
- 📋 Edge deployment optimization
- 📋 Multi-cloud bootable images
- 📋 Community contribution and open-sourcing
- 📋 Integration with Red Hat AI portfolio

### Long-term Vision
**Establish bootable containers as the standard for enterprise AI infrastructure**

---

## Questions & Discussion

### Key Discussion Points
1. **Model Selection**: Which LLMs best fit your use case?
2. **Scaling Strategy**: How many agents do you need?
3. **Integration**: How does this fit with existing Red Hat infrastructure?
4. **Timeline**: What's your deployment timeline?

### Technical Deep Dives Available
- Container optimization strategies
- Kubernetes resource management
- GPU utilization patterns
- Cost analysis and optimization

---

## Thank You

### Contact Information
- **Project Repository**: [Your GitHub/GitLab URL]
- **Documentation**: [Your docs URL]
- **Support**: [Your support channel]

### Resources
- Fedora Container Documentation
- Red Hat OpenShift integration guides
- AWS EC2 GPU optimization best practices
- Kubernetes ML/AI deployment patterns

**Ready to build the future of AI with Red Hat technologies on Amazon Infrastructure!**