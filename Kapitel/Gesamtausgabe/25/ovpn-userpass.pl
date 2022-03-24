#!/usr/bin/env perl

# auth-user-pass-verify ovpn-userpass.pl via-env
# script-security 3

my $username = $ENV{'username'};
my $password = $ENV{'password'};

system("logger -t openvpn authentication for $username");

if ( open( $fh_shadow, '<', "/etc/shadow" ) ) {
   while ( my $line = <$fh_shadow> ) {
      my ( $user, $pass ) = split( /:/, $line, 3 );
      my $pass_crypt = crypt( $password, $pass );

      if ( $username eq $user  and  $pass_crypt eq $pass ) {
         close $fh_shadow;
         # OpenVPN erwartet Exitcode null bei erfolgreichem Login
         exit 0;
      }
   }
   close $fh_shadow;

} else {
   system("logger -t openvpn error reading /etc/shadow: $!");
   exit 2;
}

# Exitcode 1 steht fuer fehlerhafte Anmeldung
exit 1;
