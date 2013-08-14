#!/usr/bin/perl -w

use LWP;

# Data between [from, to] are extracted.
my $from = 1374586200;
my $to = 1374609600;

my %tickers;
### Read stock tickers list that needs to be downloaded.
sub read_tickers {
	open TI, "<../resource/sp500.list" or die "open ../resource/sp500.list failed...\n";
	while(<TI>) {
		chomp;
		$tickers{$_} = 1;
	}
	close TI;
}

## Download all data from google.
sub download_data {
	my $max_day = 15;
	my $interval = 60;
	my $url = "http://www.google.com/finance/getprices?i=${interval}&p=${max_day}d&f=d,o,h,l,c,v&df=cpct&q=";

	my $ag = LWP::UserAgent->new( timeout => 5, keep_alive => 1);
	#$ag->conn_cache(LWP::ConnCache->new());
	#$ag->timeout(10);
	$ag->agent('Mozilla/5.0');
	$ag->cookie_jar({});

	my $od = '../resource/15intraday';
	`mkdir $od` unless -d "$od";

	for my $ti (sort keys %tickers) {
		print STDERR "$ti is downloaded...=$url$ti\n";
		
		my $res;
		my $num = 1;
		do {
			$res = $ag->get($url."$ti");
			#&parse_data($res->content);
			print STDERR "$ti retry $num.\n";
			$num++;
		} while(!$res->is_success);

		open TO, ">$od/$ti.15intraday" or die "open $od/$ti.15intraday failed...\n";
		print TO $res->content;
		close TO;
		sleep(rand(5));
	}
}

## Parse the crawled data and return the price list.
sub parse_data {
	my $od = '../resource/15intraday';
	my $rd = '../resource/n15intraday';

	for my $ti (sort keys %tickers) {
		open TO, "<$od/$ti.15intraday" or die "open $od/$ti.15intraday failed...\n";
		<TO> for (1..7);
		my %dd;
		my $start = 0;

		while(<TO>) {
			chomp;
			my @tk = split /,/;
			if($tk[0] =~ m{^a(.*?)$}is) {
				$start = $1;
				$tk[0] = 0;
			}
			$dd{$tk[0] * 60  + $start} = [@tk[1..$#tk]];
		}
		close TO;

		`mkdir $rd` unless -d $rd;

		open TO, ">$rd/$ti.n15intraday" or die "open $rd/$ti.n15intraday failed...\n";
		print TO "timestamp,open,high,low,close,volume\n";
		for my $k (sort { $a <=> $b } keys %dd) {
			print TO "$k,", join(",", @{$dd{$k}}), "\n" if $k >= $from and $to >= $k;
		}
		close TO;
	}
}

sub main {
	&read_tickers;
#	&download_data;
	&parse_data;
}

&main;
