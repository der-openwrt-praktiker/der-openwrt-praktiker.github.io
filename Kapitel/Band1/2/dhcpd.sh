#/bin/bash
IFNAME=enp0s25
ip address flush dev $IFNAME
ip address add 192.168.88.10/24 dev $IFNAME
dnsmasq -i $IFNAME --dhcp-range=192.168.88.23,192.168.88.23 --log-dhcp --bootp-dynamic -d --dhcp-boot=openwrt-18.06.4-ar71xx-mikrotik-rb-nor-flash-16M-initramfs-kernel.bin --enable-tftp --tftp-root=/var/lib/tftpboot -u root -p0 -K
