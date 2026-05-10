#!/bin/bash

# --- 1. Colors and Branding ---
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m'

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Please run as root${NC}"
   exit 1
fi

# Function to perform a quick system audit
run_audit() {
    echo -e "${CYAN}Running System Audit...${NC}"
    
    # Check if x-ui is installed
    if ! command -v x-ui &> /dev/null; then
        PANEL_STATUS="${RED}NOT INSTALLED${NC}"
    else
        # Check if service is active
        if systemctl is-active --quiet x-ui; then
            PANEL_STATUS="${GREEN}RUNNING${NC}"
        else
            PANEL_STATUS="${YELLOW}STOPPED${NC}"
        fi
    fi

    # Detect Panel Port
    # We try to find it from x-ui settings or netstat
    CURRENT_PORT=$(ss -tulnp | grep x-ui | awk '{print $5}' | cut -d':' -f2 | head -n 1)
    if [ -z "$CURRENT_PORT" ]; then
        CURRENT_PORT="Unknown"
    fi

    # Get Public IP
    CURRENT_IP=$(curl -s --max-time 2 https://api.ipify.org || echo "IP Timeout")

    # Resource Load
    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    RAM_USAGE=$(free -m | awk '/Mem:/ { printf("%3.1f%%", $3/$2*100) }')
}

# --- Main Loop ---
while true; do
    run_audit
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}           d0ct0rvrach | SERVER DASHBOARD           ${NC}"
    echo -e "${CYAN}             lazy-Flash Management Tool             ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${BLUE}Panel Status:${NC}   $PANEL_STATUS"
    echo -e "${BLUE}Public IP:${NC}      $CURRENT_IP"
    echo -e "${BLUE}Active Port:${NC}    $CURRENT_PORT"
    echo -e "${BLUE}CPU Load:${NC}       $CPU_LOAD      ${BLUE}RAM Usage:${NC} $RAM_USAGE"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "${WHITE}1${NC} - Open X-UI Native Menu"
    echo -e "${WHITE}2${NC} - Restart 3X-UI Service"
    echo -e "${WHITE}3${NC} - View Live Logs (Tail)"
    echo -e "${WHITE}4${NC} - Network Diagnostics (Netstat)"
    echo -e "${WHITE}5${NC} - Update / Reinstall Panel"
    echo -e "${WHITE}6${NC} - BBR / Speed Optimization (Check)"
    echo -e "${WHITE}9${NC} - Security Passport"
    echo -e "${RED}0 - EXIT${NC}"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    read -p "Selection: " choice

    case $choice in
        1) x-ui ;;
        2) 
           echo -e "${YELLOW}Restarting...${NC}"
           x-ui restart
           sleep 2
           ;;
        3) 
           if [ -f /etc/x-ui/x-ui.log ]; then 
               echo -e "${YELLOW}Press Ctrl+C to stop viewing logs${NC}"
               tail -f /etc/x-ui/x-ui.log
           else 
               echo -e "${RED}Log file not found.${NC}"
               sleep 2
           fi 
           ;;
        4) 
           netstat -tulnp | grep LISTEN
           read -p "Press Enter..." 
           ;;
        5) 
           echo -e "${YELLOW}Starting Reinstaller...${NC}"
           bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
           ;;
        6)
           echo -e "${BLUE}TCP Congestion Control:${NC} $(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')"
           read -p "Press Enter..."
           ;;
        9)
           echo -e "${CYAN}--- Security Quick-Check ---${NC}"
           echo -e "Port $CURRENT_PORT is currently open."
           if [ "$CURRENT_PORT" == "2053" ]; then echo -e "${RED}[!] WARNING: You are using default port.${NC}"; fi
           read -p "Press Enter..."
           ;;
        0) clear; exit 0 ;;
        *) echo -e "${RED}Invalid input!${NC}"; sleep 1 ;;
    esac
done
