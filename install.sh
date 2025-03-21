#!/bin/bash

# Soundness CLI One-Line Installer
# This script automatically installs the Soundness CLI tool

set -e

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Print banner
echo -e "\e[1;35m
███████╗ ██████╗ █████╗ ██╗   ██╗███████╗███╗   ██╗ ██████╗ ███████╗██████╗ 
██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝████╗  ██║██╔════╝ ██╔════╝██╔══██╗
███████╗██║     ███████║██║   ██║█████╗  ██╔██╗ ██║██║  ███╗█████╗  ██████╔╝
╚════██║██║     ██╔══██║╚██╗ ██╔╝██╔══╝  ██║╚██╗██║██║   ██║██╔══╝  ██╔══██╗
███████║╚██████╗██║  ██║ ╚████╔╝ ███████╗██║ ╚████║╚██████╔╝███████╗██║  ██║
╚══════╝ ╚═════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
 █████╗ ██╗██████╗ ██████╗ ██████╗  ██████╗ ██████╗     
██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██╔══██╗    
███████║██║██████╔╝██║  ██║██████╔╝██║   ██║██████╔╝    
██╔══██║██║██╔══██╗██║  ██║██╔══██╗██║   ██║██╔═══╝     
██║  ██║██║██║  ██║██████╔╝██║  ██║╚██████╔╝██║         
╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝ 
                                                                                                                                                     
\e[1;34m
               Join the scavenger airdrop Now!\e[1;32m
        ──────────────────────────────────────
        Telegram Group: \e[1;4;33mhttps://t.me/scavengerairdrop\e[0m
        ──────────────────────────────────────"
echo -e "${NC}"

echo -e "${BLUE}Soundness CLI Installer${NC}"
echo "============================"

# Check if soundnessup is already installed
if command -v soundnessup &> /dev/null; then
    echo -e "${GREEN}soundnessup is already installed.${NC}"
    echo "You can update it with: soundnessup update"
    exit 0
fi

# Check if Rust is installed
if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}Rust not found. Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install required dependencies based on OS
echo "Installing required dependencies..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y build-essential pkg-config libssl-dev
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y gcc openssl-devel pkg-config
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum install -y gcc openssl-devel pkg-config
    else
        echo -e "${YELLOW}Couldn't identify package manager. You may need to install build essentials manually.${NC}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install openssl pkg-config
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Creating temporary directory: $TEMP_DIR"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git not found. Installing Git...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git
    fi
fi

# Clone the repository
echo "Cloning Soundness repository..."
git clone https://github.com/soundnesslabs/soundness-layer.git "$TEMP_DIR/soundness-layer"

# Find the soundnessup installer
INSTALLER_DIR="$TEMP_DIR/soundness-layer/soundnessup"
if [ ! -d "$INSTALLER_DIR" ]; then
    echo -e "${RED}Error: Could not find soundnessup directory.${NC}"
    echo "Repository structure might have changed."
    
    # Try to find it elsewhere
    INSTALLER_DIR=$(find "$TEMP_DIR/soundness-layer" -name "soundnessup" -type d | head -n 1)
    
    if [ -z "$INSTALLER_DIR" ]; then
        echo -e "${RED}Could not locate soundnessup directory. Exiting.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Found soundnessup at: $INSTALLER_DIR${NC}"
fi

# Navigate to the installer directory
cd "$INSTALLER_DIR"

# Install using Cargo
echo "Installing Soundness CLI using Cargo..."
cargo install --path .

# Add to PATH if not already there
if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
fi

if [ -f ~/.zshrc ] && ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
fi

# Verify installation
if command -v soundnessup &> /dev/null; then
    echo -e "${GREEN}Soundness CLI installed successfully!${NC}"
    echo "Use 'soundnessup install' to complete the installation."
    echo -e "${YELLOW}Remember to restart your terminal or run:${NC}"
    echo "  source ~/.bashrc  # for bash"
    echo "  # or"
    echo "  source ~/.zshenv  # for zsh"
else
    echo -e "${RED}Installation might have failed. Try running:${NC}"
    echo "  source ~/.cargo/env"
    echo "  soundnessup install"
fi

# Clean up
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Installation process completed!${NC}"
echo -e "${BLUE}Don't forget to follow Soundness on X and join the Discord to request testnet access.${NC}"
echo -e "${YELLOW}To join the testnet, generate your keys and request access using:${NC}"
echo "  !access <base64-encoded-public-key>"
