#!/bin/bash

### spinner ###
spinner()
{
    local pid=$1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep .1
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

### measuring ###
run()
{
	local host=$1
	local attempts=$2
	local avg_time=0

	for ((idx=1; idx<=$attempts; idx++)); do
		printf "Attempt $idx of $attempts. Time: ";
		(curl -w "%{time_total}" -o . -s "$host" > out.txt) &
		spinner $!
		read -r t<out.txt
		printf "$t s\n"
		if [ $attempts -gt 1 ]; then avg_time=$(echo "scale=3;$avg_time+$t" | bc); fi
	done

	rm out.txt
	if [ $attempts -gt 1 ];	then 
		avg_time=$(echo "scale=3;$avg_time/$attempts" | bc)
		printf "\nAverage request time: $avg_time s\n"
	fi
}

### main ###
if [ $# -lt 1 ]; then
	printf "Usage:\n\tcurltime <target>\n\tcurltime <target> <attempts>\n"
else
	printf "Target: $1\n\n"

	attempts=1
	if [ $# -eq 2 ]; then
		let attempts=$2
	fi

	run $1 $attempts
fi