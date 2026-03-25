#!/bin/bash
#log_gen.sh
#A script that creates random new log in attempts for auth_log_tmp.txt to test ssh_guard.sh on

#IP array - to be updated and expanded upon
IP=("192.168.1.20" "192.168.1.10" "172.16.0.45" "10.10.5.122" "192.168.10.201" "172.31.255.14")

#Message to show that things are happening
echo "Generating 20 log entries. This will take 20 seconds..."

#Start loop to create multiple entries at once

for i in {1..20}; do

#Choosing an IP
NUM_IPS=${#IP[@]}
SHUFFLE=$(( RANDOM % NUM_IPS ))
ADDRESS=${IP[SHUFFLE]}

#Creating a guaranteed attacker
	if [[ "$i" -le 5 ]]; then
    ATTACKERS=("10.10.5.122" "172.16.0.45")
    # Pick a random index (0 or 1)
    INDEX=$(( RANDOM % 2 ))
    ADDRESS=${ATTACKERS[$INDEX]}
fi

#Check for authorization
	if [[ "$ADDRESS" == "192.168.1.20" ]]; then
		PASSWORD="Accepted password for user"
	else
		PASSWORD="Failed password for root"
	fi
fi

#Defining variables to plug into formula
TODAY=$(date "+%b %d %H:%M:%S")
MY_PID=$RANDOM

#Showing result
echo "$TODAY server-1 sshd[$RANDOM]: $PASSWORD from $ADDRESS port $RANDOM ssh2" >> auth_log_tmp.txt

echo -n "."
sleep 1

done

echo "Process complete! 20 entries appended to auth_log_tmp.txt."
