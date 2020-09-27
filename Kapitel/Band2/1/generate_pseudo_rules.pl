#!/usr/bin/perl
# [de] Zweck: viele Firewallregeln fuer OpenWrt erzeugen
# [en] purpose: generate many rules for OpenWrt

# usage: perl generate_pseudo_rules.pl > rules.sh ; sh rules.sh

my $number_of_rules = shift || 10;
my $prefix = 'uci set firewall.@rule[-1]';

foreach my $c ( 1 .. $number_of_rules ) {
        my $port = int(rand( 65535 ));

        print <<EOF;
uci add firewall rule
$prefix.dest_port='$port'
$prefix.src='dmz'
$prefix.name='dummy rule #$c'
$prefix.dest='wan'
$prefix.target='ACCEPT'
EOF
}

print "uci commit firewall\n";

exit( 0 );
