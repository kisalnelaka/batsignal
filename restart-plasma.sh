#!/bin/bash

# BatSignal - Plasma Shell Restart Script
# Use this if the widget doesn't appear after installation

echo "Clearing Plasma cache..."
rm -rf ~/.cache/plasma*
rm -rf ~/.cache/plasmashell*
rm -rf ~/.cache/ksvg-elements-*

echo "Restarting plasmashell..."
killall plasmashell
sleep 2
plasmashell &
disown

echo ""
echo "✓ Done! Plasmashell restarted."
echo "The BatSignal widget should now appear in the widget list."
echo ""
echo "To add the widget:"
echo "1. Right-click on your panel or desktop"
echo "2. Select 'Add Widgets...'"
echo "3. Search for 'BatSignal'"
echo "4. Drag it to your panel or desktop"
