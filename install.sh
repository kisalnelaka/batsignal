#!/bin/bash

# Complete installation script for BatSignal widget

set -e

echo "========================================="
echo "BatSignal Widget - Complete Installation"
echo "========================================="
echo ""

# Step 1: Build and install C++ plugin
echo "Step 1: Building C++ plugin..."
cd plugin
qmake6 batsignalplugin.pro
make -j$(nproc)

echo ""
echo "Step 2: Installing C++ plugin (requires sudo)..."
sudo make install

cd ..

# Step 2: Install widget
echo ""
echo "Step 3: Installing widget package..."
kpackagetool6 --type=Plasma/Applet --upgrade package 2>/dev/null || \
    kpackagetool6 --type=Plasma/Applet --install package

# Step 3: Restart plasmashell
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
echo ""
echo "Note: Make sure BlueZ experimental features are enabled:"
echo "  sudo ./enable-bluez-experimental.sh enable"
