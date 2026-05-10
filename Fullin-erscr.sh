#!/bin/bash

# --- 1. Colors and Branding ---
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m'

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Please run this script as root (sudo)${NC}"
   exit 1
fi

# --- INTERNET CHECK ---
clear
echo -e "${CYAN}Checking internet connectivity...${NC}"
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}Internet: Connected${NC}"
else
    echo -e "${RED}Internet: Disconnected! Please check your network.${NC}"
    exit 1
fi

# --- INTELLIGENT CHECK-UP ---
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}           SYSTEM CHECK-UP BEFORE INSTALL           ${NC}"
echo -e "${CYAN}             d0ct0rvrach | lazy-Flash               ${NC}"
echo -e "${CYAN}====================================================${NC}"

# OS Identification
OS_NAME=$(grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '"')
echo -e "${BLUE}OS Name:${NC} $OS_NAME"

# Arch and Virt identification
ARCH=$(uname -m)
VIRT=$(hostnamectl | grep "Virtualization" | awk '{print $2}')
echo -e "${BLUE}Architecture:${NC} $ARCH (Virt: ${VIRT:-Physical})"

# RAM Check
RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
RAM_FREE=$(free -m | awk '/^Mem:/{print $4}')
echo -e "${BLUE}RAM:${NC} Total ${RAM_TOTAL}MB (Free ${RAM_FREE}MB)"

# IP and Reputation Check
IP_INFO=$(curl -s https://ipapi.co/json/)
REAL_IP=$(echo $IP_INFO | jq -r '.ip' 2>/dev/null || curl -s https://api.ipify.org)
CITY=$(echo $IP_INFO | jq -r '.city' 2>/dev/null || echo "Unknown")
COUNTRY=$(echo $IP_INFO | jq -r '.country_name' 2>/dev/null || echo "Unknown")
echo -e "${BLUE}Public IP:${NC} $REAL_IP ($CITY, $COUNTRY)"

echo -ne "${BLUE}IP Reputation (Proxy/VPN/Tor):${NC} "
IP_CHECK=$(curl -s "https://demo.ip-api.com/json/$REAL_IP?fields=66846719" -H "Origin: https://ip-api.com")
IS_PROXY=$(echo $IP_CHECK | jq -r '.proxy' 2>/dev/null)
if [[ "$IS_PROXY" == "true" ]]; then
    echo -e "${RED}IP flagged as Proxy/Hosting (possible blocks)${NC}"
else
    echo -e "${GREEN}Clean (Resident/Mobile/Unknown)${NC}"
fi

# Port check 80/443
echo -ne "${BLUE}Standard Ports 80/443 Check:${NC} "
if ss -tuln | grep -qE ":(80|443) "; then
    echo -e "${YELLOW}Busy (Manual setup might be needed)${NC}"
else
    echo -e "${GREEN}Available${NC}"
fi

# --- PORT SELECTION LOGIC ---
echo -e "${CYAN}----------------------------------------------------${NC}"
DEFAULT_PORT="2053"
echo -e "${YELLOW}Default Panel Port is set to: ${GREEN}$DEFAULT_PORT${NC}"
read -p "Keep this port? (y) or Change/List free ports? (n): " keep_port

if [[ "$keep_port" == "n" ]]; then
    echo -e "${YELLOW}Scanning for common available ports...${NC}"
    SUGGESTED_PORTS=(2053 2083 2087 2096 8443)
    AVAILABLE_PORTS=()
    for p in "${SUGGESTED_PORTS[@]}"; do
        if ! ss -tuln | grep -q ":$p "; then
            AVAILABLE_PORTS+=($p)
        fi
    done
    echo -e "${BLUE}Available recommended ports:${NC} ${GREEN}${AVAILABLE_PORTS[*]}${NC}"
    read -p "Enter your desired port: " PANEL_PORT
else
    PANEL_PORT=$DEFAULT_PORT
fi

echo -e "${CYAN}====================================================${NC}"
read -p "Press [Enter] to start 3X-UI Installation..."
clear

# --- START INSTALLATION ---
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}           3X-UI ONLY INSTALLATION (LAZY)           ${NC}"
echo -e "${CYAN}             d0ct0rvrach | lazy-Flash               ${NC}"
echo -e "${CYAN}====================================================${NC}"

# Helper function
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 failed.${NC}"
        exit 1
    fi
}

