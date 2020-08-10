#!/bin/bash
## Virtuelle Maschinen erstellen und verkabeln

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

for value in {1..4}; do
  # Router erstellen
  ./vbox-import.sh $value

  # Virtuelle Netze anlegen
  VBoxManage hostonlyif create
  VBoxManage hostonlyif ipconfig vboxnet${value} --ip 10.${value}.1.181
done
VBoxManage hostonlyif ipconfig vboxnet5 --ip 203.0.113.181

# Router verkabeln
./vbox-cabling.sh

# MAC-Adressen zuweisen
./vbox-macaddr.sh

# Router starten
for ROUTER_ID in {1..4} ; do
  VBoxHeadless --startvm RT-${ROUTER_ID} &
  sleep 1
done
