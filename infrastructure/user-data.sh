#!/bin/bash

# Update system
dnf update -y

# Install Docker/Podman and development tools
dnf install -y \
    podman \
    podman-compose \
    git \
    wget \
    curl \
    vim \
    htop \
    python3 \
    python3-pip

# Enable and start podman socket
systemctl --user enable podman.socket
systemctl --user start podman.socket

# Install NVIDIA drivers for GPU instances
if lspci | grep -i nvidia; then
    dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    # Add nvidia container runtime
    dnf install -y nvidia-container-toolkit
fi

# Create project directory
mkdir -p /home/fedora/llm-training
chown fedora:fedora /home/fedora/llm-training

# Clone project repository (if available)
# git clone <your-repo-url> /home/fedora/llm-training

# Set up environment for fedora user
cat >> /home/fedora/.bashrc << 'EOF'
export PATH=$PATH:/home/fedora/.local/bin
export PYTHONPATH=/home/fedora/llm-training
alias ll='ls -la'
alias la='ls -A'
EOF

# Create a simple status script
cat > /home/fedora/status.sh << 'EOF'
#!/bin/bash
echo "=== Fedora LLM Training Instance Status ==="
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo "Memory: $(free -h | grep Mem)"
echo "Disk: $(df -h / | tail -1)"
echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'No GPU detected')"
echo "Podman: $(podman --version)"
echo "Python: $(python3 --version)"
EOF

chmod +x /home/fedora/status.sh
chown fedora:fedora /home/fedora/status.sh

# Log completion
echo "$(date): Fedora LLM training instance setup completed" >> /var/log/user-data.log