#!/bin/bash

#Greet
echo "Welcome to the hostname changer."

#Check if dependencies are installed
test -z $(which 'whoami') && exit 1
test -z $(which 'sed') && exit 1
test -z $(which 'hostname') && exit 1
test -z $(which 'getconf') && exit 1
test -z $(which 'wc') && exit 1
echo "You have the tools to run this script!" 

#Test for rights
test "$(whoami)" = "root" && echo "You have the power to alter the hostname!" || { echo "Come back as root!" && exit 1;}

#Prompt new hostname
echo "Enter the new hostname:"
read newhost

#Sanitize
#Delete newline, uppercase to lowercase, delete anything that isn't a letter or a number
newhost=$(echo -n "$newhost" | tr -d "\n" | sed 's/[A-Z]/\L&/g' | sed 's/[^a-z0-9]//g')

#Check length
newhostlength=$(echo -n "$newhost" | wc -c)
maxhostlength=$(getconf HOST_NAME_MAX)
test "$newhostlength" -ge "$maxhostlength" && { echo "Too long!" && exit 1; }

#Evaluate hostname
test -z "$newhost" && { echo "Empty strings are prohibited." && exit 1; }

#Anounce change
echo "Replacing $(hostname) with $newhost"

#Apply change
sed -i "s/$(hostname)/$newhost/g" /etc/hostname
sed -i "s/$(hostname)/$newhost/g" /etc/hosts
