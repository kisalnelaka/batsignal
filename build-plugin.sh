#!/bin/bash

# BatSignal C++ Plugin Build Script

set -e

echo "Building BatSignal C++ Plugin..."
echo "================================="
echo ""

cd plugin

# Clean previous build
echo "Cleaning previous build..."
rm -rf build imports
mkdir -p build

# Generate Makefile
echo "Generating Makefile with qmake6..."
cd build
qmake6 ../batsignalplugin.pro

# Build
echo "Building plugin..."
make -j$(nproc)

# Install
echo "Installing plugin..."
sudo make install

echo ""
echo "✓ Plugin built and installed successfully!"
echo ""
echo "Plugin installed to: $(qmake6 -query QT_INSTALL_QML)/org/kde/plasma/batsignal"
echo ""
echo "Next steps:"
echo "1. Update the widget to use the C++ plugin"
echo "2. Reinstall the widget"
echo "3. Restart plasmashell"
