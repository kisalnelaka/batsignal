#!/bin/bash

# BatSignal - BlueZ Experimental Features Helper
# This script helps enable/disable experimental features in BlueZ

set -e

CONFIG_FILE="/etc/bluetooth/main.conf"
BACKUP_FILE="/etc/bluetooth/main.conf.backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run with sudo${NC}"
        echo "Usage: sudo $0 [enable|disable|status]"
        exit 1
    fi
}

# Check current status
check_status() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Error: $CONFIG_FILE not found${NC}"
        exit 1
    fi
    
    if grep -q "^Experimental[[:space:]]*=[[:space:]]*true" "$CONFIG_FILE"; then
        return 0  # Enabled
    else
        return 1  # Disabled
    fi
}

# Show status
show_status() {
    if check_status; then
        echo -e "${GREEN}✓ BlueZ experimental features are ENABLED${NC}"
    else
        echo -e "${YELLOW}✗ BlueZ experimental features are DISABLED${NC}"
    fi
}

# Enable experimental features
enable_experimental() {
    echo "Enabling BlueZ experimental features..."
    
    # Create backup if it doesn't exist
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "Creating backup at $BACKUP_FILE"
        cp "$CONFIG_FILE" "$BACKUP_FILE"
    fi
    
    # Check if [General] section exists
    if ! grep -q "^\[General\]" "$CONFIG_FILE"; then
        echo "Adding [General] section to config"
        echo -e "\n[General]\nExperimental = true" >> "$CONFIG_FILE"
    else
        # Check if Experimental line exists
        if grep -q "^#*[[:space:]]*Experimental" "$CONFIG_FILE"; then
            # Uncomment and set to true
            sed -i 's/^#*[[:space:]]*Experimental[[:space:]]*=.*/Experimental = true/' "$CONFIG_FILE"
        else
            # Add under [General] section
            sed -i '/^\[General\]/a Experimental = true' "$CONFIG_FILE"
        fi
    fi
    
    echo -e "${GREEN}✓ Experimental features enabled${NC}"
    echo "Restarting Bluetooth service..."
    systemctl restart bluetooth
    echo -e "${GREEN}✓ Bluetooth service restarted${NC}"
    echo ""
    echo "You may need to reconnect your Bluetooth devices."
}

# Disable experimental features
disable_experimental() {
    echo "Disabling BlueZ experimental features..."
    
    # Comment out or set to false
    if grep -q "^Experimental[[:space:]]*=[[:space:]]*true" "$CONFIG_FILE"; then
        sed -i 's/^Experimental[[:space:]]*=.*/#Experimental = false/' "$CONFIG_FILE"
    fi
    
    echo -e "${GREEN}✓ Experimental features disabled${NC}"
    echo "Restarting Bluetooth service..."
    systemctl restart bluetooth
    echo -e "${GREEN}✓ Bluetooth service restarted${NC}"
}

# Main script
case "${1:-status}" in
    enable)
        check_root
        if check_status; then
            echo -e "${YELLOW}Experimental features are already enabled${NC}"
        else
            enable_experimental
        fi
        ;;
    disable)
        check_root
        if ! check_status; then
            echo -e "${YELLOW}Experimental features are already disabled${NC}"
        else
            disable_experimental
        fi
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 [enable|disable|status]"
        echo ""
        echo "Commands:"
        echo "  enable  - Enable BlueZ experimental features (requires sudo)"
        echo "  disable - Disable BlueZ experimental features (requires sudo)"
        echo "  status  - Check current status (no sudo required)"
        exit 1
        ;;
esac
