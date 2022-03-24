#!/bin/bash
## Virtuelle Maschine in VirtualBox anlegen und einrichten

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

# Nummer und Name des Routers
RT_ID="${1:-1}"
RT_NAME=$(printf "RT-%01d" ${RT_ID})


# Festplattenimage von OpenWrt laden und vorbereiten
OPENWRT_URL=https://downloads.openwrt.org/releases/18.06.4/targets/x86/64/openwrt-18.06.4-x86-64-combined-ext4.img.gz
OPENWRT_FILE=/tmp/$(basename $OPENWRT_URL)
OPENWRT_IMAGE=${OPENWRT_FILE%.*}

if [ ! -f "$OPENWRT_IMAGE" ] ; then
  wget -q -O $OPENWRT_FILE $OPENWRT_URL
  zcat $OPENWRT_FILE > $OPENWRT_IMAGE
fi

# DHCP-Dienst im OpenWrt-Image ausschalten
sudo kpartx -a -v $OPENWRT_IMAGE
sudo mount /dev/mapper/loop0p2 /mnt
sudo rm -f /mnt/etc/config/dhcp

# Feste IP-Adresse fuer die erste Netzwerkkarte
sudo touch /mnt/etc/config/{network,system}
sudo chmod a+rw /mnt/etc/config/{network,system}
cat <<EOF > /mnt/etc/config/network
config interface 'lan'
  option ifname 'eth0'
  option proto 'static'
  option ipaddr '10.5.1.${RT_ID}'
  option netmask '255.255.255.0'
  option gateway '10.5.1.250'
  option dns '10.5.1.253'
EOF

cat <<EOF > /mnt/etc/config/system
config system
  option hostname '${RT_NAME}'
  option zonename 'Europe/Berlin'
  option timezone 'GMT2'
EOF

sudo umount /mnt
sudo kpartx -d $OPENWRT_IMAGE


# VM erstellen und registrieren
VBoxManage createvm --name ${RT_NAME} --register
VBoxManage modifyvm ${RT_NAME} --memory 256
VBoxManage modifyvm ${RT_NAME} --description "OpenWrt lab"
VBoxManage modifyvm ${RT_NAME} --ostype "Linux_64"
VBoxManage modifyvm ${RT_NAME} --audio none
VBoxManage modifyvm ${RT_NAME} --ioapic on

# Festplatte
VDISK="$HOME/VirtualBox VMs/${RT_NAME}/disk.vmdk"
VBoxManage storagectl ${RT_NAME} --name "SATA Controller" --add sata
qemu-img convert -f raw -O vmdk $OPENWRT_IMAGE "$VDISK"
VBoxManage storageattach ${RT_NAME} --storagectl "SATA Controller" --medium "$VDISK" --port 0 --type hdd

# Netzwerkkarte 1 als Managementadapter einrichten
VBoxManage modifyvm ${RT_NAME} --nic1 bridged
VBoxManage modifyvm ${RT_NAME} --bridgeadapter1 eth1
VBoxManage modifyvm ${RT_NAME} --nictype1 virtio
VBoxManage modifyvm ${RT_NAME} --macaddress1 \
  $(printf "005623%02d00%02d" ${RT_ID} ${RT_ID})

# RDP-Konsole
VBoxManage modifyvm ${RT_NAME} --vrde on
VBoxManage modifyvm ${RT_NAME} --vrdeport 820${RT_ID}
VBoxManage modifyvm ${RT_NAME} --vrdeaddress "${HOSTNAME}"

# Serielle Konsole
#VBoxManage modifyvm ${RT_NAME} --uart1 0x3F8 4
#VBoxManage modifyvm ${RT_NAME} --uartmode1 server /tmp/${RT_NAME}.pipe

# VM starten
#VBoxHeadless --startvm ${RT_NAME} &

# Mit RDP-Konsole verbinden
#rdesktop ${HOSTNAME}:82${RT_ID} &
