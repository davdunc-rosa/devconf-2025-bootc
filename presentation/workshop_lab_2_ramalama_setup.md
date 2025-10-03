**Workshop Lab 2: RamaLama AI Model Management**

_Texas Linux Festival 2025 - Hands-on Lab (AlmaLinux Container Edition)_

**Lab Overview**

**Time Required:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Completed Workshop Lab 1 (Podman Setup)

**What You'll Learn:**

- Install RamaLama **inside your AlmaLinux container**
- Download and manage AI models securely in containerized environment
- Run interactive AI chat sessions within container isolation
- Create REST API services accessible from host
- Understand container-based AI model deployment

**What You'll Build:**

- RamaLama installation in your AlmaLinux development container
- Containerized AI model repository with persistent storage
- Container-to-host networking for AI services
- Secure, isolated AI development environment

**Lab Prerequisites Check**

**Before starting, verify Lab 1 completion from your HOST system:**

\# Run these on your HOST (not in container)  
cd ~/txlf-workshop  
./scripts/workshop-ctl.sh status  
curl -s <http://localhost:8080> | grep -i welcome  
podman pod ps | grep txlf-workshop-pod  

**If any commands fail, complete Workshop Lab 1 first!**

**Section 1: Accessing Your AlmaLinux Container Environment**

**Step 1.1: Start and Access Your Container**

**From your HOST system:**

\# Ensure you're on the host system (not in a container)  
cd ~/txlf-workshop  
<br/>\# Start your workshop environment  
./scripts/workshop-ctl.sh start  
<br/>\# Access your AlmaLinux development container  
./scripts/workshop-ctl.sh shell  

**You should now see a prompt like:**

\[workshopper@&lt;container-id&gt; workshop\]\$  

**Verify you're in the AlmaLinux container:**

\# These commands should be run INSIDE the container  
cat /etc/os-release | grep "AlmaLinux"  
whoami  
pwd  
ls -la /workshop  

**Step 1.2: Prepare Container for RamaLama**

**Inside your AlmaLinux container, update the system:**

\# Update package repository  
sudo dnf update -y  
<br/>\# Install additional dependencies needed for RamaLama  
sudo dnf install -y \\  
python3-devel \\  
gcc \\  
git \\  
cmake \\  
curl \\  
which \\  
procps-ng  
<br/>\# Upgrade pip to latest version  
pip3 install --upgrade pip  

**Section 2: Installing RamaLama in AlmaLinux Container**

**Step 2.1: Install RamaLama via pip**

**Still inside your AlmaLinux container:**

\# Install RamaLama  
pip3 install --user ramalama  
<br/>\# Verify installation  
~/.local/bin/ramalama --version  
which ramalama || echo "RamaLama installed in ~/.local/bin/"  

**Step 2.2: Configure Container Environment**

**Set up RamaLama directories and environment:**

\# Create model storage directories  
mkdir -p /workshop/models/ramalama  
mkdir -p /data/ramalama-cache  
mkdir -p /workshop/configs/ramalama  
<br/>\# Configure environment variables  
cat >> ~/.bashrc << 'EOF'  
\# RamaLama Configuration for AlmaLinux Container  
export RAMALAMA_STORE="/workshop/models/ramalama"  
export RAMALAMA_CACHE="/data/ramalama-cache"  
export PATH="\$HOME/.local/bin:\$PATH"  
<br/>\# Container identification  
export CONTAINER_ENV="almalinux-workshop"  
EOF  
<br/>\# Reload environment  
source ~/.bashrc  
<br/>\# Verify RamaLama can find its paths  
ramalama info  

**Expected output should show:**

- Your AlmaLinux system information
- Storage path: /workshop/models/ramalama
- Cache path: /data/ramalama-cache

**Step 2.3: Test Container Isolation**

**Verify container isolation is working:**

\# Check that we're isolated from host Podman  
podman version 2>/dev/null || echo "✓ Properly isolated - no host Podman access"  
<br/>\# But RamaLama should work  
ramalama --version  
<br/>\# Check our mounted volumes  
df -h | grep -E "/workshop|/data"  
<br/>\# Verify we can write to our volumes  
echo "Container test" > /workshop/container_test.txt  
echo "Data test" > /data/data_test.txt  
ls -la /workshop/container_test.txt /data/data_test.txt  

**Section 3: Containerized Model Management**

**Step 3.1: Download Models in Container**

**Inside the AlmaLinux container, explore available models:**

\# Browse available models (this may take a moment)  
ramalama list --available | head -20  
<br/>\# Look for small models suitable for container environment  
ramalama list --available | grep -i "tiny\\|small\\|mini" | head -10  

**Download your first model:**

