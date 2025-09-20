#!/bin/bash

set -e

# Configuration
KEY_NAME=${KEY_NAME:-""}
PROJECT_NAME=${PROJECT_NAME:-"fedora-llm-training"}
SSH_PUBLIC_KEY_PATH=${SSH_PUBLIC_KEY_PATH:-"~/.ssh/${KEY_NAME}.pub"}

if [ -z "$KEY_NAME" ]; then
    echo "Error: Please set KEY_NAME environment variable"
    echo "Usage: KEY_NAME=your-key-name ./scripts/generate-user-data.sh"
    exit 1
fi

# Expand tilde in path
SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH/#\~/$HOME}"

if [ ! -f "$SSH_PUBLIC_KEY_PATH" ]; then
    echo "Error: SSH public key not found at $SSH_PUBLIC_KEY_PATH"
    echo "Please ensure your SSH public key exists or set SSH_PUBLIC_KEY_PATH"
    exit 1
fi

echo "Generating cloud-init user data..."
echo "Project: $PROJECT_NAME"
echo "SSH Key: $SSH_PUBLIC_KEY_PATH"

# Read SSH public key
SSH_PUBLIC_KEY=$(cat "$SSH_PUBLIC_KEY_PATH")

# Generate user data from template
cat > infrastructure/user-data-generated.yaml << EOF
#cloud-config
# Generated Fedora LLM Training EC2 Instance Cloud-Init

hostname: ${PROJECT_NAME}-instance
fqdn: ${PROJECT_NAME}-instance.ec2.internal

# User configuration
users:
  - name: fedora
    gecos: Fedora Cloud User
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: wheel,adm,systemd-journal
    shell: /bin/bash
    lock_passwd: true
    ssh_authorized_keys:
      - ${SSH_PUBLIC_KEY}

# System updates
package_update: true
package_upgrade: false

# Additional packages for EC2
packages:
  - awscli
  - ec2-instance-utils
  - htop
  - tmux

# Disk configuration
growpart:
  mode: auto
  devices: ['/']

# Write EC2-specific configuration
write_files:
  - path: /etc/llm-training/ec2-config.conf
    content: |
      # EC2 Instance Configuration
      CLOUD_PROVIDER=aws
      INSTANCE_METADATA_URL=http://169.254.169.254/latest/meta-data/
      PROJECT_NAME=${PROJECT_NAME}
      
      # Training configuration
      TRAINING_ENABLED=true
      AUTO_START_TRAINING=true
      GPU_ENABLED=true
      
      # Logging
      LOG_TO_CLOUDWATCH=false
      LOG_LEVEL=INFO
    permissions: '0644'
    owner: root:root

  - path: /opt/scripts/ec2-setup.sh
    content: |
      #!/bin/bash
      set -e
      
      echo "Starting EC2-specific setup for ${PROJECT_NAME}..."
      
      # Get instance metadata
      INSTANCE_ID=\$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
      INSTANCE_TYPE=\$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
      AZ=\$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
      REGION=\${AZ%?}
      PUBLIC_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
      
      echo "Instance ID: \$INSTANCE_ID"
      echo "Instance Type: \$INSTANCE_TYPE"
      echo "Availability Zone: \$AZ"
      echo "Region: \$REGION"
      echo "Public IP: \$PUBLIC_IP"
      
      # Update instance configuration
      cat >> /etc/llm-training/ec2-config.conf << EOFCONF
      INSTANCE_ID=\$INSTANCE_ID
      INSTANCE_TYPE=\$INSTANCE_TYPE
      AVAILABILITY_ZONE=\$AZ
      REGION=\$REGION
      PUBLIC_IP=\$PUBLIC_IP
      EOFCONF
      
      # Configure GPU if available
      if [[ "\$INSTANCE_TYPE" == g* ]] || [[ "\$INSTANCE_TYPE" == p* ]]; then
          echo "GPU instance detected: \$INSTANCE_TYPE"
          
          if lspci | grep -i nvidia; then
              echo "NVIDIA GPU found, configuring..."
              usermod -aG video llm-user
              
              if command -v nvidia-smi &> /dev/null; then
                  nvidia-smi
              fi
          fi
      fi
      
      # Set up training directories
      mkdir -p /opt/llm-training/{logs,models,data,checkpoints}
      chown -R llm-user:llm-user /opt/llm-training
      
      # Start training service
      if systemctl is-enabled llm-training.service &> /dev/null; then
          echo "Starting LLM training service..."
          systemctl start llm-training.service
          sleep 5
          systemctl status llm-training.service
      fi
      
      echo "EC2 setup completed successfully"
    permissions: '0755'
    owner: root:root

# Run commands
runcmd:
  - /opt/scripts/ec2-setup.sh
  - echo "${PROJECT_NAME} instance ready" > /var/log/setup-complete.log

# Final message
final_message: |
  ${PROJECT_NAME} EC2 instance is ready!
  
  Connect via SSH:
  ssh -i ~/.ssh/${KEY_NAME}.pem fedora@\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
  
  View training logs:
  journalctl -u llm-training.service -f
EOF

echo "User data generated: infrastructure/user-data-generated.yaml"
echo ""
echo "To deploy with this user data:"
echo "  export KEY_NAME=$KEY_NAME"
echo "  ./scripts/deploy-ec2.sh"