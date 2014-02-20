#!/usr/perl/bin -w

use LWP;

my $ag = LWP::UserAgent->new;
my %data;
my $comps = 'sp100';

sub read_company_list {
	open IN, "<../resource/${comps}.list" or die "open ../resource/${comps}.list failed...\n";
	while(<IN>) {
		chomp;
		s{\.}{-}isg;
		$data{$_}++;
	}
	close IN;
}

sub download_ticker {
	my $ticker = $_[0];
	#my $url = "http://www.google.com/finance/historical?q=${ticker}";
	#my $url = "http://www.google.com/finance/historical?q=${ticker}&startdate=Feb+5%2C+2000&enddate=Feb+19%2C+2014";
	my $url = "http://www.google.com/finance/historical?q=${ticker}&startdate=Feb+5%2C+2000&enddate=Feb+19%2C+2014&output=csv";
	#http://www.google.com/finance/historical?q=acn&startdate=Feb+5%2C+2000&enddate=Feb+19%2C+2014
	my $res = $ag->get($url);
	die "$url cannot be get.\n" unless $res->is_success;
	my $con = $res->content;

	open OUT, ">../resource/$comps/$ticker.csv" or die "open ../resource/$comps/$ticker.csv failed..\n";
	print OUT $res->content;
	close OUT;
	#
#	if($con =~ m{<a\s+class=nowrap\s+href="([^"]+.csv)"}is) {
#		print $1, "\n";
#		$res = $ag->get($1);
#		open OUT, ">../resource/sp100/$ticker.csv" or die "open ../resource/sp100/$ticker.csv failed..\n";
#		print OUT $res->content;
#		close OUT;
#	}
#	else {
#		die "can't match .csv file.";
#	}
}

sub download_data {
	&read_company_list;
	for my $ti (sort keys %data) {
		print $ti, "\n";
		&download_ticker($ti);
	}
}

&download_data;

#&download_ticker("DELL");
#&download_data("MSFT");

# http://ichart.finance.yahoo.com/table.csv?s=ARCC&d=1&e=19&f=2014&g=d&a=9&b=7&c=2004&ignore=.csv
