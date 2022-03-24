#!/bin/bash
## Alle virtuellen Maschinen miteinander verkabeln

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

for ROUTER_ID in {1..4} ; do
  for NIC_ID in {2..4} ; do
    VBoxManage modifyvm RT-${ROUTER_ID} --nictype${NIC_ID} virtio
  done

  # Netzadapter den Campusnetzen zuweisen
  VBoxManage modifyvm RT-${ROUTER_ID} --nic2 hostonly
  VBoxManage modifyvm RT-${ROUTER_ID} --hostonlyadapter2 "vboxnet${ROUTER_ID}"
done

# Netzbereiche WAN-1 und WAN-2
VBoxManage modifyvm RT-1 --intnet3 "rt1-rt2"
VBoxManage modifyvm RT-1 --nic3 intnet
VBoxManage modifyvm RT-1 --intnet4 "rt1-rt4"
VBoxManage modifyvm RT-1 --nic4 intnet
VBoxManage modifyvm RT-2 --intnet4 "rt1-rt2"
VBoxManage modifyvm RT-2 --nic4 intnet
VBoxManage modifyvm RT-4 --intnet4 "rt1-rt4"
VBoxManage modifyvm RT-4 --nic4 intnet

# Netzbereich WAN-3
VBoxManage modifyvm RT-2 --nic3 hostonly
VBoxManage modifyvm RT-2 --hostonlyadapter3 "vboxnet5"
VBoxManage modifyvm RT-3 --nic3 hostonly
VBoxManage modifyvm RT-3 --hostonlyadapter3 "vboxnet5"
VBoxManage modifyvm RT-4 --nic3 hostonly
VBoxManage modifyvm RT-4 --hostonlyadapter3 "vboxnet5"
