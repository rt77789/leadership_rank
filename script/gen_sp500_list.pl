#!/usr/bin/perl -w

my $page;

open P, "<../data/sp500.page" or die "open ../data/sp500.page failed...\n";
while(<P>) {
	chomp;
	print "$1\n" if m{Symbol\|(.*?)\}}is;
}
close P;


