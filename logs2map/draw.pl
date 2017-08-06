#!/usr/bin/perl
use strict;
use warnings;

use GD;
use Getopt::Long;
use FindBin qw($Bin $Script);

my $clip = 0;
my $min = 3;
my $max = 3;
my $help = '';

GetOptions ('clip=i' => \$clip, 'm|min=i' => \$min, 'M|max=i' => \$max, 'help' => \$help);

if ($help) {
	print "Usage: $Script [OPTION]... [FILE]...\n\n".
		  "  -c, --clip <number>\tClip attempts above <number> (Default: 0, no clipping)\n".
		  "  -M, --max <number>\tMax size of a point in pixels (Default: 3)\n".
		  "  -m, --min <number>\tMin size of a point in pixels (Default: 3)\n".
		  "  -h, --help\tdisplay this help message\n\n".
		  "With no FILE, or when FILE is -, read standard input.\n".
		  "Clipped points are distinguished with red.\n";
	exit 0;
}

# create a new image
my $map = newFromPng GD::Image("world.png");



my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";

open(my $data, '<', $file) or die "Could not open '$file' $!\n";

# HoH, terrible[i]![/i]
my %locations;

while (my $line = <$data>) {
	chomp $line;
	my @fields = split "," , $line;

#if exist fields2 3, y sumarlo
	$locations{$fields[2]}{$fields[3]} = $fields[1];
	my $lat = $fields[2];
	my $lon = $fields[3];
	my $x = ($map->width())*(180+$lon)/360;
	my $y = ($map->height())*(90-$lat)/180;

	if ($fields[1]>$clip) {
		$map->filledArc($x,$y,$max,$max,0,360,$map->colorAllocate(255,0,0));
	} else {
		my $size = $min+($fields[1]*0.03);
		$map->filledArc($x,$y,$size,$size,0,360,$map->colorAllocate(0,0,255));
	}

}




# Convert the image to PNG and print it on standard output
print $map->png;
