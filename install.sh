#!/bin/bash

# BatSignal Widget Installation Script using CMake

set -e

echo "========================================="
echo "BatSignal Widget - Installation"
echo "========================================="
echo ""

# Check for CMake
if ! command -v cmake &> /dev/null; then
    echo "Error: cmake is required but not installed."
    echo "Please install 'cmake' and 'extra-cmake-modules'."
    exit 1
fi

# Build and Install
echo "Step 1: Configuring..."
cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/usr

echo ""
echo "Step 2: Building..."
cmake --build build -j$(nproc)

echo ""
echo "Step 3: Installing (requires sudo)..."
sudo cmake --install build

# Restart Plasma
echo ""
echo "Step 4: Restarting plasmashell..."
echo "Clearing cache..."
rm -rf ~/.cache/plasma* ~/.cache/plasmashell* ~/.cache/ksvg-elements-* 2>/dev/null

echo "Restarting plasmashell..."
killall plasmashell 2>/dev/null
sleep 2
plasmashell &
disown

echo ""
echo "✓ Installation complete!"
echo ""
echo "To add the widget:"
echo "1. Right-click on your panel"
echo "2. Select 'Add Widgets...'"
echo "3. Search for 'BatSignal'"
echo "4. Drag it to your panel"
