#!/bin/sh

# install software
opkg update
opkg install tinc


# remove default config
uci del tinc.NETNAME
uci del tinc.NODENAME
uci commit

# choose a _NETNAME_, e.g. LAB
uci set tinc.LAB=tinc-net
uci set tinc.LAB.Name=RT3
uci set tinc.LAB.Device=/dev/net/tun

# generate crypto keys
uci set tinc.LAB.generate_keys=1
uci set tinc.LAB.key_size=2048
uci set tinc.LAB.enabled=1

# specify settings of the local node
uci set tinc.RT3=tinc-host
uci set tinc.RT3.Address=203.0.113.3
uci set tinc.RT3.Subnet=10.3.1.0/24
uci set tinc.RT3.enabled=1
uci set tinc.RT3.net=LAB

# generate keys
mkdir -p /etc/tinc/LAB/hosts
tinc --net=LAB generate-ed25519-keys
cat /etc/tinc/LAB/ed25519_key.pub > /etc/tinc/LAB/hosts/RT3

# commit and start
uci commit
service tinc restart
cat /etc/tinc/LAB/hosts/RT3


# allow incoming Tinc connection
uci add firewall rule
uci set firewall.@rule[-1].dest_port='655'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].name='Allow-Tinc'
uci set firewall.@rule[-1].target='ACCEPT'
uci add_list firewall.@rule[-1].dest_ip='203.0.113.3'
uci commit
service firewall restart


# allow traffic through the Tinc tunnel
uci add firewall rule
uci set firewall.@rule[-1].name='Tinc-Traffic-IN'
uci set firewall.@rule[-1].src='*'
uci set firewall.@rule[-1].dest='lan'
uci set firewall.@rule[-1].direction='in'
uci set firewall.@rule[-1].device='tun0'
uci set firewall.@rule[-1].target='ACCEPT'
uci add_list firewall.@rule[-1].proto='all'
uci add firewall rule
uci set firewall.@rule[-1].name='Tinc-Traffic-OUT'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].dest='*'
uci set firewall.@rule[-1].direction='out'
uci set firewall.@rule[-1].device='tun0'
uci set firewall.@rule[-1].target='ACCEPT'
uci add_list firewall.@rule[-1].proto='all'
uci commit
service firewall restart


# connect to another tinc node
uci set tinc.RT2=tinc-host
uci set tinc.RT2.enabled=1
uci set tinc.RT2.net=LAB
uci add_list tinc.RT2.Address=203.0.113.2
uci set tinc.RT2.Subnet=10.2.1.0/24

# initiate a VPN connection to RT2
uci add_list tinc.LAB.ConnectTo=RT2

# get the public key from RT2 and store it in /etc/tinc/LAB/hosts/RT2

uci commit


# interface and routing
cat <<EOF > /etc/tinc/LAB/tinc-up
#!/bin/sh
ip addr add 10.3.1.3/32 dev \$INTERFACE
ip link set \$INTERFACE up
ip route add 10.0.0.0/8 dev \$INTERFACE
EOF

cat <<EOF > /etc/tinc/LAB/tinc-down
#!/bin/sh
ip route del 10.0.0.0/8 dev \$INTERFACE
ip link set \$INTERFACE down
ip addr del 10.3.1.3/32 dev \$INTERFACE
EOF

chmod +x /etc/tinc/LAB/tinc-*
service tinc restart
