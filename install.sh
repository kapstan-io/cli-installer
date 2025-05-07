#!/bin/bash

# Install script for kapstan

set -e

# 1. Detect OS and architecture
OS=""
ARCH=""

# Detect OS
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     OS="linux";;
    Darwin*)    OS="darwin";;
    *)          OS="unknown";;
esac

if [ "$OS" = "unknown" ]; then
    echo "Unsupported OS: $unameOut"
    exit 1
fi

# Detect architecture
ARCH_OUT="$(uname -m)"
case "${ARCH_OUT}" in
    x86_64)    ARCH="amd64";;
    arm64|aarch64) ARCH="arm64";;
    *)         ARCH="unknown";;
esac

if [ "$ARCH" = "unknown" ]; then
    echo "Unsupported architecture: $ARCH_OUT"
    exit 1
fi

echo "Detected OS: $OS"
echo "Detected architecture: $ARCH"

# 2. Ensure curl is installed
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is not installed. Please install curl and retry."
    exit 1
fi

# 3. Attempt to curl the correct binary download from GitHub
VERSION="${KAPSTAN_CLI_VERSION:-0.3.14}"
BINARY_NAME="kapstan-${OS}-${ARCH}"
DOWNLOAD_URL="https://github.com/kapstan-io/releases/releases/download/v${VERSION}/${BINARY_NAME}"

echo "Downloading kapstan from $DOWNLOAD_URL..."

curl -L -o kapstan_tmp "$DOWNLOAD_URL"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download the kapstan binary."
    exit 1
fi

# 4. Add permission to execute the binary using chmod +x
chmod +x kapstan_tmp

# 5. Move the binary to the user's local bin and adjust the name
INSTALL_DIR="${KAPSTAN_CLI_INSTALL_DIR:-/usr/local/bin}"

# Check if we have permission to write to INSTALL_DIR
if [ -w "$INSTALL_DIR" ]; then
    mv kapstan_tmp "$INSTALL_DIR/kapstan"
    echo "kapstan has been installed to $INSTALL_DIR/kapstan"
else
    echo "Need sudo privileges to install to $INSTALL_DIR"
    sudo mv kapstan_tmp "$INSTALL_DIR/kapstan"
    echo "kapstan has been installed to $INSTALL_DIR/kapstan"
fi

# Ensure INSTALL_DIR is in PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "Warning: $INSTALL_DIR is not in your PATH."
    echo "Please add $INSTALL_DIR to your PATH environment variable."
fi

mkdir -p ~/.kapstan
sudo chown $USER ~/.kapstan

echo "Installation complete! You can now run 'kapstan' from the command line."
