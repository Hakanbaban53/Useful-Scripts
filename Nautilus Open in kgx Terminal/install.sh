#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Interrupt handler function
trap ctrl_c INT
function ctrl_c() {
    echo -e "\n${RED}Installation interrupted by the user. Exiting...${NC}"
    exit 1
}

# Welcome message
echo -e "${BLUE}Welcome to the Nautilus extension manager for GNOME Console (KGX)!${NC}"

# Ask to install or remove the extension
echo -e "${YELLOW}Do you want to install or remove this extension?${NC}"
echo -e "${GREEN}1)${NC} Install"
echo -e "${GREEN}2)${NC} Remove"
read -p "Enter your choice (1/2): " action_choice

if [ "$action_choice" -eq 1 ]; then
    # Installation process
    echo -e "${YELLOW}Do you want to install this extension globally or for the current user only?${NC}"
    echo -e "${GREEN}1)${NC} Global (requires sudo)"
    echo -e "${GREEN}2)${NC} User only"
    read -p "Enter your choice (1/2): " choice

    # Set the target directory based on the choice
    if [ "$choice" -eq 1 ]; then
        INSTALL_DIR="/usr/share/nautilus-python/extensions"
        echo -e "${YELLOW}You chose global installation.${NC} This will require ${RED}sudo${NC} privileges."
        sudo mkdir -p "$INSTALL_DIR"
    else
        INSTALL_DIR="$HOME/.local/share/nautilus-python/extensions"
        echo -e "${YELLOW}You chose user installation.${NC} The extension will be installed in ${GREEN}$INSTALL_DIR${NC}."
        mkdir -p "$INSTALL_DIR"
    fi

    # Copy the Python extension script
    cp nautilus-open-kgx.py "$INSTALL_DIR/"

    # Set permissions
    if [ "$choice" -eq 1 ]; then
        sudo chmod +x "$INSTALL_DIR/nautilus-open-kgx.py"
    else
        chmod +x "$INSTALL_DIR/nautilus-open-kgx.py"
    fi

    echo -e "${GREEN}Installation completed successfully!${NC}"

    # Ask to restart Nautilus
    read -p "Do you want to restart Nautilus now to activate the extension? (y/n): " restart_choice
    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Restarting Nautilus...${NC}"
        nautilus -q
        echo -e "${GREEN}Nautilus has been restarted. The extension is now active!${NC}"
    else
        echo -e "${BLUE}You chose not to restart Nautilus. Please restart it later to activate the extension.${NC}"
    fi

elif [ "$action_choice" -eq 2 ]; then
    # Removal process
    echo -e "${YELLOW}Do you want to remove the extension globally or for the current user only?${NC}"
    echo -e "${GREEN}1)${NC} Global (requires sudo)"
    echo -e "${GREEN}2)${NC} User only"
    read -p "Enter your choice (1/2): " remove_choice

    if [ "$remove_choice" -eq 1 ]; then
        REMOVE_DIR="/usr/share/nautilus-python/extensions"
        echo -e "${YELLOW}You chose to remove the global installation.${NC} This will require ${RED}sudo${NC} privileges."
        if sudo rm -f "$REMOVE_DIR/nautilus-open-kgx.py"; then
            echo -e "${GREEN}The extension has been removed successfully from the global directory.${NC}"
        else
            echo -e "${RED}Failed to remove the extension. It may not exist or require additional permissions.${NC}"
        fi
    else
        REMOVE_DIR="$HOME/.local/share/nautilus-python/extensions"
        echo -e "${YELLOW}You chose to remove the user installation.${NC}"
        if rm -f "$REMOVE_DIR/nautilus-open-kgx.py"; then
            echo -e "${GREEN}The extension has been removed successfully from the user directory.${NC}"
        else
            echo -e "${RED}Failed to remove the extension. It may not exist.${NC}"
        fi
    fi

    # Ask to restart Nautilus
    read -p "Do you want to restart Nautilus now to apply the changes? (y/n): " restart_choice
    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Restarting Nautilus...${NC}"
        nautilus -q
        echo -e "${GREEN}Nautilus has been restarted. The changes have been applied!${NC}"
    else
        echo -e "${BLUE}You chose not to restart Nautilus. Please restart it later to apply the changes.${NC}"
    fi
else
    echo -e "${RED}Invalid choice. Exiting.${NC}"
fi
