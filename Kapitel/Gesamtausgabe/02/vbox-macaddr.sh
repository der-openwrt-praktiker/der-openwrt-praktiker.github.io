#!/bin/bash
## MAC-Adresse aller Netzadapter der virtuellen Maschinen definieren

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

for ROUTER_ID in {1..4} ; do
  for PORT_ID in {2..4} ; do
    MAC=$(printf "005623%02dff%02d" ${ROUTER_ID} ${PORT_ID})
    VBoxManage modifyvm RT-${ROUTER_ID} --macaddress${PORT_ID} $MAC
  done
done
