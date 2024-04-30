#!/bin/bash

if [ ! -d "$1" ] || [ ! -d "$2" ]; then
	exit 1
fi

tree -si "$1" > cmp1.txt
tree -si "$2" > cmp2.txt

diff -y cmp1.txt cmp2.txt | grep -vE "cmp[0-9].txt"

rm cmp1.txt cmp2.txt

exit 0
