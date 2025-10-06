**Workshop Lab 1: Podman Setup & Container Fundamentals**

_Texas Linux Festival 2025 - Hands-on Lab_

**Lab Overview**

**Time Required:** 30 minutes  
**Difficulty:** Beginner to Intermediate  
**Prerequisites:** Basic Linux command line knowledge

**What You'll Learn:**

- Install and configure rootless Podman
- Create isolated workshop environments
- Understand pods and volumes
- Set up the foundation for our AI bot pipeline

**What You'll Build:**

- Rootless Podman environment
- Persistent workshop workspace
- AlmaLinux container for development
- Foundation for RamaLama integration

**Lab Setup Requirements**

**Hardware Requirements:**

- Linux machine (physical or VM)
- 2GB RAM minimum (4GB recommended)
- 10GB free disk space
- Internet connection for downloads

**Software Requirements:**

- Modern Linux distribution (Fedora, RHEL, AlmaLinux, Ubuntu, etc.)
- sudo access for initial installation
- Terminal access

**Optional but Helpful:**

- Second terminal window/tab for monitoring
- Text editor (vim, nano, or VS Code)

**Section 1: Installing Rootless Podman**

**Step 1.1: Install Podman Package**

**For Fedora/RHEL/AlmaLinux/CentOS:**

sudo dnf install -y podman podman-compose buildah  

**For Ubuntu/Debian:**

sudo apt update  
sudo apt install -y podman podman-compose buildah  

**For Arch Linux:**

sudo pacman -S podman podman-compose buildah  

**Verify Installation:**

podman --version  
podman-compose --version  

**Expected Output:**

podman version 4.9.4-rhel  
podman-compose version 1.0.6  

**Step 1.2: Configure Rootless Podman**

**Check if subuid/subgid are configured:**

grep \$USER /etc/subuid  
grep \$USER /etc/subgid  

**If empty, configure manually:**

\# Only if the grep commands above returned nothing  
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 \$USER  

**Initialize rootless Podman:**

podman system migrate  

**Test rootless functionality:**

podman run --rm hello-world  

**Expected Output:**

Hello from Docker!  
This message shows that your installation appears to be working correctly.  

**Step 1.3: Enable Podman Socket (Optional)**

**Enable Docker API compatibility:**

systemctl --user enable podman.socket  
systemctl --user start podman.socket  

**Test Docker compatibility:**

export DOCKER_HOST=unix:///run/user/\$UID/podman/podman.sock  
podman version  

**Section 2: Creating Your Workshop Environment**

**Step 2.1: Set Up Workshop Directory Structure**

**Create the workshop workspace:**

\# Create main workshop directory  
mkdir -p ~/txlf-workshop  
<br/>\# Create subdirectories for organization  
cd ~/txlf-workshop  
mkdir -p {containers,volumes,configs,scripts,outputs,models}  
<br/>\# Verify structure  
tree ~/txlf-workshop  
\# or if tree isn't available:  
find ~/txlf-workshop -type d  

**Expected Structure:**

~/txlf-workshop/  
├── containers/ # Container definitions and Dockerfiles  
├── volumes/ # Persistent data volumes  
├── configs/ # Configuration files  
├── scripts/ # Workshop scripts and automation  
├── outputs/ # Results and logs  
└── models/ # AI models (for later labs)  

**Step 2.2: Create Workshop Volume**

**Create a named volume for persistent data:**

podman volume create txlf-workshop-data  

**Inspect the volume:**

podman volume inspect txlf-workshop-data  

**List volumes:**

podman volume ls  

**Step 2.3: Test Volume Mounting**

**Create a test container with volume:**

podman run --rm -it \\  
\--name volume-test \\  
\-v txlf-workshop-data:/data:Z \\  
\-v ~/txlf-workshop:/workshop:Z \\  
almalinux:latest bash  

**Inside the container, test persistence:**

