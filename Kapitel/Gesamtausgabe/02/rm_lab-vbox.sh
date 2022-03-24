#!/bin/bash
## Virtuelle Maschinen herunterfahren und löschen

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

# Router stoppen und löschen
for ROUTER_ID in {1..4} ; do
  VBoxManage controlvm RT-${ROUTER_ID} poweroff
  VBoxManage unregistervm RT-${ROUTER_ID} --delete
done
