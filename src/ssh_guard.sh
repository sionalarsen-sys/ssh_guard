#!/bin/bash
# Project: SSH Guard - Brute Force Mitigation Tool
# Author:  Siona Larsen
# Date:    March 2026
#
# Description:
# This script monitors system authentication logs for failed login attempts.
# If an IP exceeds a defined threshold, it is dynamically added to an 
# nftables/iptables blocklist to prevent further attacks.
#######################################

# ANSI Color Codes
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (Resets the terminal)
# High-Contrast UI Colors
FOCUS='\033[1;30;46m' # Bold Black text on Cyan Background
INFO='\033[1;33m'     # Bold Yellow for hints

#1. Global Functions

#Helps with pathing to create and move files
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &> /dev/null && pwd) # <--- Add this here!
CONFIG="$PROJECT_ROOT/ssh_guard.conf"
TMP_PATH="$PROJECT_ROOT/../.tmp_log_path"

# Function: Centralized logging for both terminal (if verbose) and audit log
log_msg() {
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    local MSG="$1"
    
    # Write to Audit Log (WITHOUT colors - makes the text file readable)
    if [[ -n "$AUDIT" ]]; then
        echo "[$TIMESTAMP] $MSG" >> "$AUDIT"
    fi

    # Print to Screen (WITH colors)
    if [[ "$VERBOSE" != [Nn]* ]]; then
        case "$MSG" in
            ACTION*)  echo -e "${CYAN}[$TIMESTAMP]${NC} ${RED}$MSG${NC}" ;;
            NOTICE*)  echo -e "${CYAN}[$TIMESTAMP]${NC} ${YELLOW}$MSG${NC}" ;;
            ERROR*)   echo -e "${CYAN}[$TIMESTAMP]${NC} ${RED}$MSG${NC}" ;;
            *)        echo -e "${CYAN}[$TIMESTAMP]${NC} $MSG" ;;
        esac
    fi
}

# Function: Critical errors that always print to screen and log
log_error() {
  local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
    if [[ -n "$AUDIT" ]]; then
        echo "[$TIMESTAMP] ERROR: $1" >> "$AUDIT"
    fi
}

# Allows for users to customize the configuration file to match the file types they use
run_setup() {
    # 1. Setup Environment & Handshake
    local PREFILL=""
    if [[ -f "$TMP_PATH" ]]; then
        PREFILL=$(cat "$TMP_PATH")
    fi

    # 2. Determine the "Smart Default" for the first question
    local DEFAULT_LOG
    if [[ -n "$PREFILL" ]]; then
        DEFAULT_LOG="$PREFILL"
    elif [[ -f "$PROJECT_ROOT/resources/auth_log_tmp.txt" ]]; then
        DEFAULT_LOG="$PROJECT_ROOT/resources/auth_log_tmp.txt"
    else
        DEFAULT_LOG="/var/log/auth.log"
    fi

    echo -e "${YELLOW}--- ⚙️  Setup Configuration ---${NC}"
    [[ -n "$PREFILL" ]] && echo "💡 Found suggested log path from generator: $PREFILL"

 # 3. Gather Inputs with High-contrast Focus Bold
echo -e "${INFO}Tip: Press Enter to keep the default value.${NC}"

# Step 1: Authorization Log
    read -p "$(echo -e "${FOCUS} 1. Authorization Log to monitor [${NC}$DEFAULT_LOG${FOCUS}] ${NC} ")" INPUT_LOG
    LOG_FINAL=${INPUT_LOG:-$DEFAULT_LOG}
    # MOVE CURSOR UP AND OVERWRITE WITH PLAIN TEXT
    echo -e "\033[1A\033[K 1. Authorization Log: ${CYAN}$LOG_FINAL${NC}"

    # Step 2: Fail Log
    read -p "$(echo -e "${FOCUS} 2. Fail log destination [${NC}$PROJECT_ROOT/resources/master_fail_log.txt${FOCUS}] ${NC} ")" INPUT_FAIL
    FAIL_FINAL=${INPUT_FAIL:-"$PROJECT_ROOT/resources/master_fail_log.txt"}
    echo -e "\033[1A\033[K 2. Fail log: ${CYAN}$FAIL_FINAL${NC}"

    # Step 3: Threshold
    read -p "$(echo -e "${FOCUS} 3. Threshold of failures [${NC}5${FOCUS}] ${NC} ")" INPUT_THRESHOLD
    THRESHOLD_FINAL=${INPUT_THRESHOLD:-5}
    echo -e "\033[1A\033[K 3. Threshold: ${CYAN}$THRESHOLD_FINAL${NC}"

    # Step 4: Whitelist
    read -p "$(echo -e "${FOCUS} 4. Whitelisted IP file [${NC}$PROJECT_ROOT/resources/whitelist.txt${FOCUS}] ${NC} ")" INPUT_WHITELIST
    WHITELIST_FINAL=${INPUT_WHITELIST:-"$PROJECT_ROOT/resources/whitelist.txt"}
    echo -e "\033[1A\033[K 4. Whitelisted IP file: ${CYAN}$WHITELIST_FINAL${NC}"

    # Step 5: Audit Log
    read -p "$(echo -e "${FOCUS} 5. Audit Log destination [${NC}$PROJECT_ROOT/resources/audit_log.txt${FOCUS}] ${NC} ")" INPUT_AUDIT
    AUDIT_FINAL=${INPUT_AUDIT:-"$PROJECT_ROOT/resources/audit_log.txt"}
    echo -e "\033[1A\033[K 5. Audit Log: ${CYAN}$AUDIT_FINAL${NC}"

    # Step 6: Verbose
    read -p "$(echo -e "${FOCUS} 6. Detailed output? (y/n) [${NC}y${FOCUS}] ${NC} ")" INPUT_VERBOSE
    VERBOSE_FINAL=${INPUT_VERBOSE:-"y"}
    echo -e "\033[1A\033[K 6. Verbose Output: ${CYAN}$VERBOSE_FINAL${NC}"

    # 4. Create Folders & Save
    mkdir -p "$(dirname "$LOG_FINAL")"
    mkdir -p "$(dirname "$FAIL_FINAL")"
    mkdir -p "$(dirname "$AUDIT_FINAL")"
    mkdir -p "$(dirname "$WHITELIST_FINAL")"

# Seed the whitelist with test data if it's empty or missing
    if [[ ! -s "$WHITELIST_FINAL" ]]; then
        echo "192.168.1.20" > "$WHITELIST_FINAL"  # Your "Admin" IP from log_gen
        echo "192.168.1.10" >> "$WHITELIST_FINAL" # A non-attacker IP that fails
        echo "✅ Created whitelist with default test IPs."
    fi

cat << EOF > "$CONFIG"
LOG="$LOG_FINAL"
FAIL="$FAIL_FINAL"
THRESHOLD="$THRESHOLD_FINAL"
WHITELIST="$WHITELIST_FINAL"
AUDIT="$AUDIT_FINAL"
VERBOSE="$VERBOSE_FINAL"
EOF

    echo -e "${GREEN}✅ Configuration saved to $CONFIG.${NC}"
    source "$CONFIG"
    rm -f "$TMP_PATH"
}