\# Download TinyLlama (small, fast download)  
echo "Downloading TinyLlama model in AlmaLinux container..."  
echo "Storage location: /workshop/models/ramalama/"  
ramalama pull tinyllama  
<br/>\# Monitor the download  
ls -la /workshop/models/ramalama/  

**Step 3.2: Verify Persistent Storage**

**Test that models persist outside container:**

\# Check model storage  
ramalama list  
find /workshop/models -name "\*tinyllama\*" -type f  
<br/>\# Exit container temporarily  
exit  

**From HOST system, verify persistence:**

\# Back on host - check if model files are visible  
ls -la ~/txlf-workshop/models/  
find ~/txlf-workshop/models -name "\*tinyllama\*" 2>/dev/null | head -5  
<br/>\# Re-enter container  
./scripts/workshop-ctl.sh shell  

**Back in container, verify model is still available:**

\# Should show tinyllama without re-downloading  
ramalama list  

**Step 3.3: Download Additional Model**

**Download a more capable model:**

\# Download orca-mini for better responses  
echo "Downloading Orca-Mini model..."  
ramalama pull orca-mini  
<br/>\# Check storage usage  
du -sh /workshop/models/ramalama/  
ramalama list  

**Section 4: Containerized AI Chat**

**Step 4.1: Interactive Chat in Container**

**Start AI chat within the container:**

echo "=== Starting AI Chat in AlmaLinux Container ==="  
echo "You are running in: \$(cat /etc/os-release | grep PRETTY_NAME)"  
echo "Container user: \$(whoami)"  
echo "Working directory: \$(pwd)"  
echo ""  
echo "Type 'exit' to end chat session"  
echo "Try asking: 'What container am I running in?'"  
<br/>ramalama run tinyllama  

**Try these container-themed prompts:**

What container am I running in?  
Explain the benefits of running AI in containers.  
What is AlmaLinux?  
How does containerization help with AI model deployment?  

**Step 4.2: Chat with Orca-Mini**

**Test the more capable model:**

echo "=== Starting chat with Orca-Mini in container ==="  
ramalama run orca-mini  

**Test these advanced prompts:**

Explain the security benefits of rootless containers for AI workloads.  
How does AlmaLinux compare to other enterprise Linux distributions?  
What are the advantages of running AI models in isolated containers?  

**Step 4.3: Container Environment Chat**

**Run with container-specific system prompt:**

ramalama run orca-mini \\  
\--system "You are an AI assistant running inside an AlmaLinux container at Texas Linux Festival 2025. You understand containerization and Linux systems."  

**Test the specialized system prompt:**

Where am I running right now?  
What can you tell me about this environment?  
How do containers benefit AI deployments?  

**Section 5: Container-to-Host API Services**

**Step 5.1: Configure Container Networking**

**First, check your pod networking configuration:**

\# Check current network setup  
ip addr show | grep -A 2 "eth0"  
netstat -tlnp 2>/dev/null | grep -E ":808\[0-9\]" || echo "No conflicting services"  
<br/>\# Test connectivity to host network  
ping -c 2 google.com || echo "External connectivity check"  

**Step 5.2: Start API Server in Container**

**Start RamaLama API server accessible from host:**

\# Start API server bound to all interfaces in container  
echo "Starting RamaLama API server in AlmaLinux container..."  
echo "Server will be accessible from host on port 8888"  
<br/>ramalama serve orca-mini \\  
\--host 0.0.0.0 \\  
\--port 8888 &  
<br/>\# Wait for server to start  
sleep 5  
<br/>\# Test from within container  
curl -s <http://localhost:8888/v1/models> | jq . || curl -s <http://localhost:8888/v1/models>  

**Step 5.3: Test API from Host System**

**Open a NEW terminal on your HOST system:**

\# From HOST system (new terminal)  
cd ~/txlf-workshop  
<br/>\# Test API server running in container  
curl -s <http://localhost:8888/v1/models> | jq .  
<br/>\# If jq not available on host:  
curl -s <http://localhost:8888/v1/models>  

**Create API test from host:**

\# From HOST system, create test request  
cat > ~/txlf-workshop/test_container_api.json << 'EOF'  
{  
"model": "orca-mini",  
"messages": \[  
{  
"role": "system",  
"content": "You are an AI running in an AlmaLinux container."  
},  
{  
"role": "user",  
"content": "Explain how you are running in a container and accessible from the host."  
}  
\],  
"max_tokens": 200,  
"temperature": 0.7  
}  
EOF  
<br/>\# Test API from host  
curl -X POST <http://localhost:8888/v1/chat/completions> \\  
\-H "Content-Type: application/json" \\  
\-d @~/txlf-workshop/test_container_api.json  

**Section 6: Container Management and Monitoring**

**Step 6.1: Create Container Monitoring Script**

