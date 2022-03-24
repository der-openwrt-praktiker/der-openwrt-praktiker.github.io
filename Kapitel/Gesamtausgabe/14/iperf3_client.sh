#!/bin/sh

INTERFACE=eno1
PEER=192.0.2.91

for MTU in 1500 1420 1280 1024 512 256 128 68 ; do
  echo "*** Messung mit MTU ${MTU} Bytes"
  ip link set ${INTERFACE} mtu ${MTU}
  sleep 4
  iperf3 --client ${PEER} --time 60 --interval 60 --window 128K --format m | grep bit
done

# Interface MTU zuruecksetzen
ip link set ${INTERFACE} down
ip link set ${INTERFACE} mtu 1500
ip link set ${INTERFACE} up