#2. Configuration & Environment

if [[ -f "$CONFIG" ]]; then
    source "$CONFIG"
    FIRST_RUN=false
else
    echo -e "${YELLOW}No configuration found. Starting first-time setup...${NC}"
    run_setup
    FIRST_RUN=true
fi

#3. Interactive Update Option (Only skip if we literally just ran setup)
#To allow for automation, update response timesout after 5 seconds
if [[ "$FIRST_RUN" == false ]]; then
    echo -e "${CYAN}Tip: You have 5 seconds to hit 'y' to change settings...${NC}"
    read -t 5 -p "Would you like to review or update settings? (y/n): " UPDATE
    
    # If the user actually typed 'y'
    if [[ "$UPDATE" == [Yy]* ]]; then
        echo -e "${YELLOW}Current Settings: LOG=$LOG, THRESHOLD=$THRESHOLD${NC}"
        read -p "Update these now? (y/n): " CONFIRM
        [[ "$CONFIRM" == [Yy]* ]] && run_setup
    fi
fi

#4. Main Execution
#clear #removing the clear function for now so all statements can be kept on my screen to be sure they're operating
echo -e "${BLUE}==============================================${NC}"
echo -e "${CYAN}             🛡️  SSH GUARD v1.0               ${NC}"
echo -e "${BLUE}==============================================${NC}"
# This goes to screen AND audit log:
log_msg "Beginning SSH Guard Scan..."

# Verify files exist before running to prevent grep/awk crashes
if [[ ! -f "$LOG" ]]; then
    log_error "Source log not found at $LOG. Check your config (For tests run log_gen.sh)"
    exit 1
fi

#Step 1: Filter log for failures
grep -iE "failed|invalid" "$LOG" >> "$FAIL"

#Step 2: Analyze failures and act
awk '{print $11}' "$FAIL" | sort | uniq -c | while read COUNT IP; do
    if [[ "$COUNT" -ge "$THRESHOLD" ]]; then

	# Security logic: Check Whitelist and Audit (already blocked)
    if grep -q "$IP" "$WHITELIST" 2>/dev/null; then
        log_msg "NOTICE: $IP is whitelisted 🛡️. Skipping block action."
    elif grep -q "$IP" "$AUDIT" 2>/dev/null; then
        #for testing environment
        log_msg "NOTICE: $IP was already processed. No further action."
        continue 
    else
        log_msg "ACTION: Blocking $IP ($COUNT failures detected) 🚫"
        # Future home of: nft add element inet filter blackhole { $IP }
        fi
    fi
done

log_msg "--- Scan Complete ---"

# 5. Testing & Cleanup Logic
echo -e "\n--------------------------------"
read -p "📊 Demo/Testing: Archive all logs to history for a fresh start? (y/n): " CLEANUP

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BASE_DIR="${PROJECT_ROOT}"

if [[ "$CLEANUP" == [Yy]* ]]; then
    HISTORY_DIR="$BASE_DIR/resources/history/$TIMESTAMP"
    mkdir -p "$HISTORY_DIR"
    
    # SURGICAL MOVE: Move logs and failures, but NOT the whitelist
    # This pattern matches auth_log_tmp.txt, master_fail_log.txt, and audit_log.txt
    mv "$BASE_DIR"/resources/*_log*.txt "$HISTORY_DIR/" 2>/dev/null
    
    # Explicitly keep the whitelist by NOT moving it. 
    # If you want to be extra safe, you can 'touch' it to ensure it exists.
    touch "$BASE_DIR/resources/whitelist.txt"
    touch "$BASE_DIR/resources/.gitkeep"
    
    echo -e "${GREEN}🧹 Test environment reset. Logs archived to $HISTORY_DIR${NC}"
    echo -e "${CYAN}🛡️  Whitelist preserved at $BASE_DIR/resources/whitelist.txt${NC}"
    echo "🚀 Ready for a new run of log_gen.sh!"
else
    # Standard Log Rotation (Only the source log)
    if [[ -f "$LOG" ]]; then
        mkdir -p "$BASE_DIR/resources/history"
        mv "$LOG" "$BASE_DIR/resources/history/auth_log_$TIMESTAMP.txt"
        echo -e "${YELLOW}🧹 Active log rotated to history.${NC}"
    fi
fi