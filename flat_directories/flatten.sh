#!/bin/bash

#Directory Flatener

#- create hard links to original files
#- keep a record of (file hash / path / size )
#- do not create new link if hash already exists and size is a match
#- only keep name (append hash if name clobber occurs)
#- hash map ==> map[sha1sum,bytes]=<full_path>


#Check if src / dst dirs exist
if [ ! -d "$1" ] || [ ! -d "$2" ] || [ -z "$3" ]; then
    echo "Invalid Dirs: $0 <src_dir> <dst_dir> <log_file>"
    exit 0;
fi

#create file database
declare -A FDB

#create log file or append
if [ ! -e "$3" ]; then
    touch "$3"
fi
echo "@$(date "+%F %H:%M:%S") Initiated $0 with args: $1 $2 $3" >> "$3"

#for each file in src_dir
find "$1" -type f |
while IFS="" read -r file || [ -n "$file" ]; do

    hash=$(sha1sum "$file" | cut -d" " -f1)
    size=$(stat -c "%s" "$file")
    fpath=$(realpath "$file")
    bpath=$(basename "$file")

    if [ -z "${FDB[${hash},${size}]}" ]; then
        #if empty
        ##1.add entry
        FDB[${hash},${size}]="$fpath"
        ##2.check if hard link exist in dst
        if [ ! -e "$2/${bpath}" ]; then
            ##3.Create Hard Link (name)
            ln "$file" "$2/${bpath}"
            if [[ $? -ne 0 ]]; then
                echo "Attempted clobber detected! Please ensure dst_dir is clean and empty! Exiting..."
                echo "${fpath},${hash},${size} --> clobber exit" >> "$3"
                exit 1
            fi
            status="HL Created: name"
        else
            ##3alt.Create Hard Link (hash_name)
            ln "$file" "$2/${hash}_${bpath}"
            if [[ $? -ne 0 ]]; then
                echo "Attempted clobber detected! Please ensure dst_dir is clean and empty! Exiting..."
                echo "${fpath},${hash},${size} --> clobber exit" >> "$3"
                exit 1
            fi
            status="HL Created: hash_name"
        fi
    else
        status="Already Exists in DB"
    fi
    
    echo "${fpath},${hash},${size}-->${status}" >> "$3"
    
done


