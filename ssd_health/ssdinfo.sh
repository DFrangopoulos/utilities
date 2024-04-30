#!/bin/bash
#set -x

#Get Info

for file in $(find /dev/ -name "sd[a-z]"); do

	echo "Found --> $file"

	model=$(hdparm -I "$file" | grep "Model Number" | head -n1 | sed -r 's/ //g' | cut -d':' -f2)
	serial=$(hdparm -I "$file" | grep "Serial Number" | head -n1 | sed -r 's/ //g' | cut -d':' -f2)
	timestamp=$(date +'%s')

	if [ ! -z "$model" ] && [ ! -z "$serial" ]; then
		hdparm -I "$file" > ./${model}_${serial}_${timestamp}_info.txt
		smartctl -A "$file" > ./${model}_${serial}_${timestamp}_smart.txt

		chown 1000:1000 ./${model}_${serial}*
	fi

done
