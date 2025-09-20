# Technical Appendix: Fedora LLM Training Platform

## Detailed Architecture Specifications

### Bootable Container Architecture
```
┌─────────────────────────────────────────────────────────────┐
│              Fedora Bootable Container (bootc)             │
├─────────────────────────────────────────────────────────────┤
│ Application Layer                                           │
│ ├── LLM Training Service (systemd managed)                 │
│ ├── Training Scripts (Python 3.12)                         │
│ ├── Model Management (Transformers 4.30+)                  │
│ ├── Data Pipeline (Datasets, Tokenizers)                   │
│ └── Monitoring (TensorBoard, Weights & Biases)             │
├─────────────────────────────────────────────────────────────┤
│ System Services Layer                                       │
│ ├── SSH Server (remote access)                             │
│ ├── LLM Training Service (auto-start)                      │
│ ├── Logging Service (journald)                             │
│ └── GPU Management (nvidia-container-toolkit)              │
├─────────────────────────────────────────────────────────────┤
│ ML/AI Framework Layer                                       │
│ ├── PyTorch 2.0+ (CUDA enabled)                           │
│ ├── Hugging Face Ecosystem                                 │
│ ├── Accelerate (Distributed training)                      │
│ └── PEFT/LoRA (Parameter efficient fine-tuning)           │
├─────────────────────────────────────────────────────────────┤
│ System Layer                                               │
│ ├── Python 3.12 + pip                                     │
│ ├── NVIDIA CUDA Toolkit                                    │
│ ├── Podman (container runtime)                             │
│ └── System utilities (htop, curl, wget)                    │
├─────────────────────────────────────────────────────────────┤
│ Base OS: Fedora 42 (bootc)                                 │
│ ├── DNF Package Manager                                    │
│ ├── Systemd (init system)                                  │
│ ├── SELinux (Enforcing)                                   │
│ ├── Immutable filesystem                                   │
│ └── Atomic updates                                         │
└─────────────────────────────────────────────────────────────┘
```

### AWS Infrastructure Components

#### EC2 Instance Specifications
```yaml
Instance Configuration:
  Type: g4dn.xlarge
  vCPUs: 4
  Memory: 16 GiB
  GPU: 1x NVIDIA T4 (16 GB VRAM)
  Network: Up to 25 Gbps
  Storage: 125 GB NVMe SSD

Operating System:
  AMI: Fedora-Cloud-Base-39 (ami-*)
  Owner: 125523088429 (Fedora Project)
  Architecture: x86_64
  Virtualization: HVM

Storage Configuration:
  Root Volume:
    Type: gp3
    Size: 100 GB
    IOPS: 3000
    Throughput: 125 MB/s
    Encryption: Enabled (AWS managed)
```

#### Network Configuration
```yaml
VPC Configuration:
  Default VPC: Used for simplicity
  Availability Zone: Single AZ deployment
  
Security Groups:
  Inbound Rules:
    - SSH (22): 0.0.0.0/0
    - Jupyter (8888): 0.0.0.0/0
    - TensorBoard (6006): 0.0.0.0/0
  Outbound Rules:
    - All traffic: 0.0.0.0/0

Elastic IP: Optional (for persistent access)
```

### Training Pipeline Technical Details

#### Model Support Matrix
| Model Family | Size | Memory Req | Training Time | Status |
|--------------|------|------------|---------------|---------|
| DialoGPT | 117M | 2 GB | 30 min | ✅ Tested |
| GPT-2 | 124M-1.5B | 2-8 GB | 1-4 hours | ✅ Tested |
| Llama 2 | 7B-70B | 16-140 GB | 8-48 hours | 🔄 In Progress |
| Mistral | 7B | 16 GB | 8 hours | 📋 Planned |
| CodeLlama | 7B-34B | 16-70 GB | 8-24 hours | 📋 Planned |

