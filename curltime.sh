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
	host=$1
	attempts=$2
	avg_time=0

	for ((idx=1; idx<=$attempts; idx++)) 
	do
		printf "Attempt $idx of $attempts. Time: ";
		(curl -w "%{time_total}" -o . -s "$host" > out.txt) &
		spinner $!
		read -r t<out.txt
		printf "$t s\n"
		avg_time=$(echo "scale=3;$avg_time+$t" | bc)
	done

	rm out.txt
	avg_time=$(echo "scale=3;$avg_time/$attempts" | bc)

	echo "Average request time: $avg_time s"
}

### main ###
if [ $# -lt 2 ]
then
	echo "Usage: curltime <host> <attempts>"
else
	run $1 $2
fi