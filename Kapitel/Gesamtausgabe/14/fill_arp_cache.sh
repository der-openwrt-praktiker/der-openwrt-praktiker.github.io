#!/bin/sh
NEIGHBORS4=$(/sbin/ip route list | grep via | awk '{print $3}')
for NHR in ${NEIGHBORS4} ; do
  grep ${NHR} /proc/net/arp >/dev/null  ||  ping -t1 -c1 -W1 ${NHR} >/dev/null
done

NEIGHBORS6=$(/sbin/ip -6 route list | grep via | awk '{print $3}')
for NHR in ${NEIGHBORS6} ; do
  ip -6 neigh show | grep $NHR >/dev/null  ||  ping -6 -t1 -c1 $NHR >/dev/null
done
