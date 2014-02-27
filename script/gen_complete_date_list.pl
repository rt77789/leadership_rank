#!/usr/bin/perl -w
use List::Util qw(min max);

my $prefix = 'sp500';
my %date_list;
my %mc_date;
my %price_date;

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


##### Statistics of date list for each stock price and market cap. ######

my $total_num = keys %date_list;

for my $k (sort keys %mc_date) {
	my $num = 0;
	grep { $num++ if $_ >= $mc_date{$k}->[0] && $_ <= $mc_date{$k}->[1]; } keys %date_list;
	print "$k, cover=$mc_date{$k}->[2], total=$num, list=$total_num, from=$mc_date{$k}->[0], to=$mc_date{$k}->[1], cover_rate=", $mc_date{$k}->[2] / $num,"\n";
}

for my $k (sort keys %price_date) {
	my $num = 0;
	grep { $num++ if $_ >= $price_date{$k}->[0] && $_ <= $price_date{$k}->[1]; } keys %date_list;
	print "$k, cover=$price_date{$k}->[2], total=$num, list=$total_num, from=$price_date{$k}->[0], to=$price_date{$k}->[1], cover_rate=", $price_date{$k}->[2] / $num,"\n";
}

open OUT, ">../resource/${prefix}.datelist" or die "open ../resource/${prefix}.datelist failed...\n";
print OUT $_, "\n" for (sort keys %date_list);
close OUT;
