#!/usr/bin/perl

use strict ;
#use Net::SNMP ;
#use Data::Dumper ;

my %oidHash = (
		'sysDesc'              => '.1.3.6.1.2.1.1.1.0',
		'sysUpTime'            => '.1.3.6.1.2.1.25.1.1.0',
		'sysName'              => '.1.3.6.1.2.1.1.5.0',
		'cpuManufacturer'      => '.1.3.6.1.2.1.25.3.2.1.3.768',
		'cpu1MinAvgLoad'       => '.1.3.6.1.4.1.2021.10.1.3.1',
		'cpu5MinAvgLoad'       => '.1.3.6.1.4.1.2021.10.1.3.2',
		'cpu15MinAvgLoad'      => '.1.3.6.1.4.1.2021.10.1.3.3',
		'cpuIdleTimePercent'   => '.1.3.6.1.4.1.2021.11.11.0',
		'totalSwapMemSpace'    => '.1.3.6.1.4.1.2021.4.3.0',
		'unusedSwapMemSpace'   => '.1.3.6.1.4.1.2021.4.4.0',
		'totalRamInstalled'    => '.1.3.6.1.4.1.2021.4.5.0',
		'totalRamUnused'       => '.1.3.6.1.4.1.2021.4.6.0',
		'sharedMemAllocated'   => '.1.3.6.1.4.1.2021.4.13.0',
		'totalMemBuffered'     => '.1.3.6.1.4.1.2021.4.14.0',
		'totalMemCached'       => '.1.3.6.1.4.1.2021.4.15.0',
		'totalDiskSpace'       => '.1.3.6.1.4.1.2021.9.1.6.1',
		'availDiskSpace'       => '.1.3.6.1.4.1.2021.9.1.7.1',
		'usedDiskSpace'        => '.1.3.6.1.4.1.2021.9.1.8.1',
		'usedDiskSpacePercent' => '.1.3.6.1.4.1.2021.9.1.9.1', ) ;
		
my $hostname = 'localhost' ;
my $community = 'public' ;

#my ($session, $error) = Net::SNMP->session(
#				-hostname => $hostname,
#				-community => $community,
				#) ;

#my $result = $session->get_request( -varbindlist => [$oid], );

while ((my $key, my $value) = each %oidHash) {
	my $machineStat = `snmpget -v2c -c $community -Ov $hostname $value` ;
	chomp($machineStat) ;

	print "[$key] [$machineStat]\n" ;
}
