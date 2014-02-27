#!/usr/bin/perl -w

use LWP 5.69;                                                    
use HTTP::Headers;                                               
use HTTP::Response;  

use LWP;
use JSON;
use Data::Dumper;
use HTTP::Cookies;
use LWP::ConnCache;
use HTTP::Request::Common qw(POST);
use IO::Uncompress::Gunzip qw(gunzip) ;
use URI;
use Mojo::DOM;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
$ENV{HTTPS_VERSION} = 3;

my $ag = LWP::UserAgent->new(requests_redirectable => [ 'GET', 'HEAD', 'POST' ]);

$ag->agent("Mozilla/5.0(windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36");
$ag->timeout(30);

my $json = new JSON;
my $cookie_jar = HTTP::Cookies->new; 
my $ycharts_cookies;

$cookie_jar->clear;

$ag->cookie_jar($cookie_jar);

my %tlist;
my $company_list = 'sp500';
my %black_list;

$black_list{'DELL'} = 1;
$black_list{'BMC'} = 1;
$black_list{'LTD'} = 1;
#$black_list{'FE'} = 1;
$black_list{'MOLX'} = 1;
$black_list{'NYX'} = 1;
$black_list{'SAI'} = 1;
$black_list{'WPO'} = 1;

sub read_ticker_list {
	open IN, "<../resource/${company_list}.list" or die "open ../resource/${company_list}.list failed...\n";
	while(<IN>) {
		chomp;
		#	s{\.}{-}isg;
		#$tlist{$_}++ if $_ ne "DELL";
		$tlist{$_}++ unless defined $black_list{$_};
	}
	close IN;
}

sub extract_market_cap {
	#print $res->content;
	my $dom = Mojo::DOM->new($_[0]);
#	print STDERR $res->content;

	my @date = $dom->find('table[class=histDataTable] tr td[class=col1]')->text->each;
	my @mc = $dom->find('table[class=histDataTable] tr td[class=col2]')->text->each;

	my @res;

	for my $i (0..$#mc) {
		#print "$date[$i]; $mc[$i]\n";
		push @res, [$date[$i], $mc[$i]];
	}
	\@res;
}

sub login {
	my $res = $ag->get('http://ycharts.com/companies/AAPL/market_cap');

	$cookie_jar->extract_cookies($res);
	$cookie_jar->save('ycharts_cookies.data');

	if($cookie_jar->as_string =~ m{csrftoken=(.*?);}is) {
		#print $1, "\n";
		$ycharts_cookies = $1;
	}
	#print $cookie_jar->as_string, "\n";

	sleep(5);

	$res = $ag->post('http://ycharts.com/login', {
			'csrfmiddlewaretoken' => $ycharts_cookies,
		'email' => 'rt77789@gmail.com',
		'password' => 'zh7758521',
		'next' => '%2Fcompanies%2FAAPL%2Fmarket_cap',
		'auth_submit' => 'Sign+In',
		'remember_me' => 'on'
		});

#	print $res->content;
}

sub download_mc {

	my $ticker = $_[0];

	my $start = "1%2F1%2F1962";
	my $end = "2%2F19%2F2014";

	my $header = HTTP::Headers->new("Accept" => "application/json, text/plain, */*",
		"Origin" => "http://ycharts.com",
		"User-Agent" => "Mozilla/5.0(windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
		"X-CSRFToken" => $ycharts_cookies,
		"Content-Type" => "application/x-www-form-urlencoded",
		"Referer" => "http://ycharts.com/companies/AAPL/market_cap",
		"Accept-Encoding" => "gzip,deflate,sdch",
		"Accept-Language" => "zh-CN,en-US;q=0.8,en;q=0.6,zh;q=0.4",
		"Connection" => "keep-alive",
		"Host" => "ycharts.com",
		"Cache-Control" => "max-age=0",
	);

	$ag->default_headers($header);

	my $submit_values = {
			'startDate' => $start,
			'endDate' => $end,
			'pageNum' => 2,
		};
		my $res = $ag->post("http://ycharts.com/companies/${ticker}/market_cap/data_ajax", $submit_values);

	my $obj = $json->decode($res->decoded_content(charset => 'none'));
	my $maxp = $obj->{'last_page_num'};
	my $table_html = $obj->{'data_table_html'};

	my @mc;

	#for my $i (1..$maxp) {
	for my $i (1..$maxp) {
		my $k = 1;
		my $res;
		while(1) {
			$res = $ag->post("http://ycharts.com/companies/${ticker}/market_cap/data_ajax", {
					'startDate' => $start,
					'endDate' => $end,
					'pageNum' => $i,
				});
			last if $res->is_success;
			print STDERR "retry $k times...\n";
			++$k;
		}

		$obj = $json->decode($res->decoded_content(charset => 'none'));

		my $tc = &extract_market_cap($obj->{'data_table_html'});
		push @mc, @{$tc};

		for my $k (@{$tc}) {
			print STDERR "$k->[0];$k->[1]\n";
		}
		print STDERR "$ticker, page $i/$maxp\n";
	}
	#sleep(2);
	#for my $k (sort keys %mc) {
		#print "$k, $mc{$k}\n";
		#}
	\@mc;
}

sub download_all_mc {
	my $flag = 0;
	my $tnum = keys %tlist;
	my $inum = 0;

	for my $t (sort keys %tlist) {
		#$flag = 1 if($t eq 'WMT') ;
		#next if $flag == 0;

		print $t, ",", $inum, "/", $tnum, "\n";
		++$inum;
		my $mc = &download_mc($t);

		open OUT, ">../resource/${company_list}_market_cap/$t.cap" or die "open ../resource/${company_list}_market_cap/$t.cap";
		for my $k (@{$mc}) {
			print OUT "$k->[0];$k->[1]\n";
		}
		close OUT;
		sleep(1);
	}
}

&read_ticker_list;	
&login;
&download_all_mc;
