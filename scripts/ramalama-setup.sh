#!/bin/bash

set -e

echo "Setting up RamaLama for LLM inference..."

# Create RamaLama directories
mkdir -p /opt/llm-training/models
mkdir -p /var/log/ramalama
mkdir -p /etc/ramalama

# Set permissions
chown -R llm-user:llm-user /opt/llm-training/models
chown -R llm-user:llm-user /var/log/ramalama
chmod 755 /opt/llm-training/models
chmod 755 /var/log/ramalama

# Copy configuration
cp /config/ramalama.conf /etc/ramalama/ramalama.conf
chown root:root /etc/ramalama/ramalama.conf
chmod 644 /etc/ramalama/ramalama.conf

# Create RamaLama wrapper script
cat > /usr/local/bin/ramalama-wrapper << 'EOF'
#!/bin/bash

# RamaLama wrapper script for systemd service

CONFIG_FILE="/etc/ramalama/ramalama.conf"
MODEL_STORE="/opt/llm-training/models"
LOG_FILE="/var/log/ramalama/ramalama.log"

# Source configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Set environment variables
export RAMALAMA_STORE="$MODEL_STORE"
export RAMALAMA_LOG_FILE="$LOG_FILE"

# GPU detection
if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
    export RAMALAMA_GPU=true
    echo "GPU detected, enabling GPU acceleration"
else
    export RAMALAMA_GPU=false
    echo "No GPU detected, using CPU inference"
fi

# Execute RamaLama with provided arguments
exec ramalama "$@"
EOF

chmod +x /usr/local/bin/ramalama-wrapper
chown root:root /usr/local/bin/ramalama-wrapper

# Create model management script
cat > /opt/scripts/manage-models.sh << 'EOF'
#!/bin/bash

set -e

RAMALAMA_STORE="/opt/llm-training/models"
export RAMALAMA_STORE

case "$1" in
    "pull")
        if [ -z "$2" ]; then
            echo "Usage: $0 pull <model-name>"
            echo "Examples:"
            echo "  $0 pull llama2:7b-chat"
            echo "  $0 pull codellama:7b-instruct"
            echo "  $0 pull tinyllama:1.1b-chat"
            exit 1
        fi
        echo "Pulling model: $2"
        ramalama pull "$2"
        ;;
    "list")
        echo "Available models:"
        ramalama list
        ;;
    "serve")
        if [ -z "$2" ]; then
            echo "Usage: $0 serve <model-name> [port]"
            exit 1
        fi
        PORT=${3:-8080}
        echo "Starting inference server for model: $2 on port: $PORT"
        ramalama serve --port "$PORT" --host 0.0.0.0 "$2"
        ;;
    "remove")
        if [ -z "$2" ]; then
            echo "Usage: $0 remove <model-name>"
            exit 1
        fi
        echo "Removing model: $2"
        ramalama rm "$2"
        ;;
    *)
        echo "Usage: $0 {pull|list|serve|remove} [args...]"
        echo ""
        echo "Commands:"
        echo "  pull <model>     - Download a model"
        echo "  list             - List available models"
        echo "  serve <model>    - Start inference server"
        echo "  remove <model>   - Remove a model"
        echo ""
        echo "Examples:"
        echo "  $0 pull llama2:7b-chat"
        echo "  $0 serve llama2:7b-chat 8080"
        echo "  $0 list"
        exit 1
        ;;
esac
EOF

chmod +x /opt/scripts/manage-models.sh
chown llm-user:llm-user /opt/scripts/manage-models.sh

echo "RamaLama setup completed successfully"