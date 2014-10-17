#!/usr/bin/perl
#
# This perl script will get the machine statistics from a Linux Server
#

use strict ;
use Env ;
use Scalar::Util qw(looks_like_number);
use Sys::Statistics::Linux ;
use Tie::IxHash ;

my $statsOutFile = "/home/vagrant/logs/machineStats.properties";
tie (my %epicStatsMap, 'Tie::IxHash') ; 
tie (my %genericStatsMap, 'Tie::IxHash') ;

	# Sys::Statistics::Linux module is being used in this script to get the overall machine stats
my $systemStats = Sys::Statistics::Linux->new (
					sysinfo   => 1,
					cpustats  => 1,
					procstats => 1,
					memstats  => 1,
					pgswstats => 1,
					diskstats => 1,
					diskusage => 1,
					loadavg   => 1,
					processes => 0,
				) ;

sleep(2) ;
my $result = $systemStats->get() ;

foreach my $key (keys %$result) {
	while ((my $statKey, my $statVal) = each %{$result->$key}) {
		if ( $statVal =~ /^HASH/ && $key eq "diskusage" ) {
			while ((my $statValKey, my $statValValue) = each %$statVal) {
				(looks_like_number($statValValue)) ? $epicStatsMap{"$key\_\[$statKey\]\_$statValKey"}=$statValValue : $genericStatsMap{"$key\_\[$statKey\]\_$statValKey"}=$statValValue ;
			}
		} else {
			(looks_like_number($statVal)) ? $epicStatsMap{"$key\_$statKey"}=$statVal : $genericStatsMap{"$key\_$statKey"}=$statVal ;
		}
	}
}

open (STATSFILE, ">$statsOutFile") or die "Unable to open file [$statsOutFile] for writing\n" ;
print STATSFILE "[Epic]\n" ;
while ((my $key, my $value) = each %epicStatsMap) {
    print STATSFILE "$key=$value\n" ;
}

print STATSFILE "[Generic]\n" ;
while ((my $key, my $value) = each %genericStatsMap) {
    print STATSFILE "$key=$value\n" ;
}
close STATSFILE ;

print "[INFO] All stats have been written into file [$statsOutFile]\n" ;
