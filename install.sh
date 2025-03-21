#!/bin/bash

# Soundness CLI Auto-Install Script
# This script automatically installs the Soundness CLI tool

set -e

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed. Please install git and try again.${NC}"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js is not installed. Installing...${NC}"
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            sudo apt-get update
            sudo apt-get install -y nodejs npm
        elif command -v dnf &> /dev/null; then
            # Fedora
            sudo dnf install -y nodejs npm
        elif command -v yum &> /dev/null; then
            # CentOS/RHEL
            sudo yum install -y nodejs npm
        else
            echo -e "${RED}Unsupported Linux distribution. Please install Node.js manually.${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install node
        else
            echo -e "${RED}Homebrew not found. Please install Node.js manually.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Unsupported operating system. Please install Node.js manually.${NC}"
        exit 1
    fi
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d 'v' -f 2)
REQUIRED_VERSION="14.0.0"

if [[ $(echo -e "$NODE_VERSION\n$REQUIRED_VERSION" | sort -V | head -n1) != "$REQUIRED_VERSION" ]]; then
    echo -e "${YELLOW}Warning: Node.js version $NODE_VERSION is below the recommended version ($REQUIRED_VERSION).${NC}"
    echo -e "You may experience issues. Consider upgrading your Node.js installation."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Creating temporary directory: $TEMP_DIR"

# Clone the repository
echo "Cloning Soundness CLI repository..."
git clone https://github.com/SoundnessLabs/soundness-layer.git "$TEMP_DIR/soundness-layer"

# Navigate to the CLI directory
cd "$TEMP_DIR/soundness-layer/soundness-cli"

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the project
echo "Building Soundness CLI..."
npm run build

# Install globally
echo "Installing Soundness CLI globally..."
sudo npm install -g .

# Verify installation
if command -v soundness &> /dev/null; then
    INSTALLED_VERSION=$(soundness --version)
    echo -e "${GREEN}Soundness CLI installed successfully!${NC}"
    echo "Version: $INSTALLED_VERSION"
    echo "You can now use the 'soundness' command."
else
    echo -e "${RED}Installation failed. Please try again or install manually.${NC}"
    exit 1
fi

# Clean up
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Installation complete!${NC}"
echo "Run 'soundness --help' to see available commands."
