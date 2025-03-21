#!/bin/bash

# Soundness CLI One-Click Installer
# This script installs the Soundness CLI tool from the Soundness Labs repository

# Text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
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
        ──────────────────────────────────────
${NC}"
echo ""

# Check for required dependencies
echo "Checking dependencies..."

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed. Please install git and try again.${NC}"
    exit 1
fi

# Check for npm and Node.js
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed. Please install Node.js and npm, then try again.${NC}"
    exit 1
fi

# Check for Node.js version
NODE_VERSION=$(node -v | cut -d 'v' -f 2)
REQUIRED_VERSION="18.0.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo -e "${RED}Error: Node.js version 18 or higher is required.${NC}"
    echo -e "Current version: ${NODE_VERSION}"
    exit 1
fi

echo -e "${GREEN}All dependencies are satisfied.${NC}"

# Create installation directory
INSTALL_DIR="$HOME/.soundness-cli"
echo "Installing Soundness CLI to $INSTALL_DIR..."

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Clone the repository
echo "Cloning Soundness CLI repository..."
git clone https://github.com/SoundnessLabs/soundness-layer.git "$INSTALL_DIR/temp" || { 
    echo -e "${RED}Error: Failed to clone repository.${NC}" 
    exit 1
}

# Move to the CLI directory
cd "$INSTALL_DIR/temp/soundness-cli" || {
    echo -e "${RED}Error: Failed to navigate to the CLI directory.${NC}"
    exit 1
}

# Install dependencies
echo "Installing npm dependencies..."
npm install || {
    echo -e "${RED}Error: Failed to install npm dependencies.${NC}"
    exit 1
}

# Build the CLI
echo "Building Soundness CLI..."
npm run build || {
    echo -e "${RED}Error: Failed to build the CLI.${NC}"
    exit 1
}

# Create global link
echo "Creating global npm link..."
npm link || {
    echo -e "${RED}Error: Failed to create global npm link.${NC}"
    exit 1
}

# Move built files to final location
echo "Setting up final installation..."
cd "$INSTALL_DIR" || exit 1
mv temp/soundness-cli/* .
rm -rf temp

# Create a configuration file
echo "Creating default configuration..."
mkdir -p "$HOME/.soundness"
CONFIG_FILE="$HOME/.soundness/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
{
  "api_key": "",
  "output_format": "json",
  "default_network": "mainnet"
}
EOF
    echo "Created default configuration file at $CONFIG_FILE"
    echo "Note: You will need to add your API key to this file."
fi

# Add to PATH if not already there
SHELL_TYPE=$(basename "$SHELL")
RC_FILE=""

case "$SHELL_TYPE" in
    bash)
        RC_FILE="$HOME/.bashrc"
        ;;
    zsh)
        RC_FILE="$HOME/.zshrc"
        ;;
    *)
        echo "Unsupported shell: $SHELL_TYPE. Please manually add the Soundness CLI to your PATH."
        ;;
esac

if [ -n "$RC_FILE" ]; then
    if ! grep -q "soundness-cli" "$RC_FILE"; then
        echo "Adding Soundness CLI to PATH in $RC_FILE..."
        echo 'export PATH="$PATH:$HOME/.soundness-cli/bin"' >> "$RC_FILE"
        echo "Please restart your terminal or run 'source $RC_FILE' to update your PATH."
    else
        echo "Soundness CLI is already in PATH."
    fi
fi

# Create bin directory and launcher script
mkdir -p "$INSTALL_DIR/bin"
cat > "$INSTALL_DIR/bin/soundness" << EOF
#!/bin/bash
node $INSTALL_DIR/dist/index.js "\$@"
EOF

chmod +x "$INSTALL_DIR/bin/soundness"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Soundness CLI installed successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Usage: soundness [command] [options]"
echo ""
echo "To get started, run: soundness --help"
echo ""
echo "Don't forget to add your API key to the config file:"
echo "$CONFIG_FILE"
echo ""
echo "If the 'soundness' command is not found, make sure to restart your terminal"
echo "or run: source $RC_FILE"

exit 0
