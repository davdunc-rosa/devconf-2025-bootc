#!/bin/bash

set -e

echo "Setting up Fedora LLM training environment..."

# Create llm-user
useradd -m -s /bin/bash llm-user
usermod -aG wheel llm-user

# Create necessary directories
mkdir -p /var/log/llm-training
mkdir -p /opt/llm-training/results
mkdir -p /opt/llm-training/models
mkdir -p /etc/llm-training

# Set permissions
chown -R llm-user:llm-user /opt/llm-training
chown -R llm-user:llm-user /var/log/llm-training
chmod 755 /opt/llm-training
chmod 755 /var/log/llm-training

# Install Python dependencies
pip3 install --no-cache-dir \
    torch \
    transformers \
    datasets \
    accelerate \
    bitsandbytes \
    peft \
    trl \
    wandb \
    tensorboard \
    jupyter \
    numpy \
    pandas \
    scikit-learn

# Configure SSH for remote access
mkdir -p /home/llm-user/.ssh
chown llm-user:llm-user /home/llm-user/.ssh
chmod 700 /home/llm-user/.ssh

# Set up GPU access for llm-user
usermod -aG video llm-user

# Create startup script
cat > /opt/scripts/start-training.sh << 'EOF'
#!/bin/bash
cd /opt/llm-training
python3 train.py --config /etc/llm-training/llm-training.conf
EOF

chmod +x /opt/scripts/start-training.sh
chown llm-user:llm-user /opt/scripts/start-training.sh

# Set up RamaLama
/opt/scripts/ramalama-setup.sh

echo "LLM environment setup completed successfully"