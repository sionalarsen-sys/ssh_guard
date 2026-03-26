#!/bin/bash
#
#Project: Log Generator
#Author: Siona Larsen
#Date: March 2026

#Description:
#This script creates a simulated log with failed login attempts to test SSH Guard on

#####################################

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (Resets the terminal)

#1. Configuration

# 1. Locate the script
# 1. Configuration

# Get the Absolute Path to the project root
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &> /dev/null && pwd)

CONFIG="$PROJECT_ROOT/ssh_guard.conf"
TMP_PATH="$PROJECT_ROOT/.tmp_log_path"

# 2. Check for Config or define the log path
if [[ -f "$CONFIG" ]]; then
    # If the user already ran setup, we use the path they chose
    source "$CONFIG"
    echo "📂 Using existing log path from config: $LOG"
else
    echo "⚠️ No configuration found."
    # We offer the Absolute Path as the default now!
    DEFAULT_LOG="$PROJECT_ROOT/resources/auth_log_tmp.txt"
    
    read -p "Where should I create the test log? [$DEFAULT_LOG]: " USER_LOG
    
    # Use the absolute default if user just hits Enter
    LOG=${USER_LOG:-"$DEFAULT_LOG"}
    
    # Ensure the directory exists BEFORE saving the path
    mkdir -p "$(dirname "$LOG")"
    
    # Save this path so the Guard script can find it later
    echo "$LOG" > "$TMP_PATH"
    echo "✅ Handshake created at $TMP_PATH"
    echo "🚀 Run 'src/ssh_guard.sh' next to finish setup."
fi


#Loads an array of fictional IP Addresses
IP=("192.168.1.20" "192.168.1.10" "172.16.0.45" "10.10.5.122" "192.168.10.201" "172.31.255.14")
ATTACKERS=("10.10.5.122" "172.16.0.45")

#2. Startup
#Startup message to show parameters of what will be created and to prevent user from believing the system frozen
echo "Generating 20 log entries. This will take 2 seconds..."

# Ensure the directory exists before we try to write to it
mkdir -p "$(dirname "$LOG")"

#Start loop to create multiple entries at once

for i in {1..20}; do

	#Choosing a base random IP
	NUM_IPS=${#IP[@]}
	SHUFFLE=$(( RANDOM % NUM_IPS ))
	ADDRESS=${IP[SHUFFLE]}

	#Override: Ensure test coverage by forcing attackers in early rounds
	if [[ "$i" -le 5 ]]; then
    	INDEX=$(( RANDOM % 2 ))
    	ADDRESS=${ATTACKERS[$INDEX]}
	fi

	#Authorization check: Differentiate between admin and unauthorized attempts
	if [[ "$ADDRESS" == "192.168.1.20" ]]; then
		PASSWORD="Accepted password for user"
	else
		PASSWORD="Failed password for root"
	fi

	#Generate dynamic log components
	TODAY=$(date "+%b %d %H:%M:%S")
	# Using a sub-variable for the PID shows attention to detail
    MY_PID=$(( RANDOM % 65535 ))

	#Append formatted entry to log file
	echo "$TODAY server-1 sshd[$MY_PID]: $PASSWORD from $ADDRESS port $RANDOM ssh2" >> "$LOG"

#Progress indicator and simulated delay
	echo -e -n "${CYAN}⚡${NC}"
	sleep 0.2

done

#Closing message to show that the process has been completed and inform user of the destination
echo -e "\nProcess complete! 20 entries appended to $LOG."
