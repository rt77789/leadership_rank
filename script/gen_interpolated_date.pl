#!/usr/bin/perl -w

## Filter the s&p 500, obtain the valid companies. ##

use List::Util qw(min max);

my $prefix = 'sp500';
my %date_list;

for my $f (`ls ../resource/${prefix}_market_cap_clean/*.cap.clean`) {
	chomp $f;
	open IN, "<$f" or die "open $f failed...\n";
	my @td;
	while(<IN>) {
		chomp;
		my @tk = split /,/;
#		print $tk[0], "\n";
		$date_list{$tk[0]}++;
		push @td, $tk[0];
	}
	close IN;

	$mc_date{$f} = [min(@td), max(@td), $#td + 1];
}

for my $f (`ls ../resource/${prefix}_day_price/*.price`) {
	chomp $f;
	open IN, "<$f" or die "open $f failed...\n";
	<IN>;
	my @td;
	while(<IN>) {
		chomp;
		my @tk = split /,/;
#		print $tk[0], "\n";
		$tk[0] =~ s{-}{}isg;
		$date_list{$tk[0]}++;
		push @td, $tk[0];
	}
	close IN;
	$price_date{$f} = [min(@td), max(@td), $#td + 1];
}

