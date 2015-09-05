#!/bin/bash

#Shellscript based on @brutelogic's 1-line url mapper:
#for w in $(cat WORDLIST); do printf %20s "$w: "; curl -s http://TARGET/$w -i | grep HTTP; done

usage="USAGE: $0 -u URL -w WORDLIST"

while getopts w:u: opt 2> /dev/null ; do
	case $opt in

		u)
			target=$OPTARG
			;;

		w)
			wordlist=$(cat $OPTARG)
			;;

		?)
			echo "$usage"
			exit 1
			;;
	esac
done

if [[ -z $target ]] || [[ -z $wordlist ]]; then
	echo "$usage"
	exit 1
fi

# Calculate offset so results are in one line

wl=$(
	for cnt in $wordlist; do
		printf "$cnt" | wc -c
	done | sort -nr | head -n 1
);


if [ "$wl" -gt "50" ];then
	wl="50"
else
	wl=$[$wl+5]
fi

# print the statuscode for every entry in $wordlist
for w in $wordlist; do
	printf %"$wl"s "$w: "
	curl -s $target/$w -I -X GET | grep "HTTP/" | cut -d " " -f 2-
# -s - silent mode, -I only show header, -X GET force curl to use GET, so it
# will also work if HEAD isn't allowed, only grep the HTTP/1.1... part, cut
# -f 2- to show statuscode and explanation (200 OK).
# Use -f 2 to show only 200, 404... and -f 3- to show only OK, NOT FOUND, etc.
done
