#!/usr/perl/bin -w

use LWP;

my $ag = LWP::UserAgent->new;
my %sp100;

sub read_sp100_list {
	open IN, '<../resource/sp100.list' or die "open ../resource/sp100.list failed...\n";
	while(<IN>) {
		chomp;
		s{\.}{-}isg;
		$sp100{$_}++;
	}
	close IN;
}

sub download_ticker {
	my $ticker = $_[0];
	my $url = "http://finance.yahoo.com/q/hp?s=${ticker}+Historical+Prices";
	my $res = $ag->get($url);
	my $con = $res->content;

	if($con =~ m{<a\s+href="([^"]+.csv)"}is) {
		print $1, "\n";
	}
	else {
		die "can't match .csv file.";
	}
}

sub download_sp100 {
	&read_sp100_list;
	for my $ti (sort keys %sp100) {
		print $ti, "\n";
		&download_ticker($ti);
	}
}

#&download_sp100;

&download_ticker("DELL");
#&download_data("MSFT");