**Back in your AlmaLinux container, create monitoring tools:**

\# Inside container  
cat > /workshop/scripts/container_monitor.sh << 'EOF'  
# !/bin/bash  
<br/>echo "=== AlmaLinux Container RamaLama Monitoring ==="  
echo "Container: \$(hostname)"  
echo "OS: \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"  
echo "User: \$(whoami)"  
echo "Time: \$(date)"  
echo ""  
<br/>echo "=== Container Environment ==="  
echo "Working Directory: \$(pwd)"  
echo "Mount Points:"  
df -h | grep -E "/workshop|/data" | sed 's/^/ /'  
echo ""  
<br/>echo "=== RamaLama Status ==="  
echo "Version: \$(ramalama --version)"  
echo "Storage: \$RAMALAMA_STORE"  
echo "Cache: \$RAMALAMA_CACHE"  
echo ""  
<br/>echo "=== Available Models ==="  
ramalama list  
echo ""  
<br/>echo "=== Running Services ==="  
ramalama containers 2>/dev/null || echo "No RamaLama containers running"  
echo ""  
<br/>echo "=== Network Services ==="  
echo "Listening ports in container:"  
netstat -tlnp 2>/dev/null | grep LISTEN | sed 's/^/ /' || ss -tlnp | grep LISTEN | sed 's/^/ /'  
echo ""  
<br/>echo "=== Storage Usage ==="  
echo "Models: \$(du -sh /workshop/models/ramalama/ 2>/dev/null | cut -f1 || echo '0B')"  
echo "Cache: \$(du -sh /data/ramalama-cache/ 2>/dev/null | cut -f1 || echo '0B')"  
echo "Workspace: \$(du -sh /workshop/ 2>/dev/null | cut -f1)"  
EOF  
<br/>chmod +x /workshop/scripts/container_monitor.sh  
./scripts/container_monitor.sh  

**Step 6.2: Create Host-Side Monitoring**

**From HOST system, create host monitoring:**

\# On HOST system  
cat > ~/txlf-workshop/scripts/host_monitor.sh << 'EOF'  
# !/bin/bash  
<br/>echo "=== Host System Monitoring for TXLF Workshop ==="  
echo "Host: \$(hostname)"  
echo "Time: \$(date)"  
echo ""  
<br/>echo "=== Pod Status ==="  
podman pod ps  
echo ""  
<br/>echo "=== Container Status ==="  
podman ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"  
echo ""  
<br/>echo "=== Workshop Environment ==="  
echo "Workshop directory: ~/txlf-workshop/"  
ls -la ~/txlf-workshop/ | head -10  
echo ""  
<br/>echo "=== Persistent Storage ==="  
echo "Models stored on host:"  
find ~/txlf-workshop/models -type f -name "\*.gguf" 2>/dev/null | head -5 || echo "No .gguf files found yet"  
echo "Total model storage: \$(du -sh ~/txlf-workshop/models/ 2>/dev/null | cut -f1 || echo '0B')"  
echo ""  
<br/>echo "=== API Connectivity ==="  
if curl -s <http://localhost:8888/v1/models> >/dev/null 2>&1; then  
echo "✓ Container API accessible from host on port 8888"  
echo "Available models via API:"  
curl -s <http://localhost:8888/v1/models> 2>/dev/null | jq -r '.data\[\].id' 2>/dev/null | sed 's/^/ - /' || echo " (JSON parsing not available)"  
else  
echo "✗ Container API not accessible from host"  
fi  
EOF  
<br/>chmod +x ~/txlf-workshop/scripts/host_monitor.sh  
./scripts/host_monitor.sh  

**Section 7: Container Performance Testing**

**Step 7.1: Benchmark Models in Container**

**Back in your AlmaLinux container:**

\# Benchmark models within container environment  
echo "=== Benchmarking AI Models in AlmaLinux Container ==="  
<br/>echo "Testing TinyLlama performance..."  
ramalama bench tinyllama \\  
\--prompt "Explain containerization" \\  
\--max-tokens 50  
<br/>echo ""  
echo "Testing Orca-Mini performance..."  
ramalama bench orca-mini \\  
\--prompt "Explain containerization" \\  
\--max-tokens 50  

**Step 7.2: Create Performance Report**

**Generate performance report:**

