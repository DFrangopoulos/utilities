#!/bin/sh
# $1 = original_file
# $2 = modified_file

#Delete comments/spaces/tabs/newlines
#Ignore stderr
#Grab verything after the function identifier
#Use awk to count brackets and isolate function
#Hash it

>/tmp/temp_sto

ctags -x --c-kinds=fp $1 | sed "s/ \+/ /g" | cut -d" " -f5- | cut -d"(" -f1 | tr -d "\t" | tr -d "[:blank:]" > /tmp/temp_sto
ctags -x --c-kinds=fp $2 | sed "s/ \+/ /g" | cut -d" " -f5- | cut -d"(" -f1 | tr -d "\t" | tr -d "[:blank:]" >> /tmp/temp_sto

cat /tmp/temp_sto | sort -u | grep -v "^$" > /tmp/temp_sto_sorted


extarct_n_hash ()
{
cat "$1" |  gcc -E -P -fpreprocessed - 2>/dev/null | tr -d "[:blank:]" | tr -d "\t" | tr -d "\n" | sed -r "s/.*($2.*)/\1/" | grep "$2" | \
awk '{if($0 == ""){exit}; split($0, chars, ""); opening_brackets=0; closing_brackets=0; for(i=1; i <= length($0); i++){printf("%s",chars[i]); if(chars[i]=="{"){opening_brackets++}; if(chars[i]=="}"){closing_brackets++}; if((opening_brackets>0)&&(opening_brackets==closing_brackets)){exit;}};}' | \
xargs -r -I {} sh -c 'echo -n "{}" | sha1sum | cut -d"-" -f1' 
}



while read func
do
	orig=$(extarct_n_hash "$1" "$func"); 
	mod=$(extarct_n_hash "$2" "$func"); 
	if [ "$orig" = "$mod" ]
	then 
		echo "MATCH $func"
	else 
		if [ -z "$mod" ]
		then
			echo "NOT IN MOD $func"
		elif [ -z "$orig" ]
		then
			echo "NOT IN ORIG $func"
		else
			echo "NO MATCH $func"
		fi
	fi
	
	
done < /tmp/temp_sto_sorted