\# Create test files  
echo "Hello from container" > /data/test.txt  
echo "Workshop directory mounted" > /workshop/test.txt  
ls -la /data/  
ls -la /workshop/  
exit  

**Verify persistence on host:**

ls -la ~/txlf-workshop/  
\# Should see test.txt file  

**Section 3: Building Your Development Container**

**Step 3.1: Create Development Dockerfile**

**Create a custom development container:**

cd ~/txlf-workshop/containers  
cat > Dockerfile.dev << 'EOF'  
FROM almalinux:latest  
<br/>\# Install development tools  
RUN dnf update -y && \\  
dnf install -y \\  
python3 \\  
python3-pip \\  
git \\  
vim \\  
curl \\  
wget \\  
which \\  
htop \\  
tree \\  
jq && \\  
dnf clean all  
<br/>\# Install Python packages for AI development  
RUN pip3 install --no-cache-dir \\  
numpy \\  
pandas \\  
requests \\  
pyyaml  
<br/>\# Create workshop user (matching host UID for rootless)  
RUN useradd -m -u 1000 workshopper  
USER workshopper  
WORKDIR /workshop  
<br/>\# Set up environment  
ENV PYTHONPATH=/workshop  
ENV PATH="/home/workshopper/.local/bin:\$PATH"  
<br/>CMD \["/bin/bash"\]  
EOF  

**Step 3.2: Build Development Image**

**Build the custom image:**

cd ~/txlf-workshop/containers  
podman build -f Dockerfile.dev -t txlf-dev:latest .  

**Verify the build:**

podman images | grep txlf-dev  

**Step 3.3: Test Development Container**

**Run the development container:**

podman run -it --rm \\  
\--name txlf-dev-test \\  
\-v txlf-workshop-data:/data:Z \\  
\-v ~/txlf-workshop:/workshop:Z \\  
\-w /workshop \\  
txlf-dev:latest  

**Inside the container, test environment:**

\# Check user and permissions  
whoami  
id  
pwd  
<br/>\# Test Python environment  
python3 --version  
pip3 list  
<br/>\# Test volume access  
ls -la /data/  
ls -la /workshop/  
<br/>\# Create a test script  
cat > test_env.py << 'EOF'  
# !/usr/bin/env python3  
import sys  
import os  
import json  
<br/>print("=== TXLF Workshop Environment Test ===")  
print(f"Python version: {sys.version}")  
print(f"Current user: {os.getenv('USER', 'unknown')}")  
print(f"Working directory: {os.getcwd()}")  
print(f"Workshop data accessible: {os.path.exists('/data')}")  
print("Environment ready for AI development!")  
EOF  
<br/>python3 test_env.py  
exit  

**Section 4: Working with Pods**

**Step 4.1: Create Your First Pod**

**Create a multi-container pod:**

podman pod create \\  
\--name txlf-workshop-pod \\  
\--publish 8080:8080 \\  
\--publish 8888:8888  

**Inspect the pod:**

podman pod inspect txlf-workshop-pod  
podman pod ps  

**Step 4.2: Add Containers to Pod**

**Add development container to pod:**

podman run -d \\  
\--name dev-container \\  
\--pod txlf-workshop-pod \\  
\-v txlf-workshop-data:/data:Z \\  
\-v ~/txlf-workshop:/workshop:Z \\  
txlf-dev:latest sleep infinity  

**Add a simple web server for testing:**

podman run -d \\  
\--name web-server \\  
\--pod txlf-workshop-pod \\  
\-v ~/txlf-workshop:/usr/share/nginx/html:Z,ro \\  
nginx:alpine  

**Step 4.3: Test Pod Networking**

**Verify containers are running:**

podman pod ps  
podman ps --pod  

**Test shared networking:**

\# Execute in dev container  
podman exec -it dev-container bash  
<br/>\# Inside dev container - test localhost networking  
curl <http://localhost:8080>  
\# Should see nginx default page or workshop files  
<br/>exit  

**Test from host:**