cat > /workshop/outputs/container_performance.md << 'EOF'  
\# RamaLama Performance in AlmaLinux Container  
<br/>\## Environment  
\- \*\*Container OS\*\*: AlmaLinux  
\- \*\*Container User\*\*: workshopper  
\- \*\*Python Version\*\*: \$(python3 --version)  
\- \*\*RamaLama Version\*\*: \$(ramalama --version)  
<br/>\## Storage Configuration  
\- \*\*Model Storage\*\*: /workshop/models/ramalama/ (host-mounted)  
\- \*\*Cache Directory\*\*: /data/ramalama-cache/ (host-mounted)  
<br/>\## Models Tested  
\$(ramalama list)  
<br/>\## Container Isolation Benefits  
1\. \*\*Security\*\*: Models run without host root access  
2\. \*\*Consistency\*\*: Same environment across different hosts  
3\. \*\*Portability\*\*: Complete environment in container  
4\. \*\*Resource Control\*\*: Container-level resource limits  
<br/>\## Network Configuration  
\- \*\*API Server\*\*: Accessible on host port 8888  
\- \*\*Container Networking\*\*: Pod-based shared networking  
\- \*\*Host Access\*\*: Full API compatibility maintained  
<br/>\## Performance Notes  
\- Model loading time may be slightly higher due to container overhead  
\- API response times are comparable to native execution  
\- Storage I/O benefits from host SSD performance  
\- Memory usage contained within container limits  
<br/>Generated: \$(date)  
EOF  
<br/>cat /workshop/outputs/container_performance.md  

**Section 8: Container Cleanup and Management**

**Step 8.1: Proper Service Shutdown**

**Stop services gracefully:**

\# Stop API server  
ramalama stop --all  
<br/>\# Verify no background processes  
ps aux | grep ramalama | grep -v grep || echo "All RamaLama processes stopped"  
<br/>\# Check port availability  
netstat -tlnp 2>/dev/null | grep :8888 || echo "Port 8888 available"  

**Step 8.2: Create Startup/Shutdown Scripts**

**Create container management scripts:**

cat > /workshop/scripts/ramalama_start.sh << 'EOF'  
# !/bin/bash  
\# Start RamaLama services in container  
<br/>echo "Starting RamaLama services in AlmaLinux container..."  
<br/>\# Verify we're in container  
if \[ ! -f /.dockerenv \] && \[ ! -f /run/.containerenv \]; then  
echo "Warning: This script should run inside the container"  
fi  
<br/>\# Start API server  
echo "Starting API server on port 8888..."  
ramalama serve orca-mini --host 0.0.0.0 --port 8888 &  
<br/>\# Wait and verify  
sleep 3  
if curl -s <http://localhost:8888/v1/models> >/dev/null 2>&1; then  
echo "✓ API server started successfully"  
echo "Access from host: <http://localhost:8888>"  
else  
echo "✗ API server failed to start"  
fi  
EOF  
<br/>cat > /workshop/scripts/ramalama_stop.sh << 'EOF'  
# !/bin/bash  
\# Stop RamaLama services in container  
<br/>echo "Stopping RamaLama services..."  
ramalama stop --all  
<br/>echo "Killing any remaining processes..."  
pkill -f ramalama || echo "No processes to kill"  
<br/>echo "RamaLama services stopped"  
EOF  
<br/>chmod +x /workshop/scripts/ramalama_start.sh  
chmod +x /workshop/scripts/ramalama_stop.sh  

**Lab Completion Checklist**

**Verify all work is done in AlmaLinux container:**

- \[ \] **RamaLama installed** inside AlmaLinux container only
- \[ \] **Models downloaded** and stored in persistent volume
- \[ \] **Interactive chat** tested within container
- \[ \] **API server** running in container, accessible from host
- \[ \] **Container isolation** verified (no host Podman access)
- \[ \] **Persistent storage** working across container restarts
- \[ \] **Monitoring scripts** created for both container and host
- \[ \] **Performance testing** completed in container environment

**Final Test Commands:**

**From HOST:**

cd ~/txlf-workshop  
./scripts/workshop-ctl.sh status  
curl -s <http://localhost:8888/v1/models>  
./scripts/host_monitor.sh  

**From CONTAINER:**

./scripts/workshop-ctl.sh shell  
\# Then inside container:  
ramalama --version  
ramalama list  
./scripts/container_monitor.sh  

**Container-Specific Troubleshooting**

**1\. Can't access RamaLama from container:**

\# Verify PATH and installation  
source ~/.bashrc  
which ramalama  
ls -la ~/.local/bin/ramalama  

**2\. API not accessible from host:**

\# Check container networking  
\# Inside container:  
netstat -tlnp | grep 8888  
\# From host:  
podman port &lt;container-name&gt;  

**3\. Models not persisting:**

\# Check volume mounts  
\# Inside container:  
df -h | grep workshop  
\# From host:  
ls -la ~/txlf-workshop/models/  

**4\. Container can't access internet:**

\# Check container networking  
\# Inside container:  
ping google.com  
nslookup google.com  

_🤠 Happy containerized AI wrangling! You've mastered AI deployment in AlmaLinux! 📦🧠_

