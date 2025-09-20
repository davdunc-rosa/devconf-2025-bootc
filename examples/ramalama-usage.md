# RamaLama Usage Examples

## Basic Model Management

### Pull Models
```bash
# Pull popular chat models
ramalama pull llama2:7b-chat
ramalama pull codellama:7b-instruct
ramalama pull tinyllama:1.1b-chat

# Pull specific model versions
ramalama pull llama2:13b-chat-q4_0
ramalama pull mistral:7b-instruct-v0.1
```

### List Available Models
```bash
# List all downloaded models
ramalama list

# Example output:
# REPOSITORY          TAG                 MODEL ID     CREATED       SIZE
# llama2              7b-chat            abc123def    2 hours ago   3.8GB
# codellama           7b-instruct        def456ghi    1 hour ago    3.8GB
# tinyllama           1.1b-chat          ghi789jkl    30 min ago    637MB
```

### Serve Models
```bash
# Start inference server
ramalama serve --port 8080 --host 0.0.0.0 llama2:7b-chat

# With custom parameters
ramalama serve \
  --port 8080 \
  --host 0.0.0.0 \
  --ctx-size 4096 \
  --threads 4 \
  --gpu-layers 32 \
  llama2:7b-chat
```

## OpenAI-Compatible API Usage

### Chat Completions
```bash
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2:7b-chat",
    "messages": [
      {"role": "system", "content": "You are a helpful AI assistant."},
      {"role": "user", "content": "Explain containerization in simple terms."}
    ],
    "max_tokens": 150,
    "temperature": 0.7
  }'
```

### Text Completions
```bash
curl -X POST http://localhost:8080/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2:7b-chat",
    "prompt": "The benefits of using bootable containers are:",
    "max_tokens": 100,
    "temperature": 0.5
  }'
```

### Model Information
```bash
# List available models via API
curl http://localhost:8080/v1/models

# Get model details
curl http://localhost:8080/v1/models/llama2:7b-chat
```

## Systemd Service Management

### Service Control
```bash
# Check service status
systemctl status ramalama-inference.service

# Start/stop service
systemctl start ramalama-inference.service
systemctl stop ramalama-inference.service

# Enable/disable auto-start
systemctl enable ramalama-inference.service
systemctl disable ramalama-inference.service

# View logs
journalctl -u ramalama-inference.service -f
```

### Service Configuration
```bash
# Edit service configuration
systemctl edit ramalama-inference.service

# Reload after changes
systemctl daemon-reload
systemctl restart ramalama-inference.service
```

## Advanced Usage

### Custom Model Serving
```bash
# Serve with custom configuration
ramalama serve \
  --port 8080 \
  --host 0.0.0.0 \
  --ctx-size 8192 \
  --batch-size 512 \
  --threads $(nproc) \
  --gpu-layers -1 \
  --mlock \
  llama2:13b-chat
```

### Multiple Model Instances
```bash
# Serve different models on different ports
ramalama serve --port 8080 llama2:7b-chat &
ramalama serve --port 8081 codellama:7b-instruct &
ramalama serve --port 8082 tinyllama:1.1b-chat &
```

### Model Registry Integration
```bash
# Push model to registry (if supported)
ramalama tag llama2:7b-chat registry.example.com/models/llama2:7b-chat
ramalama push registry.example.com/models/llama2:7b-chat

# Pull from registry
ramalama pull registry.example.com/models/llama2:7b-chat
```

## Integration with Training Pipeline

### Model Evaluation
```python
import requests
import json

def evaluate_model(prompt, model_endpoint="http://localhost:8080"):
    """Evaluate model response via RamaLama API"""
    
    response = requests.post(
        f"{model_endpoint}/v1/chat/completions",
        headers={"Content-Type": "application/json"},
        json={
            "model": "llama2:7b-chat",
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 150,
            "temperature": 0.1
        }
    )
    
    return response.json()

# Example usage
result = evaluate_model("What is machine learning?")
print(result["choices"][0]["message"]["content"])
```

### Automated Testing
```bash
#!/bin/bash
# Test script for model inference

MODEL_ENDPOINT="http://localhost:8080"
TEST_PROMPTS=(
    "Hello, how are you?"
    "Explain quantum computing"
    "Write a Python function to sort a list"
)

for prompt in "${TEST_PROMPTS[@]}"; do
    echo "Testing prompt: $prompt"
    
    response=$(curl -s -X POST "$MODEL_ENDPOINT/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"llama2:7b-chat\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
            \"max_tokens\": 50
        }")
    
    echo "Response: $(echo "$response" | jq -r '.choices[0].message.content')"
    echo "---"
done
```

## Monitoring and Observability

### Health Checks
```bash
# Simple health check
curl -f http://localhost:8080/health || echo "Service unhealthy"

# Detailed status
curl http://localhost:8080/v1/models | jq '.'
```

### Performance Monitoring
```bash
# Monitor resource usage
watch -n 1 'ps aux | grep ramalama'
watch -n 1 'nvidia-smi'

# Monitor API response times
time curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "llama2:7b-chat", "messages": [{"role": "user", "content": "Hi"}]}'
```

## Troubleshooting

### Common Issues

#### Model Not Loading
```bash
# Check model exists
ramalama list | grep llama2

# Check disk space
df -h /opt/llm-training/models

# Check service logs
journalctl -u ramalama-inference.service --no-pager
```

#### GPU Not Detected
```bash
# Verify GPU availability
nvidia-smi

# Check CUDA installation
nvidia-container-cli info

# Test GPU access in container
podman run --rm --device nvidia.com/gpu=all nvidia/cuda:11.8-base nvidia-smi
```

#### API Connection Issues
```bash
# Check service is running
systemctl status ramalama-inference.service

# Check port binding
netstat -tlnp | grep 8080

# Test local connection
curl -v http://localhost:8080/v1/models
```

This comprehensive guide shows how RamaLama integrates seamlessly with our Fedora bootc container, providing a container-native approach to LLM deployment and management.