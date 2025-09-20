# DevConf.us Hands-On Guide: Fedora Bootable Containers for Enterprise AI

## Prerequisites

### Required Software
- **Podman** (or Docker) - Container runtime
- **Git** - Version control
- **curl** and **jq** - API testing tools
- **Python 3.9+** - For RamaLama installation

### Optional (for full experience)
- **AWS CLI** - For cloud deployment
- **cloud-init** - For testing cloud-init configurations
- **QEMU** - For testing bootable images locally

### Quick Setup
```bash
# Fedora/RHEL
sudo dnf install -y podman git curl jq python3 python3-pip

# Ubuntu/Debian
sudo apt update && sudo apt install -y podman git curl jq python3 python3-pip

# macOS
brew install podman git curl jq python3
```

---

## 🛠️ Exercise #1: Build Your First Bootable Container

### Objective
Build a Fedora bootc container that includes LLM training capabilities and system services.

### Steps

#### 1. Get the Code
```bash
# Clone the repository
git clone https://github.com/your-repo/fedora-llm-training
cd fedora-llm-training

# Explore the structure
ls -la
tree -L 2  # if tree is installed
```

#### 2. Examine the Containerfile
```bash
# Look at the bootc Containerfile
cat containers/Containerfile.fedora-llm

# Key things to notice:
# - FROM quay.io/fedora/fedora-bootc:42
# - System packages + cloud-init
# - Python ML libraries + RamaLama
# - Systemd service configuration
# - Configuration file copying
```

#### 3. Build the Container
```bash
# Build the bootable container
podman build -t fedora-llm-bootc:42 -f containers/Containerfile.fedora-llm .

# This will take 3-5 minutes depending on your connection
# Watch for successful completion
```

#### 4. Verify the Build
```bash
# Check the image was created
podman images | grep fedora-llm-bootc

# Inspect the image
podman inspect fedora-llm-bootc:42 | jq '.[] | {Id, Created, Size}'

# Test run (optional - requires systemd support)
podman run -it --rm --systemd=always fedora-llm-bootc:42 /bin/bash
# Inside container: systemctl status
# Exit with: exit
```

### Expected Results
- ✅ Container image `fedora-llm-bootc:42` appears in `podman images`
- ✅ Image size approximately 2-3 GB
- ✅ Container runs successfully with systemd

### Troubleshooting
- **Build fails**: Check internet connection, try `podman system prune -a`
- **Permission denied**: Ensure user is in `podman` group or use `sudo`
- **Out of space**: Clean up with `podman system prune -a --volumes`

---

## 🛠️ Exercise #2: Cloud-Init Configuration

### Objective
Configure cloud-init for automated EC2 deployment with proper user setup and service initialization.

### Steps

#### 1. Set Up Your Environment
```bash
# Set your AWS key name (replace with your actual key)
export KEY_NAME="your-aws-key-name"
export PROJECT_NAME="fedora-llm-training"

# Verify environment
echo "Key: $KEY_NAME, Project: $PROJECT_NAME"
```

#### 2. Generate Cloud-Init Configuration
```bash
# Generate user data for your environment
./scripts/generate-user-data.sh

# This creates infrastructure/user-data-generated.yaml
```

#### 3. Examine the Configuration
```bash
# Look at the generated cloud-init file
cat infrastructure/user-data-generated.yaml

# Key sections to notice:
# - User configuration with SSH keys
# - Package installation
# - File creation (configs, scripts)
# - Command execution (runcmd)
# - Final message
```

#### 4. Validate Cloud-Init (if available)
```bash
# Install cloud-init for validation (optional)
# Fedora: sudo dnf install -y cloud-init
# Ubuntu: sudo apt install -y cloud-init

# Validate the configuration
cloud-init schema --config-file infrastructure/user-data-generated.yaml

# Should show: Valid cloud-config
```

#### 5. Simulate Cloud-Init Execution
```bash
# Create a test directory
mkdir -p /tmp/cloud-init-test
cd /tmp/cloud-init-test

# Extract and examine the setup script
grep -A 50 "path: /opt/scripts/ec2-setup.sh" ../fedora-llm-training/infrastructure/user-data-generated.yaml

# This shows what would run on instance boot
```

### Expected Results
- ✅ `user-data-generated.yaml` file created
- ✅ Cloud-init validation passes (if cloud-init installed)
- ✅ Configuration includes your SSH key and project settings

### Troubleshooting
- **SSH key not found**: Ensure `~/.ssh/$KEY_NAME.pub` exists
- **Permission denied**: Check file permissions on SSH key
- **Validation fails**: Check YAML syntax with `yamllint` or online validator

