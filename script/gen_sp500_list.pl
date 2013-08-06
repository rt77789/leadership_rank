#!/usr/bin/perl -w

my $page;

open P, "<../data/sp500.page" or die "open ../data/sp500.page failed...\n";

while(<P>) {
	chomp;
	print "$1\n" if m{Symbol\|(.*?)\}}is;
	my $com = $1;
	my @tk = split /\|\|/;
	if(@tk > 4) {
		$tk[3] =~ s{^\s+}{}isg;
		$tk[3] =~ s{\s+$}{}isg;
		print STDERR "$com,$tk[3]\n";
	}
}
close P;