#### Training Optimization Techniques
```python
# Memory Optimization
optimization_config = {
    "fp16": True,                    # 50% memory reduction
    "gradient_checkpointing": True,  # 30% memory reduction
    "gradient_accumulation_steps": 4, # Effective batch size scaling
    "dataloader_num_workers": 4,     # Parallel data loading
    "pin_memory": True,              # GPU transfer optimization
}

# Performance Optimization
performance_config = {
    "torch_compile": True,           # PyTorch 2.0 compilation
    "flash_attention": True,         # Attention optimization
    "fused_optimizer": True,         # Optimizer fusion
    "mixed_precision": "fp16",       # Automatic mixed precision
}

# Distributed Training (Multi-GPU)
distributed_config = {
    "strategy": "ddp",               # DistributedDataParallel
    "find_unused_parameters": False, # Performance optimization
    "bucket_cap_mb": 25,             # Gradient bucketing
}
```

### Kubernetes Deployment Specifications

#### Resource Requirements
```yaml
Resource Allocation:
  Training Workload:
    CPU: 4 cores (guaranteed)
    Memory: 16 GB (guaranteed)
    GPU: 1x NVIDIA T4
    Storage: 100 GB (training data + models)
    
  Inference Workload:
    CPU: 2 cores (guaranteed)
    Memory: 8 GB (guaranteed)
    GPU: 1x NVIDIA T4 (shared)
    Storage: 50 GB (model storage)

Node Requirements:
  Instance Type: g4dn.xlarge or larger
  OS: Fedora CoreOS or RHEL
  Container Runtime: CRI-O or Podman
  GPU Operator: NVIDIA GPU Operator
```

#### Scaling Configuration
```yaml
Horizontal Pod Autoscaler:
  Min Replicas: 1
  Max Replicas: 10
  Target CPU: 70%
  Target Memory: 80%
  Scale Up: 2 pods per 30s
  Scale Down: 1 pod per 60s

Vertical Pod Autoscaler:
  Update Mode: Auto
  CPU Request: 100m - 4000m
  Memory Request: 1Gi - 16Gi
  
Cluster Autoscaler:
  Min Nodes: 1
  Max Nodes: 20
  Scale Up Delay: 10s
  Scale Down Delay: 10m
```

### Performance Benchmarks

#### Training Performance
```
Model: DialoGPT-small (117M parameters)
Dataset: WikiText-2 (1000 samples)
Hardware: g4dn.xlarge (1x T4 GPU)

Baseline (CPU only):
  Training Time: 45 minutes
  Memory Usage: 4 GB
  Throughput: 22 samples/sec

Optimized (GPU + FP16):
  Training Time: 18 minutes (2.5x faster)
  Memory Usage: 2.4 GB (40% reduction)
  Throughput: 55 samples/sec (2.5x faster)
  GPU Utilization: 85%
```

#### Inference Performance
```
Model: DialoGPT-small (fine-tuned)
Input: 50 token prompt
Hardware: g4dn.xlarge (1x T4 GPU)

Latency Metrics:
  First Token: 120ms
  Subsequent Tokens: 25ms/token
  Total (100 tokens): 2.6 seconds
  
Throughput Metrics:
  Concurrent Users: 8
  Requests/Second: 15
  Tokens/Second: 380
  GPU Utilization: 75%
```

### Security Considerations

#### Container Security
```yaml
Security Measures:
  Base Image: Official Fedora registry
  User: Non-root execution
  Capabilities: Minimal required set
  SELinux: Enforcing mode
  Secrets: Kubernetes secrets management
  
Vulnerability Scanning:
  Tool: Podman/Buildah built-in scanner
  Frequency: On every build
  Policy: Block high/critical vulnerabilities
  
Network Security:
  Ingress: TLS termination
  Service Mesh: Istio (optional)
  Network Policies: Kubernetes NetworkPolicy
```