\# Create a simple HTML file  
echo "&lt;h1&gt;Welcome to TXLF Workshop!&lt;/h1&gt;" > ~/txlf-workshop/index.html  
<br/>\# Test access from host  
curl <http://localhost:8080>  

**Section 5: Container Management & Systemd Integration**

**Step 5.1: Generate Systemd Service**

**Generate systemd unit for your pod:**

podman generate systemd \\  
\--new \\  
\--name txlf-workshop-pod \\  
\--files  

**Move service files to user directory:**

mkdir -p ~/.config/systemd/user  
mv pod-txlf-workshop-pod.service ~/.config/systemd/user/  
mv container-dev-container.service ~/.config/systemd/user/  
mv container-web-server.service ~/.config/systemd/user/  

**Step 5.2: Enable Systemd Services**

**Reload systemd and enable services:**

systemctl --user daemon-reload  
systemctl --user enable pod-txlf-workshop-pod.service  

**Test stopping and starting with systemd:**

\# Stop the current pod  
podman pod stop txlf-workshop-pod  
<br/>\# Start via systemd  
systemctl --user start pod-txlf-workshop-pod.service  
<br/>\# Check status  
systemctl --user status pod-txlf-workshop-pod.service  

**Step 5.3: Create Workshop Management Script**

**Create a convenience script:**

cat > ~/txlf-workshop/scripts/workshop-ctl.sh << 'EOF'  
# !/bin/bash  
<br/>WORKSHOP_DIR="\$HOME/txlf-workshop"  
POD_NAME="txlf-workshop-pod"  
<br/>case "\$1" in  
start)  
echo "Starting TXLF Workshop environment..."  
systemctl --user start pod-\${POD_NAME}.service  
echo "Workshop environment started!"  
echo "Access web interface: <http://localhost:8080>"  
;;  
stop)  
echo "Stopping TXLF Workshop environment..."  
systemctl --user stop pod-\${POD_NAME}.service  
echo "Workshop environment stopped!"  
;;  
status)  
systemctl --user status pod-\${POD_NAME}.service  
;;  
shell)  
podman exec -it dev-container bash  
;;  
logs)  
journalctl --user -u pod-\${POD_NAME}.service -f  
;;  
clean)  
echo "Cleaning up workshop environment..."  
systemctl --user stop pod-\${POD_NAME}.service  
podman pod rm -f \${POD_NAME}  
podman volume rm txlf-workshop-data  
echo "Workshop environment cleaned!"  
;;  
\*)  
echo "Usage: \$0 {start|stop|status|shell|logs|clean}"  
echo ""  
echo "Commands:"  
echo " start - Start the workshop environment"  
echo " stop - Stop the workshop environment"  
echo " status - Check environment status"  
echo " shell - Get shell in development container"  
echo " logs - View environment logs"  
echo " clean - Remove all workshop containers and data"  
exit 1  
;;  
esac  
EOF  
<br/>chmod +x ~/txlf-workshop/scripts/workshop-ctl.sh  

**Section 6: Verification & Testing**

**Step 6.1: Complete Environment Test**

**Test the workshop script:**

cd ~/txlf-workshop  
./scripts/workshop-ctl.sh status  
./scripts/workshop-ctl.sh shell  

**Inside the development container:**

