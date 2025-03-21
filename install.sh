#!/bin/bash

# Instalasi Soundness CLI dengan satu command
# Gunakan: curl -sSL https://raw.githubusercontent.com/YourUsername/YourRepo/main/install.sh | bash

set -e

# Warna untuk output terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
NC='\033[0m' # Tanpa Warna

# Tampilkan banner
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
               Bergabunglah dengan airdrop scavenger sekarang!\e[1;32m
        ──────────────────────────────────────
        Grup Telegram: \e[1;4;33mhttps://t.me/scavengerairdrop\e[0m
        ──────────────────────────────────────"
echo -e "${NC}"

echo -e "${BLUE}Installer Soundness CLI${NC}"
echo "============================"

# Periksa apakah Rust sudah terinstal
if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}Rust tidak ditemukan. Menginstal Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Instalasi dependensi sesuai dengan sistem operasi
echo "Menginstal dependensi yang diperlukan..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y build-essential pkg-config libssl-dev git
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y gcc openssl-devel pkg-config git
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum install -y gcc openssl-devel pkg-config git
    else
        echo -e "${YELLOW}Sistem paket tidak terdeteksi. Pastikan build-essential dan git sudah terinstal.${NC}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew tidak ditemukan. Menginstal Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install openssl pkg-config git
fi

# Buat direktori sementara
TEMP_DIR=$(mktemp -d)
echo "Membuat direktori sementara: $TEMP_DIR"

# Kloning repositori dan khususnya direktori soundnessup
echo "Mengkloning repositori Soundness..."
git clone --depth 1 https://github.com/SoundnessLabs/soundness-layer.git "$TEMP_DIR/soundness-layer"

# Pastikan direktori soundnessup ada
SOUNDNESSUP_DIR="$TEMP_DIR/soundness-layer/soundnessup"
if [ ! -d "$SOUNDNESSUP_DIR" ]; then
    echo -e "${RED}Error: Direktori soundnessup tidak ditemukan di repositori.${NC}"
    echo "Struktur repositori mungkin telah berubah."
    exit 1
fi

# Cek jika Cargo.toml ada di direktori soundnessup
if [ ! -f "$SOUNDNESSUP_DIR/Cargo.toml" ]; then
    echo -e "${RED}Error: File Cargo.toml tidak ditemukan di direktori soundnessup.${NC}"
    echo "Struktur proyek mungkin telah berubah."
    exit 1
fi

# Navigasi ke direktori soundnessup
cd "$SOUNDNESSUP_DIR"
echo "Menginstal dari direktori: $SOUNDNESSUP_DIR"

# Instal menggunakan Cargo
echo "Menginstal Soundness CLI menggunakan Cargo..."
cargo install --path .

# Tambahkan ke PATH jika belum ada
if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
fi

if [ -f ~/.zshrc ] && ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
fi

# Verifikasi instalasi
if [ -f "$HOME/.cargo/bin/soundnessup" ]; then
    echo -e "${GREEN}Soundness CLI berhasil diinstal!${NC}"
    echo "Anda dapat menggunakan 'soundnessup install' untuk menyelesaikan instalasi."
    echo -e "${YELLOW}Ingat untuk memulai ulang terminal Anda atau jalankan:${NC}"
    echo "  source ~/.bashrc  # untuk bash"
    echo "  # atau"
    echo "  source ~/.zshenv  # untuk zsh"
    echo "  # atau"
    echo "  source ~/.cargo/env  # untuk sesi saat ini"
else
    echo -e "${RED}Instalasi mungkin gagal. Coba jalankan perintah berikut:${NC}"
    echo "  source ~/.cargo/env"
    echo "  cd $SOUNDNESSUP_DIR"
    echo "  cargo install --path ."
fi

# Bersihkan
echo "Membersihkan file sementara..."
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Proses instalasi selesai!${NC}"
echo -e "${BLUE}Jangan lupa untuk mengikuti Soundness di X dan bergabung dengan Discord untuk meminta akses testnet.${NC}"
echo -e "${YELLOW}Untuk bergabung dengan testnet, buat kunci Anda dan minta akses menggunakan:${NC}"
echo "  !access <kunci-publik-base64-encoded>"
