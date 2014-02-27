#!/usr/perl/bin -w

use LWP;

my $ag = LWP::UserAgent->new;
my $company_list = 'sp100';
my %company_list;

sub read_company_list {
	open IN, "<../resource/${company_list}.list" or die "open ../resource/${company_list}.list failed...\n";
	while(<IN>) {
		chomp;
		s{\.}{-}isg;
		$company_list{$_}++;
	}
	close IN;
}

sub download_ticker {
	my $ticker = $_[0];
	my $url = "http://ichart.finance.yahoo.com/table.csv?s=${ticker}&d=1&e=21&f=2014&g=d&a=7&b=19&c=1950&ignore=.csv";

	my $res;
	while(1) {	
		$res = $ag->get($url);
		last if $res->is_success;
		warn "$ticker cannot be downloaded...\n";
	}

	if($res->is_success) {
		open OUT, ">../resource/${company_list}_day_price/$ticker.price" or die "open ../resource/${company_list}_day_price/$ticker.price";
		print OUT $res->content;
		close OUT;
	}
	else {
		warn "$ticker cannot be downloaded...\n";
	}
}

sub download_all {
	&read_company_list;
	for my $ti (sort keys %company_list) {
		print $ti, " is downloading...\n";
		&download_ticker($ti);
	}
}

&download_all;

#&download_ticker("WPO");
#&download_data("MSFT");
