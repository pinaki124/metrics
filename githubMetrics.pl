#!/usr/bin/perl

use strict ;
use Net::GitHub ;
use Term::ReadKey ;

my $passKey = "" ;
my $gitHubURL = "" ;
my $user = "" ;
my $credentials = "" ;

print "Enter credentials (userid:password) : " ;
ReadMode 2 ;
chomp($credentials = <STDIN>) ;
ReadMode 0 ;

($user, $passKey) = split (":", $credentials) ;

print "Enter Github enterprise URL : (Press 'Enter' for non-enterprise URL)" ;
chomp($gitHubURL = <STDIN>) ;

	# Accessing the github public URL
my $github = Net::GitHub->new ( login => $user, pass => $passKey ) ;
my $eventObj = $github->event ;

foreach my $repo ( $github->repos->list ) {
	foreach my $event ( $eventObj->repos_events($user, $repo->{name}) ) {
		while ((my $eventKey, my $eventVal) = each %{$event}) {
			print "AA: [$repo->{name}] [$eventKey] [$eventVal]\n" ;
			if ( $eventVal =~ /HASH/ ) {
				while ((my $eventValKey, my $eventValValue) = each %{$eventVal}) {
					print "\tBB: [$repo->{name}] [$eventKey] [$eventValKey] [$eventValValue]\n" ;
				}
			}
		}
		print "--------------------------------------------------------------------------\n" ;
	}
	print "==========================================================================\n" ;
}
