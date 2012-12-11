#!/usr/bin/perl
use strict;
use warnings;

use Regexp::Common qw /net/;
use Geo::IP;
use Getopt::Long;
use FindBin qw($Bin $Script);

my $csv = '';
my $help = '';

GetOptions ('csv' => \$csv, 'help' => \$help);

if ($help) {
	print "Usage: $Script [OPTION]... [FILE]...\n\n".
		  "  -c, --csv\tcomma-separated values output\n".
		  "  -h, --help\tdisplay this help message\n\n".
		  "With no FILE, or when FILE is -, read standard input.\n";
	exit 0;
}

my $gi = Geo::IP->open("$Bin/GeoLiteCity.dat", GEOIP_STANDARD);

my %ip_list;

while (<>) {
	if (/($RE{net}{IPv4})/g) {
		if(not exists $ip_list{$1}) {
			$ip_list{$1} = 1;
		} else {
			$ip_list{$1}++;
		}
	}
}

foreach (sort { $ip_list{$b} <=> $ip_list{$a} } keys %ip_list) {
	my $record = $gi->record_by_addr($_);
	if ($csv) {
		print "$_,$ip_list{$_}," . $record->latitude . ',' . $record->longitude . "\n";
	} else {
		print "$_\t - " . $record->city . ($record->city?', ':'') . $record->country_name . ' ('. $record->latitude . ' ' . $record->longitude .") - Attempts: $ip_list{$_}\n";
	}
}

if (not $csv) {
	print "\nTotal hosts: " . keys( %ip_list ) . "\n";
}