\# Verify environment  
cat > /workshop/verification.py << 'EOF'  
# !/usr/bin/env python3  
"""  
TXLF Workshop Environment Verification  
"""  
import os  
import sys  
import subprocess  
import json  
<br/>def check_environment():  
print("=== TXLF Workshop Environment Verification ===\\n")  
<br/>\# Check Python  
print(f"✓ Python version: {sys.version.split()\[0\]}")  
<br/>\# Check user  
user = os.getenv('USER', 'unknown')  
print(f"✓ Current user: {user}")  
<br/>\# Check directories  
dirs_to_check = \['/workshop', '/data'\]  
for directory in dirs_to_check:  
if os.path.exists(directory):  
print(f"✓ Directory accessible: {directory}")  
else:  
print(f"✗ Directory missing: {directory}")  
<br/>\# Check networking (curl to localhost)  
try:  
result = subprocess.run(\['curl', '-s', '<http://localhost:8080'\>],  
capture_output=True, text=True, timeout=5)  
if result.returncode == 0:  
print("✓ Pod networking functional")  
else:  
print("✗ Pod networking issue")  
except Exception as e:  
print(f"✗ Network test failed: {e}")  
<br/>\# Check Podman access (should fail in container, which is expected)  
try:  
result = subprocess.run(\['podman', 'version'\],  
capture_output=True, text=True, timeout=5)  
if result.returncode == 0:  
print("! Podman accessible in container (unexpected)")  
else:  
print("✓ Container properly isolated from host Podman")  
except Exception:  
print("✓ Container properly isolated from host Podman")  
<br/>print("\\n=== Environment Ready for AI Development! ===")  
<br/>if \__name__ == "\__main_\_":  
check_environment()  
EOF  
<br/>python3 /workshop/verification.py  
exit  

**Step 6.2: Document Your Environment**

**Create environment documentation:**

cat > ~/txlf-workshop/README.md << 'EOF'  
\# TXLF Workshop Environment  
<br/>\## Overview  
This is your Texas Linux Festival 2025 workshop environment for learning:  
\- Podman (rootless containers)  
\- RamaLama (AI model orchestration)  
\- Docling (document processing)  
\- RAG (Retrieval-Augmented Generation)  
<br/>\## Quick Start  

**Start environment**

./scripts/workshop-ctl.sh start

**Get development shell**

./scripts/workshop-ctl.sh shell

**Stop environment**

./scripts/workshop-ctl.sh stop

\## Environment Details  
\- \*\*Development Container\*\*: AlmaLinux-based with Python 3 and AI tools  
\- \*\*Web Server\*\*: Nginx for testing and demos  
\- \*\*Persistent Storage\*\*: Named volume for data persistence  
\- \*\*Networking\*\*: Pod-based with shared localhost  
<br/>\## Directory Structure  
\- \`~/txlf-workshop/\` - Main workshop directory  
\- \`containers/\` - Container definitions  
\- \`volumes/\` - Persistent data  
\- \`configs/\` - Configuration files  
\- \`scripts/\` - Workshop automation  
\- \`outputs/\` - Results and logs  
\- \`models/\` - AI models (Lab 2+)  
<br/>\## Next Steps  
Ready for Lab 2: RamaLama Installation and AI Model Management!  
EOF  

**Lab Completion Checklist**

**Verify you have completed all sections:**

- \[ \] **Podman installed** and rootless mode working
- \[ \] **Workshop directory** structure created
- \[ \] **Persistent volume** created and tested
- \[ \] **Development container** built and functional
- \[ \] **Pod networking** working correctly
- \[ \] **Systemd integration** configured
- \[ \] **Management script** working
- \[ \] **Environment verification** passed

**Test Commands:**

\# These should all work without errors:  
podman version  
podman pod ps  
curl <http://localhost:8080>  
./scripts/workshop-ctl.sh status  
./scripts/workshop-ctl.sh shell  

**Troubleshooting**

**Common Issues and Solutions:**

**1\. "permission denied" errors:**

\# Check subuid/subgid configuration  
grep \$USER /etc/subuid /etc/subgid  
<br/>\# If empty, run:  
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 \$USER  
\# Then log out and back in  

**2\. "network already exists" errors:**

\# Clean up existing pods/networks  
podman pod stop --all  
podman pod rm --all  
podman network prune  

**3\. Volume mount issues:**

\# Check SELinux context (if applicable)  
ls -laZ ~/txlf-workshop/  
\# Use :Z flag in volume mounts for SELinux  

**4\. Port conflicts:**

\# Check what's using the ports  
ss -tlnp | grep ':8080\\|:8888'  
\# Use different ports in pod creation if needed