# System Preparation
echo -e "${BLUE}Updating packages and installing dependencies...${NC}"
if [ -f /etc/debian_version ]; then
    apt update && apt install -y curl sqlite3 jq software-properties-common net-tools logrotate
elif [ -f /etc/redhat-release ]; then
    dnf makecache && dnf install -y sqlite jq net-tools logrotate
else
    echo -e "${RED}OS not supported.${NC}"
    exit 1
fi
check_status "System preparation"

# IPv6 Setup
echo -e "${GREEN}IPv6 Settings:${NC}"
read -t 10 -p "Disable IPv6? (y/n, default n): " disable_ipv6_choice
if [[ "$disable_ipv6_choice" == "y" ]]; then
    echo -e "${YELLOW}Disabling IPv6...${NC}"
    sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p > /dev/null 2>&1
    echo -e "${GREEN}IPv6 disabled.${NC}"
fi

# 3X-UI Install
echo -e "${BLUE}Installing panel on port $PANEL_PORT...${NC}"
export X_UI_ADMIN="admin"
export X_UI_PASSWORD="admin"
export X_UI_PORT="$PANEL_PORT"

bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) <<EOF
y
admin
admin
$PANEL_PORT
EOF
check_status "3X-UI Installation"

# Logrotate setup
echo -e "${BLUE}Configuring log rotation...${NC}"
cat > /etc/logrotate.d/3x-ui <<EOF
/etc/x-ui/x-ui.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
}
EOF

# Firewall setup
if command -v ufw >/dev/null; then
    ufw allow $PANEL_PORT/tcp >/dev/null 2>&1
    ufw allow 80/tcp >/dev/null 2>&1
    ufw allow 443/tcp >/dev/null 2>&1
fi

# --- INTERACTIVE DASHBOARD ---
RAW_IP=$(curl -s --max-time 5 https://api.ipify.org || hostname -I | awk '{print $1}')

while true; do
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}          🎉 INSTALLATION SUCCESSFUL!              ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}             🔑 SERVER PASSPORT & KEYS             ${NC}"
    echo -e "${CYAN}             d0ct0rvrach | lazy-Flash               ${NC}"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "${BLUE}Panel URL:${NC}      http://$RAW_IP:$PANEL_PORT"
    echo -e "${BLUE}Login/Pass:${NC}     admin / admin"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "${WHITE}1${NC} - Open x-ui management menu"
    echo -e "${WHITE}2${NC} - Show current Server IP"
    echo -e "${WHITE}3${NC} - Restart 3X-UI Panel"
    echo -e "${WHITE}4${NC} - Check Service Status (systemctl)"
    echo -e "${WHITE}5${NC} - View last 20 log lines"
    echo -e "${WHITE}6${NC} - Check Listen Ports (netstat)"
    echo -e "${WHITE}7${NC} - Show CPU/RAM Load"
    echo -e "${WHITE}8${NC} - Reinstall / Update Panel"
    echo -e "${WHITE}9${NC} - Security Tips"
    echo -e "${RED}0 - EXIT SCRIPT${NC}"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    read -p "Select action [0-9]: " choice

    case $choice in
        1) x-ui ;;
        2) echo -e "${GREEN}Your IP:${NC} $RAW_IP"; read -p "Press Enter..." ;;
        3) x-ui restart ;;
        4) systemctl status x-ui; read -p "Press Enter..." ;;
        5) if [ -f /etc/x-ui/x-ui.log ]; then tail -n 20 /etc/x-ui/x-ui.log; else echo "Log file not found yet."; fi; read -p "Press Enter..." ;;
        6) netstat -tulnp | grep LISTEN; read -p "Press Enter..." ;;
        7) top -b -n 1 | head -n 12; read -p "Press Enter..." ;;
        8) 
           echo -e "${YELLOW}Running Reinstallation...${NC}"
           bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
           ;;
        9)
           echo -e "${CYAN}--- Security Advice ---${NC}"
           echo -e "1. Change 'admin' login immediately."
           echo -e "2. Use a non-standard port (e.g., 45921)."
           echo -e "3. Setup Reality (VLESS) for traffic camouflage."
           read -p "Press Enter..."
           ;;
        0) echo -e "${GREEN}Happy tunneling!${NC}"; break ;;
        *) echo -e "${RED}Invalid input!${NC}"; sleep 1 ;;
    esac
done
