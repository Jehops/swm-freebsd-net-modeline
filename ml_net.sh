#!/bin/sh

dri=`/usr/bin/netstat -r4n | awk '/^default/ {print $4}'`
dri_dn=`echo ${dri} | sed -E 's/([0-9]+)/.\1/'`
[ -n "$dri" ] && t1=`now` && \
	rate_info=`/usr/bin/netstat -I ${dri} -q 1 -b 2>/dev/null | awk 'NR%3==0 {print $8 " " $11}'`
set -- ${rate_info}
[ -n "$1" ] && d1=$1; d2='0'; dr=-1
[ -n "$2" ] && u1=$2; u2='0'; ur=-1
t2='0'
interval=3

stump_pid=`pgrep -a -n stumpwm`

# while stumpwm is still running
while kill -0 $stump_pid > /dev/null 2>&1; do
    dri=`/usr/bin/netstat -r4n 2>/dev/null | awk '/^default/ {print $4}'`
    if [ -n "${dri}" ]; then
	dri_dn=`echo ${dri} | sed -E 's/([0-9]+)/.\1/'`
	t2=`now` &&\
	    rate_info=`/usr/bin/netstat -I ${dri} -q 1 -b 2>/dev/null | awk 'NR%3==0 {print $8 " " $11}'`
	set -- ${rate_info}
	[ -n "$1" ] && d2=$1;
	[ -n "$2" ] && u2=$2;
	dr=`echo "scale=2; (${d2} - ${d1}) / (${t2} - ${t1}) / 1024" | bc`
	ur=`echo "scale=2; (${u2} - ${u1}) / (${t2} - ${t1}) / 1024" | bc`
	printf "%s\t" ${dri}
 	case $ur in
	    ''|*[!0-9]*) printf "%8.2f\t" ${ur};;
	    *) printf "-1";;
	esac
	case $dr in
	    ''|*[!0-9]*) printf "%8.2f\n" ${dr};;
	    *) printf "-1\n";;
	esac
	t1=${t2}; d1=${d2}; u1=${u2}
    else
	printf "\-\t-1\t-1\n"
    fi
    sleep ${interval}
done