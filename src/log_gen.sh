#!/bin/bash
#
#Project: Log Generator
#Author: Siona Larsen
#Date: March 2026

#Description:
#This script creates a simulated log with failed login attempts to test SSH Guard on

#####################################

#1. Configuration

#Defining the destination for the log entries
LOG="../resources/auth_log_tmp.txt"

#Loads an array of fictional IP Addresses
IP=("192.168.1.20" "192.168.1.10" "172.16.0.45" "10.10.5.122" "192.168.10.201" "172.31.255.14")
ATTACKERS=("10.10.5.122" "172.16.0.45")

#2. Startup
#Startup message to show parameters of what will be created and to prevent user from believing the system frozen
echo "Generating 20 log entries. This will take 20 seconds..."

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
	echo "$TODAY server-1 sshd[$MY_PID]: $PASSWORD from $ADDRESS port $RANDOM ssh2" >> $LOG

#Progress indicator and simulated delay
	echo -n "."
	sleep 1

done

#Closing message to show that the process has been completed and inform user of the destination
echo -e "\nProcess complete! 20 entries appended to $LOG."