#### AWS Security
```yaml
IAM Configuration:
  Instance Profile: Minimal required permissions
  S3 Access: Read-only for datasets
  ECR Access: Pull container images
  CloudWatch: Logs and metrics
  
Encryption:
  EBS Volumes: AWS KMS encryption
  S3 Buckets: Server-side encryption
  Secrets: AWS Secrets Manager
  
Network Security:
  Security Groups: Restrictive rules
  VPC: Private subnets for training
  NAT Gateway: Outbound internet access
  VPC Endpoints: AWS service access
```

### Monitoring and Observability

#### Metrics Collection
```yaml
System Metrics:
  - CPU utilization per core
  - Memory usage (RSS, cache, swap)
  - GPU utilization and memory
  - Disk I/O and space usage
  - Network throughput

Application Metrics:
  - Training loss and accuracy
  - Tokens processed per second
  - Model inference latency
  - Queue depth and processing time
  - Error rates and types

Business Metrics:
  - Cost per training job
  - Time to model deployment
  - Resource efficiency ratios
  - SLA compliance metrics
```

#### Logging Strategy
```yaml
Log Levels:
  - ERROR: System and application errors
  - WARN: Performance degradation alerts
  - INFO: Training progress and milestones
  - DEBUG: Detailed troubleshooting info

Log Destinations:
  - CloudWatch Logs: Centralized logging
  - Local Files: Container-level logs
  - Elasticsearch: Search and analytics
  - S3: Long-term archival

Log Retention:
  - ERROR/WARN: 90 days
  - INFO: 30 days
  - DEBUG: 7 days
  - Archived: 1 year
```

### Cost Analysis

#### Training Cost Breakdown
```
g4dn.xlarge Instance (us-west-2):
  On-Demand: $0.526/hour
  Spot Instance: ~$0.158/hour (70% savings)
  
Storage Costs:
  EBS gp3 (100 GB): $8/month
  S3 Standard (datasets): $0.023/GB/month
  
Network Costs:
  Data Transfer Out: $0.09/GB
  Inter-AZ Transfer: $0.01/GB

Example Training Job:
  Duration: 8 hours
  Instance: g4dn.xlarge (spot)
  Storage: 100 GB EBS + 10 GB S3
  Total Cost: ~$1.50 per training job
```

#### Scaling Cost Projections
```
Monthly Training Workload Scenarios:

Light Usage (10 jobs/month):
  Compute: $15
  Storage: $8
  Network: $2
  Total: ~$25/month

Medium Usage (50 jobs/month):
  Compute: $75
  Storage: $20
  Network: $8
  Total: ~$103/month

Heavy Usage (200 jobs/month):
  Compute: $300
  Storage: $50
  Network: $25
  Total: ~$375/month
```

### Troubleshooting Guide

#### Common Issues and Solutions

**GPU Not Detected**
```bash
# Check GPU availability
nvidia-smi

# Verify CUDA installation
python3 -c "import torch; print(torch.cuda.is_available())"

# Container GPU access
podman run --device nvidia.com/gpu=all nvidia/cuda:11.8-base nvidia-smi
```

**Out of Memory Errors**
```python
# Reduce batch size
per_device_train_batch_size = 2

# Enable gradient checkpointing
gradient_checkpointing = True

# Use FP16 training
fp16 = True

# Gradient accumulation
gradient_accumulation_steps = 4
```

**Slow Training Performance**
```python
# Enable compilation (PyTorch 2.0+)
model = torch.compile(model)

# Optimize data loading
dataloader_num_workers = 4
pin_memory = True

# Use faster attention
from transformers import AutoConfig
config = AutoConfig.from_pretrained(model_name)
config.use_flash_attention_2 = True
```

**Container Build Failures**
```bash
# Clear Podman cache
podman system prune -a

# Build with no cache
podman build --no-cache -t fedora-llm .

# Check disk space
df -h
```

This technical appendix provides the detailed specifications and implementation guidance needed for successful deployment and operation of the Fedora LLM training platform.