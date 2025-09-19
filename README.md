# Fedora LLM Training on AWS EC2

A project for training LLM models using Fedora bootable containers on Amazon EC2 instances, designed to support Red Hat partnership initiatives.

## Project Overview

- **Base OS**: Fedora (no Amazon Linux components)
- **Container Runtime**: Podman/Docker on Fedora
- **Target Platform**: Amazon EC2
- **Goal**: Train local LLM agents for Kubernetes deployment

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EC2 Instance  │    │   EC2 Instance  │    │   EC2 Instance  │
│   Fedora Boot   │    │   Fedora Boot   │    │   Fedora Boot   │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │ LLM Agent │  │    │  │ LLM Agent │  │    │  │ LLM Agent │  │
│  │Container  │  │    │  │Container  │  │    │  │Container  │  │
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

1. Set up Fedora bootable containers for EC2
2. Configure training environment
3. Deploy LLM training workloads
4. Set up Kubernetes cluster integration

## Components

- `/infrastructure/` - Terraform/CloudFormation for EC2 setup
- `/containers/` - Fedora container definitions
- `/training/` - LLM training scripts and configurations
- `/kubernetes/` - K8s manifests and cluster setup