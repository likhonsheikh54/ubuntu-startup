#!/bin/bash
# =============================================================================
# Ubuntu Startup and Security Hardening Script
# Author: Likhon Sheikh
# Repository: https://github.com/likhonsheikh54/ubuntu-startup
#
# This script will:
#   - Update and upgrade your system
#   - Install essential security and utility packages
#   - Configure UFW firewall and Fail2Ban for SSH protection
#   - Scan for malware (ClamAV) and rootkits (rkhunter)
#   - Secure the SSH configuration (disable root login)
#   - Prompt you to create a non-root user with sudo privileges,
#     with an option to set up SSH key authentication and disable password login
#   - Set up unattended upgrades for automatic security updates
#
# IMPORTANT: Run this script as root:
#   sudo bash ubuntu-startup.sh
# =============================================================================

# -----------------------------
# Define Color Codes for Output
# -----------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# -----------------------------
# Function: Check if running as root
# -----------------------------
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}[ERROR] This script must be run as root. Use sudo.${NC}"
        exit 1
    fi
}

# -----------------------------
# Function: Update and Upgrade System
# -----------------------------
update_system() {
    echo -e "${BLUE}[INFO] Updating system packages...${NC}"
    apt update && apt upgrade -y
}

# -----------------------------
# Function: Install Essential Packages
# -----------------------------
install_packages() {
    echo -e "${BLUE}[INFO] Installing essential packages...${NC}"
    apt install -y ufw fail2ban sudo curl wget git nano vim unzip zip htop net-tools clamav rkhunter unattended-upgrades
}

# -----------------------------
# Function: Configure UFW Firewall
# -----------------------------
configure_ufw() {
    echo -e "${BLUE}[INFO] Configuring UFW firewall...${NC}"
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow OpenSSH
    ufw --force enable
    echo -e "${GREEN}[SUCCESS] UFW configured.${NC}"
    ufw status verbose
}

# -----------------------------
# Function: Configure Fail2Ban for SSH
# -----------------------------
configure_fail2ban() {
    echo -e "${BLUE}[INFO] Configuring Fail2Ban for SSH protection...${NC}"
    cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
    systemctl restart fail2ban
    echo -e "${GREEN}[SUCCESS] Fail2Ban configured.${NC}"
}

# -----------------------------
# Function: Scan for Malware using ClamAV
# -----------------------------
scan_malware() {
    echo -e "${BLUE}[INFO] Updating ClamAV database and scanning for malware...${NC}"
    freshclam
    clamscan -r / --exclude-dir="^/sys" --exclude-dir="^/proc" --exclude-dir="^/dev"
}

# -----------------------------
# Function: Scan for Rootkits using rkhunter
# -----------------------------
scan_rootkits() {
    echo -e "${BLUE}[INFO] Updating rkhunter and scanning for rootkits...${NC}"
    rkhunter --update
    rkhunter --checkall --skip-keypress
}

# -----------------------------
# Function: Secure SSH Configuration
# -----------------------------
secure_ssh() {
    echo -e "${BLUE}[INFO] Securing SSH configuration...${NC}"
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo -e "${GREEN}[SUCCESS] SSH root login disabled.${NC}"
}

# -----------------------------
# Function: Create a Non-Root User with Sudo Privileges
# -----------------------------
create_non_root_user() {
    echo -e "${BLUE}[INFO] Creating a new non-root user with sudo privileges...${NC}"
    read -p "Enter the new username: " NEW_USER
    adduser "$NEW_USER"
    usermod -aG sudo "$NEW_USER"
    echo -e "${GREEN}[SUCCESS] User '$NEW_USER' created and added to sudo group.${NC}"
    
    read -p "Do you want to set up SSH key authentication for $NEW_USER? (y/n): " SSH_SETUP
    if [ "$SSH_SETUP" == "y" ]; then
        mkdir -p /home/"$NEW_USER"/.ssh
        chmod 700 /home/"$NEW_USER"/.ssh
        read -p "Paste your public SSH key: " SSH_KEY
        echo "$SSH_KEY" > /home/"$NEW_USER"/.ssh/authorized_keys
        chmod 600 /home/"$NEW_USER"/.ssh/authorized_keys
        chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/.ssh
        echo -e "${GREEN}[SUCCESS] SSH key added for $NEW_USER.${NC}"
        read -p "Disable password authentication for SSH? (y/n): " DISABLE_PASS
        if [ "$DISABLE_PASS" == "y" ]; then
            sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
            systemctl restart sshd
            echo -e "${GREEN}[SUCCESS] Password authentication disabled for SSH.${NC}"
        fi
    fi
}

# -----------------------------
# Function: Set Up Unattended Upgrades
# -----------------------------
setup_unattended_upgrades() {
    echo -e "${BLUE}[INFO] Configuring unattended-upgrades...${NC}"
    dpkg-reconfigure -plow unattended-upgrades
}

# -----------------------------
# Main Function
# -----------------------------
main() {
    check_root
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW} Ubuntu Startup & Security Hardening Script ${NC}"
    echo -e "${YELLOW} Repository: https://github.com/likhonsheikh54/ubuntu-startup ${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    update_system
    install_packages
    configure_ufw
    configure_fail2ban
    scan_malware
    scan_rootkits
    secure_ssh
    create_non_root_user
    setup_unattended_upgrades

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}[SUCCESS] VPS hardening complete!${NC}"
    echo -e "${GREEN}You can now log in with your new non-root user.${NC}"
    echo -e "${GREEN}========================================${NC}"
}

main
