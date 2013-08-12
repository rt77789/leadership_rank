#!/usr/bin/perl -w

my $page;

open P, "<../resource/sp500.page" or die "open ../resource/sp500.page failed...\n";
open COM, ">../resource/sp500.list" or die "open ../resource/sp500.list failed...\n";
open IND, ">../resource/sp500.industry" or die "open ../resource/sp500.industry failed...\n";
open SEC, ">../resource/sp500.sector" or die "open ../resource/sp500.sector...\n";

while(<P>) {
	chomp;
	print COM "$1\n" if m{Symbol\|(.*?)\}}is;
	my $com = $1;
	my @tk = split /\|\|/;
	if(@tk > 5) {
		$tk[3] =~ s{^\s+}{}isg;
		$tk[3] =~ s{\s+$}{}isg;
		print SEC "\"$com\",\"$tk[3]\"\n";

		$tk[4] =~ s{^\s+}{}isg;
		$tk[4] =~ s{\s+$}{}isg;
		print IND "\"$com\",\"$tk[4]\"\n";
	}
}

close COM;
close SEC;
close IND;
close P;


