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
uci set tinc.LAB.Name=RT4
uci set tinc.LAB.Device=/dev/net/tun

# generate crypto keys
uci set tinc.LAB.generate_keys=1
uci set tinc.LAB.key_size=2048
uci set tinc.LAB.enabled=1

# specify settings of the local node
uci set tinc.RT4=tinc-host
uci set tinc.RT4.Address=2001:db8:3::4
uci set tinc.RT4.Subnet=fd00:4::/64
uci set tinc.RT4.enabled=1
uci set tinc.RT4.net=LAB

# generate keys
mkdir -p /etc/tinc/LAB/hosts
tinc --net=LAB generate-ed25519-keys
cat /etc/tinc/LAB/ed25519_key.pub > /etc/tinc/LAB/hosts/RT4

# commit and start
uci commit
service tinc restart
cat /etc/tinc/LAB/hosts/RT4


# allow incoming Tinc connection
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-Tinc'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest_port='655'
uci set firewall.@rule[-1].target='ACCEPT'
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
uci add_list tinc.RT2.Address=2001:db8:3::2
uci set tinc.RT2.Subnet=fd00:2::/64

# initiate a VPN connection to RT2
uci add_list tinc.LAB.ConnectTo=RT2

# get the public key from RT2 and store it in /etc/tinc/LAB/hosts/RT2

uci commit


# interface and routing
cat <<EOF > /etc/tinc/LAB/tinc-up
#!/bin/sh
ip -6 addr add fd00:4::4/128 dev \$INTERFACE
ip -6 link set \$INTERFACE up mtu 1280
ip -6 route add fd00::/16 dev \$INTERFACE
EOF

cat <<EOF > /etc/tinc/LAB/tinc-down
#!/bin/sh
ip -6 route del fd00::/16 dev \$INTERFACE
ip -6 link set \$INTERFACE down
ip -6 addr del fd00:4::4/128 dev \$INTERFACE
EOF

chmod +x /etc/tinc/LAB/tinc-*
service tinc restart
