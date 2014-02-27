#!/usr/bin/perl -w

my $clist = 'sp100';
my $dir = '../resource';

my %asc2num;
$asc2num{'Jan.'} = 1;
$asc2num{'Feb.'} = 2;
$asc2num{'March'} = 3;
$asc2num{'April'} = 4;
$asc2num{'May'} = 5;
$asc2num{'June'} = 6;
$asc2num{'July'} = 7;
$asc2num{'Aug.'} = 8;
$asc2num{'Sept.'} = 9;
$asc2num{'Oct.'} = 10;
$asc2num{'Nov.'} = 11;
$asc2num{'Dec.'} = 12;

for my $f (`ls $dir/${clist}_market_cap/`) {
	chomp $f;
	print "$dir/${clist}_market_cap/$f\n";	
	open IN, "<$dir/${clist}_market_cap/$f" or die "open $dir/${clist}_market_cap/$f failed...\n";
	open OUT, ">$dir/${clist}_market_cap_clean/$f.clean" or die "open $dir/${clist}_market_cap_clean/$f.clean failed...\n";
	while(<IN>) {
		chomp;
		die "$_ cannot match.\n" unless m{^(.*?)\s+(\d+),\s+(\d+);(.*?)(\w)$}is;
		my ($mon, $day, $year, $cap, $unit) = ($1, $2, $3, $4, $5);
		
		$cap *= 1000 if $unit eq 'B';
		#$cap *= 1000000 if $unit eq 'M';

		#print "$asc2num{$mon}, $day, $year, $cap\n";
		print OUT "$year-$asc2num{$mon}-$day,$cap\n";
	}
	close OUT;
	close IN;
}
