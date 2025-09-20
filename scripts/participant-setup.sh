#!/bin/bash

set -e

echo "🚀 DevConf.us Hands-On Setup Script"
echo "Setting up environment for Fedora Bootable Containers workshop..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please don't run this script as root"
    exit 1
fi

# Detect OS
if [ -f /etc/fedora-release ]; then
    OS="fedora"
    INSTALL_CMD="sudo dnf install -y"
elif [ -f /etc/redhat-release ]; then
    OS="rhel"
    INSTALL_CMD="sudo dnf install -y"
elif [ -f /etc/debian_version ]; then
    OS="debian"
    INSTALL_CMD="sudo apt update && sudo apt install -y"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    INSTALL_CMD="brew install"
else
    OS="unknown"
fi

print_status "Detected OS: $OS"

# Check prerequisites
print_status "Checking prerequisites..."

# Check for required commands
REQUIRED_COMMANDS=("git" "curl" "python3")
MISSING_COMMANDS=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_COMMANDS+=("$cmd")
    fi
done

# Install missing basic commands
if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
    print_warning "Missing commands: ${MISSING_COMMANDS[*]}"
    print_status "Installing missing commands..."
    
    case $OS in
        "fedora"|"rhel")
            $INSTALL_CMD git curl python3 python3-pip jq
            ;;
        "debian")
            $INSTALL_CMD git curl python3 python3-pip jq
            ;;
        "macos")
            $INSTALL_CMD git curl python3 jq
            ;;
        *)
            print_error "Unsupported OS. Please install git, curl, python3, and jq manually."
            exit 1
            ;;
    esac
fi

# Check for Podman
if ! command -v podman &> /dev/null; then
    print_warning "Podman not found. Installing..."
    
    case $OS in
        "fedora"|"rhel")
            $INSTALL_CMD podman
            ;;
        "debian")
            # Add Podman repository for Debian/Ubuntu
            print_status "Adding Podman repository..."
            . /etc/os-release
            echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
            curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -
            sudo apt update
            $INSTALL_CMD podman
            ;;
        "macos")
            $INSTALL_CMD podman
            print_status "Starting Podman machine..."
            podman machine init
            podman machine start
            ;;
        *)
            print_error "Please install Podman manually for your OS"
            exit 1
            ;;
    esac
else
    print_success "Podman is already installed"
fi

# Verify Podman works
print_status "Testing Podman..."
if podman --version &> /dev/null; then
    print_success "Podman is working: $(podman --version)"
else
    print_error "Podman installation failed or not working"
    exit 1
fi

# Install RamaLama
print_status "Installing RamaLama..."
if ! command -v ramalama &> /dev/null; then
    pip3 install --user ramalama
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
        export PATH=$PATH:$HOME/.local/bin
        print_status "Added ~/.local/bin to PATH"
    fi
else
    print_success "RamaLama is already installed"
fi

# Verify RamaLama
if command -v ramalama &> /dev/null; then
    print_success "RamaLama is working: $(ramalama --version)"
else
    print_warning "RamaLama not found in PATH. You may need to restart your shell or run:"
    echo "export PATH=\$PATH:\$HOME/.local/bin"
fi

# Optional: Install cloud-init for validation
if ! command -v cloud-init &> /dev/null; then
    print_status "Installing cloud-init (optional)..."
    case $OS in
        "fedora"|"rhel")
            $INSTALL_CMD cloud-init || print_warning "Could not install cloud-init"
            ;;
        "debian")
            $INSTALL_CMD cloud-init || print_warning "Could not install cloud-init"
            ;;
        "macos")
            print_warning "cloud-init not available on macOS"
            ;;
    esac
fi

# Create workspace directory
WORKSPACE="$HOME/devconf-bootc-workshop"
if [ ! -d "$WORKSPACE" ]; then
    print_status "Creating workspace directory: $WORKSPACE"
    mkdir -p "$WORKSPACE"
fi

# Summary
print_success "Setup completed successfully!"
echo ""
echo "📋 Summary:"
echo "  ✅ OS: $OS"
echo "  ✅ Podman: $(podman --version 2>/dev/null || echo 'Not available')"
echo "  ✅ Git: $(git --version 2>/dev/null || echo 'Not available')"
echo "  ✅ Python: $(python3 --version 2>/dev/null || echo 'Not available')"
echo "  ✅ RamaLama: $(ramalama --version 2>/dev/null || echo 'Not in PATH')"
echo "  ✅ Workspace: $WORKSPACE"
echo ""
echo "🎯 Next Steps:"
echo "  1. Clone the workshop repository:"
echo "     cd $WORKSPACE"
echo "     git clone <repository-url>"
echo ""
echo "  2. If RamaLama is not in PATH, run:"
echo "     export PATH=\$PATH:\$HOME/.local/bin"
echo ""
echo "  3. Follow along with the presentation!"
echo ""
print_success "Ready for the DevConf.us workshop! 🚀"