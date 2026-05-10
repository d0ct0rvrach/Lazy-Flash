#!/bin/bash

# --- Colors and Branding ---
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Please run as root (sudo)${NC}"
   exit 1
fi

# Function to check current IPv6 status
check_ipv6_status() {
    # Check if IPv6 is disabled in sysctl
    local disabled=$(sysctl -n net.ipv6.conf.all.disable_ipv6)
    
    # Check if there are active IPv6 addresses (excluding loopback)
    local has_addr=$(ip -6 addr show scope global)

    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}           IPv6 STATUS DIAGNOSTICS                  ${NC}"
    echo -e "${CYAN}====================================================${NC}"

    if [ "$disabled" -eq 1 ]; then
        echo -e "System Setting: ${RED}DISABLED${NC} (via sysctl)"
    else
        echo -e "System Setting: ${GREEN}ENABLED${NC}"
    fi

    if [ -n "$has_addr" ]; then
        echo -e "Network Interface: ${GREEN}ACTIVE${NC}"
        echo -e "${BLUE}Global IPv6 Addresses:${NC}"
        echo "$has_addr" | grep "inet6" | awk '{print " -> " $2}'
    else
        echo -e "Network Interface: ${RED}NO GLOBAL ADDRESS${NC}"
    fi
    echo -e "${CYAN}====================================================${NC}"
}

# Function to disable IPv6
disable_ipv6() {
    echo -e "${YELLOW}Disabling IPv6...${NC}"
    sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
    
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    
    sysctl -p > /dev/null 2>&1
    echo -e "${GREEN}IPv6 has been disabled successfully.${NC}"
}

# Function to enable IPv6
enable_ipv6() {
    echo -e "${YELLOW}Enabling IPv6...${NC}"
    sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
    
    echo "net.ipv6.conf.all.disable_ipv6 = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 0" >> /etc/sysctl.conf
    
    sysctl -p > /dev/null 2>&1
    echo -e "${GREEN}IPv6 has been enabled successfully.${NC}"
}

# --- Main Menu ---
while true; do
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}           d0ct0rvrach | IPv6 MANAGER               ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    check_ipv6_status
    echo -e "${WHITE}1${NC} - ${RED}DISABLE${NC} IPv6"
    echo -e "${WHITE}2${NC} - ${GREEN}ENABLE${NC} IPv6"
    echo -e "${WHITE}3${NC} - Refresh Status"
    echo -e "${WHITE}0${NC} - Exit"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    read -p "Select an option: " choice

    case $choice in
        1) disable_ipv6; read -p "Press Enter to continue..." ;;
        2) enable_ipv6; read -p "Press Enter to continue..." ;;
        3) continue ;;
        0) echo -e "${BLUE}Exiting IPv6 Manager. Goodbye!${NC}"; break ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
    esac
done