---

## 🛠️ Exercise #3: RamaLama Model Management

### Objective
Experience container-native LLM management with RamaLama, including model pulling, serving, and API interaction.

### Steps

#### 1. Install RamaLama
```bash
# Install RamaLama
pip3 install --user ramalama

# Add to PATH if needed
export PATH=$PATH:~/.local/bin

# Verify installation
ramalama --version
```

#### 2. Pull a Model
```bash
# Pull a small model for testing (600MB download)
ramalama pull tinyllama:1.1b-chat

# Monitor the download progress
# This will take 2-3 minutes depending on connection
```

#### 3. Explore Model Management
```bash
# List downloaded models
ramalama list

# Get model information
ramalama info tinyllama:1.1b-chat

# Check storage location
ls -la ~/.local/share/ramalama/
```

#### 4. Start Inference Server
```bash
# Start the inference server
ramalama serve --port 8080 --host 0.0.0.0 tinyllama:1.1b-chat &

# Wait for server to start (10-15 seconds)
sleep 15

# Check if server is running
curl -s http://localhost:8080/v1/models | jq '.'
```

#### 5. Test OpenAI-Compatible API
```bash
# Test chat completions
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinyllama:1.1b-chat",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Explain bootable containers in one sentence."}
    ],
    "max_tokens": 50,
    "temperature": 0.7
  }' | jq -r '.choices[0].message.content'

# Test text completion
curl -X POST http://localhost:8080/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinyllama:1.1b-chat",
    "prompt": "The main benefit of using Fedora bootc is",
    "max_tokens": 30
  }' | jq -r '.choices[0].text'
```

#### 6. Monitor and Manage
```bash
# Check server logs (if running in background)
jobs
# Should show ramalama job

# Get server statistics
curl -s http://localhost:8080/v1/models/tinyllama:1.1b-chat | jq '.'

# Stop the server
pkill -f ramalama
# Or bring to foreground with fg and Ctrl+C
```

#### 7. Clean Up
```bash
# Remove the model (optional)
ramalama rm tinyllama:1.1b-chat

# Verify removal
ramalama list
```

### Expected Results
- ✅ RamaLama successfully installed and working
- ✅ Model downloaded and listed in `ramalama list`
- ✅ Inference server responds to API calls
- ✅ AI generates responses about bootable containers

### Troubleshooting
- **Installation fails**: Try `pip3 install --user --upgrade ramalama`
- **Model download fails**: Check internet connection and disk space
- **Server won't start**: Check port 8080 isn't in use: `netstat -tlnp | grep 8080`
- **API calls fail**: Ensure server is running: `curl http://localhost:8080/health`
- **Permission denied**: Ensure user has write access to `~/.local/share/`

---

## 🎯 Bonus Challenges

### Challenge 1: Custom Model
Try pulling and serving a different model:
```bash
ramalama pull codellama:7b-instruct
ramalama serve --port 8081 codellama:7b-instruct
```

### Challenge 2: Bootable Image Creation
If you have sufficient privileges:
```bash
sudo podman run --rm --privileged \
  -v $(pwd):/output \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 fedora-llm-bootc:42
```

### Challenge 3: Multi-Model Setup
Run multiple models simultaneously on different ports and compare responses.

---

## 📚 Additional Resources

### Documentation
- [Fedora bootc Documentation](https://docs.fedoraproject.org/en-US/bootc/)
- [RamaLama GitHub](https://github.com/containers/ramalama)
- [Podman Documentation](https://docs.podman.io/)
- [Cloud-Init Documentation](https://cloud-init.readthedocs.io/)

### Community
- **Fedora Discussion**: https://discussion.fedoraproject.org/
- **Containers Community**: https://github.com/containers
- **Red Hat Developer**: https://developers.redhat.com/

### Next Steps
- Explore the full project repository
- Try deploying to AWS EC2 (if you have access)
- Experiment with different LLM models
- Contribute improvements back to the project

---

## 🤝 Getting Help

During the presentation:
1. **Raise your hand** for immediate assistance
2. **Check with neighbors** - collaborative learning encouraged
3. **Use the chat** for questions that can wait
4. **Take notes** of any issues for Q&A session

Post-presentation:
- **GitHub Issues**: Report bugs or request features
- **Community Forums**: Ask questions and share experiences
- **Social Media**: Tag @fedora and @containers for visibility

**Happy hacking with Fedora bootc and RamaLama!** 🚀