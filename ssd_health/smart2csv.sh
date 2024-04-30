#!/bin/bash

#Process Info
for file in *smart.txt; do

        echo "Procesing --> $file"
        identifier=$(echo "$file" | sed -r 's/^([^_]+)_([^_]+)_.*/\1_\2/')
        timestamp=$(echo "$file" | sed -rn 's/^[^_]+_[^_]+_([^_]+)_.*/\1/p')
	if [ -z "$timestamp" ]; then
		birthtime=$(stat -c "%W" "$file")
		new_name=$(echo "$file" | sed -r "s/^([^_]+)_([^_]+)_.*/\1_\2_${birthtime}_smart.csv/")
		timestamp=$(echo "$birthtime")
	else
	        new_name=$(echo "$file" | rev | sed -r 's/^txt/vsc/' | rev)
	fi

        grep -E "^[ ]*[0-9]+ " "$file" | sed -r -e 's/^[ ]+//' -e 's/[ ]+/ /g' | sed -r -e "s/^/${identifier} ${timestamp} /" -e 's/ /,/g' | cut -d',' -f-12 > ./${new_name}

done

#Concatenate Info
if [ -f "./all.csv" ]
then
        mv all.csv all.csv.tmp
        cat *.csv all.csv.tmp | sort -u > all.csv
        rm all.csv.tmp
else
        cat *.csv | sort -u > all.csv
fi
