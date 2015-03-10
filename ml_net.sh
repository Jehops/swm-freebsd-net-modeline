#!/bin/sh

dt1=`now` && d1=`/sbin/sysctl -n dev.em.0.mac_stats.good_octets_recvd`
dt2='' && d2=''
interval=3
ut1=`now` && u1=`/sbin/sysctl -n dev.em.0.mac_stats.good_octets_txd`
ut2='' && u2=''
stump_pid=`pgrep -a -n stumpwm`

# while stumpwm is still running
while kill -0 $stump_pid > /dev/null 2>&1; do
    dri=`/usr/bin/netstat -r4n | awk '/^default/ {print $4}'`
    dri_dn=`echo ${dri} | sed -E 's/([0-9]+)/.\1/'`
    dt2=`now` && d2=`/sbin/sysctl -n dev.${dri_dn}.mac_stats.good_octets_recvd`
    dr=`echo "scale=2; (${d2} - ${d1}) / (${dt2} - ${dt1}) / 1024" | bc`
    ut2=`now` && u2=`/sbin/sysctl -n dev.${dri_dn}.mac_stats.good_octets_txd`
    ur=`echo "scale=2; (${u2} - ${u1}) / (${ut2} - ${ut1}) / 1024" | bc`    
    printf "%s\t%8.2f\t%8.2f\n" ${dri} ${ur} ${dr}
    dt1=${dt2} && d1=${d2}
    ut1=${ut2} && u1=${u2}
    sleep ${interval}
done