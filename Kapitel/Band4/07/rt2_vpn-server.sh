#!/bin/sh
# tested and working with:
# OpenWrt 19.07.4 r11208-ce6496d796
# target: x86/legacy
# arch: i386_pentium


# Software fuer Racoon
opkg update
opkg install ipsec-tools openssl-util ip-tiny kmod-ipsec4
ln -s /sbin/ip /usr/sbin/ip

# Racoon als VPN-Server konfiguieren
rm -f /etc/config/racoon
touch /etc/config/racoon
uci add racoon racoon
uci set racoon.@racoon[0].ipversion=4

uci add racoon p1_proposal
uci rename racoon.@p1_proposal[-1]=aes256xauth
uci set racoon.aes256xauth.enc_alg=aes
uci set racoon.aes256xauth.hash_alg=sha1
uci set racoon.aes256xauth.auth_method=xauth_psk_server
uci set racoon.aes256xauth.dh_group=2
uci set racoon.aes256xauth.lifetime=86400

uci add racoon p2_proposal
uci rename racoon.@p2_proposal[-1]=aes256sha
uci set racoon.aes256sha.pfs_group=2
uci set racoon.aes256sha.enc_alg=aes
uci set racoon.aes256sha.auth_alg=hmac_sha1

uci add racoon sainfo
uci rename racoon.@sainfo[-1]=anonymous
uci set racoon.anonymous.enabled=1
uci set racoon.anonymous.p2_proposal=aes256sha
uci set racoon.anonymous.local_net=10.2.1.0/24
uci set racoon.anonymous.remote_net=10.6.1.0/24
uci set racoon.anonymous.dns4=10.2.1.2
uci set racoon.anonymous.defdomain=openwrt.lab
uci set racoon.anonymous.save_passwd=1

uci add racoon tunnel
uci rename racoon.@tunnel[-1]=vpnc
uci set racoon.vpnc.enabled=1
uci set racoon.vpnc.remote='anonymous'
uci set racoon.vpnc.pre_shared_key=OpenWrtPraktiker
uci set racoon.vpnc.exchange_mode=aggressive
uci set racoon.vpnc.my_id='rt-2.openwrt.lab'
uci set racoon.vpnc.my_id_type=fqdn
uci set racoon.vpnc.mode_cfg=on
uci add_list racoon.vpnc.p1_proposal='aes256xauth'
uci add_list racoon.vpnc.sainfo='anonymous'

uci commit


# Kleine Fixes fuer das Start-Skript /etc/init.d/racoon
opkg install patch
cd /etc/
wget https://github.com/der-openwrt-praktiker/der-openwrt-praktiker.github.io/blob/master/Kapitel/Band4/7/racoon_server.patch
patch -p2 < racoon_server.patch


# Firewallregel fuer den Datenverkehr *im* VPN-Tunnel
uci add firewall rule
uci add_list firewall.@rule[-1].proto='all'
uci set firewall.@rule[-1].name='Allow-traffic-inside-tunnel'
uci add_list firewall.@rule[-1].src_ip='10.6.1.0/24'
uci add_list firewall.@rule[-1].src_ip='fd00:6::/64'
uci set firewall.@rule[-1].dest='lan'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].src='*'
uci commit
service firewall restart


# Benutzerkonten anlegen
opkg install shadow-useradd
/usr/sbin/useradd scooper
passwd scooper


# VPN-Dienst Racoon starten
service racoon restart
service racoon enable
