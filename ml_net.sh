#!/bin/sh

dri=$(/usr/bin/netstat -r4n | awk '/^default/ {print $4}')
[ -n "$dri" ] && t1=$(now) && \
    rate_info=$(/usr/bin/netstat -I "$dri" -4 -b 2>/dev/null | \
                    awk 'NR%2==0 {print $8 " " $11}')
set -- $rate_info
[ -n "$1" ] && d1=$1; d2='0'; dr=-1.0
[ -n "$2" ] && u1=$2; u2='0'; ur=-1.0
t2='0'
interval=3 # customize this

# Set the variable stump_pid using one of these two lines.  Which line you use
# depends on whether you run the large StumpWM executable that bundles SBCL, or
# if you simply start SBCL and load StumpWM.  If you are using the FreeBSD
# StumpWM package, use the second line.

stump_pid=$(pgrep -a -n stumpwm)
#stump_pid="$(pgrep -anf -U "$(id -u)" "sbcl .*(stumpwm:stumpwm)")"

# while stumpwm is still running
while kill -0 "$stump_pid" > /dev/null 2>&1; do
    dri=$(/usr/bin/netstat -r4n 2>/dev/null | awk '/^default/ {print $4}')
    if [ -n "$dri" ]; then
	t2=$(now) && \
	    rate_info=$(/usr/bin/netstat -I "$dri" -4 -b 2>/dev/null | \
                            awk 'NR%2==0 {print $8 " " $11}')
	set -- $rate_info
	[ -n "$1" ] && d2=$1;
	[ -n "$2" ] && u2=$2;
	dr=$(bc -e "scale=2;($d2-$d1)/($t2-$t1)/1024" -e quit)
	ur=$(bc -e "scale=2;($u2-$u1)/($t2-$t1)/1024" -e quit)
	printf "%s\t" "$dri"
 	case "$ur" in
	    ''|*.*.*|*[!0-9.]*) printf "%8.2f\t" "-1.0";;
	    *) printf "%8.1f\t" "$ur";;
	esac
	case "$dr" in
	    ''|*.*.*|*[!0-9.]*) printf "%8.2f\n" "-1.0";;
	    *) printf "%8.1f\n" "$dr";;
	esac
	t1="$t2"; d1="$d2"; u1="$u2"
    else
	printf "\-\t-1.0\t-1.0\n"
    fi
    sleep "$interval"
done