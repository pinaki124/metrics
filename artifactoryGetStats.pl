#!/usr/bin/perl
#
# This perl script will get the machine statistics from the Server hosting Artifactory for monitoring.
#

use strict ;
use Env ;
use Scalar::Util qw(looks_like_number);

my $serviceProcessID = 0 ;
my $machineStats ;
my %epicStatsMap = () ;
my %genericStatsMap = () ;
my $artifactorySystemInfo ;
my @statsToMap = [];

	# Verifying that the property and parameter files required by the script are defined as environment variables
die "[ERROR] Property/parameter files updated/required by the script are not defined.\n" if ( (! defined $ENV{'ARTIFACTORY_PROPS'}) || (! defined $ENV{'ARTIFACTORY_OUTFILE'}) ) ;
my $statsOutFile = $ENV{'ARTIFACTORY_OUTFILE'} ;
my $statsParamFile = $ENV{'ARTIFACTORY_PROPS'} ;

	# Reading the parameter file to identify the properties required to be monitored for Artifactory
open (PROPS, "$statsParamFile") or die "Unable to open file [$statsParamFile] for reading.\n" ;
while (<PROPS>) {
	chomp $_;
	push (@statsToMap, $_) ;
}
close PROPS ;

	# Verifying that the Environment variables for artifactory are set.
die "[ERROR] Environment variables for Artifactory are not set. Please check your job config.\n" if ( (! defined $ENV{'ARTIFACTORY_HOME'}) || (! defined $ENV{'ARTIFACTORY_PID_FILE'}) ) ;

	# Checking for the Process ID of the artifactory process running on the server
if ( ! -r "$ENV{'ARTIFACTORY_HOME'}/run/$ENV{'ARTIFACTORY_PID_FILE'}" ) {
	print "[WARNING] Artifactory process ID file [$ENV{'ARTIFACTORY_HOME'}/run/$ENV{'ARTIFACTORY_PID_FILE'}] does not exist. The program will try to get the process ID from the server\n" ;  
	chomp($serviceProcessID = `pgrep -f "java.*artifactory.* start\$"`) ;
	die "[ERROR] The program could not accurately identify a process ID for 'Artifactory'. Multiple process IDs were found.\n" if ( scalar (split ("\n", $serviceProcessID)) > 1 ) ;
} else {
	chomp($serviceProcessID = `cat $ENV{'ARTIFACTORY_HOME'}/run/$ENV{'ARTIFACTORY_PID_FILE'}`) ;
}

print "[INFO] Process ID for Artifactory process running on this server is : $serviceProcessID\n" ;
print "[INFO] Retrieving machine usage statistics for artifactory\n" ;

chomp($machineStats = `ps -p $serviceProcessID -o %cpu,%mem --no-heading`) ;
$epicStatsMap{'cpu usage'} = (split (/\s/, $machineStats))[1] if ( grep ("cpu usage", @statsToMap) );
$epicStatsMap{'mem usage'} = (split (/\s/, $machineStats))[2] if ( grep ("mem usage", @statsToMap) );

print "[INFO] Retrieving system information for Artifactory by using the rest API\n" ;
foreach ( `curl http://admin:$ENV{'artifactory_slave1'}\@localhost:8081/artifactory/api/system` ) {
	my $line = $_ ; chomp $line ;

	my $key = (split (/\|/, $line))[0];
	$key =~ s/\s*(\S+.*\S)\s*/$1/ ; 
	next if ( !(grep (/^$key$/, @statsToMap)) ) ;

	my $value = (split (/\|/, $line))[1];
	$value =~ s/\s*(\S+.*\S)\s*/$1/ ;

	if ( !($key =~ /^\s*$/ || $value =~ /^\s*$/) ) {
		(looks_like_number($value) && ($key =~ /cpu/i || $key =~ /mem/i)) ? $epicStatsMap{$key}=$value : $genericStatsMap{$key}=$value ;
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
