#!/usr/bin/perl -w

use LWP;
use JSON;
use Data::Dumper;
use HTTP::Cookies;
use LWP::ConnCache;
use HTTP::Request::Common qw(GET);
use IO::Uncompress::Gunzip qw(gunzip) ;
use URI;
use Mojo::DOM;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
$ENV{HTTPS_VERSION} = 3;

my $ag = LWP::UserAgent->new(requests_redirectable => [ 'GET', 'HEAD', 'POST' ]);

$ag->agent("Mozilla/5.0(windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36");
$ag->timeout(10);

my $json = new JSON;
my $cookie_jar = HTTP::Cookies->new; 
my $ycharts_cookies;

$cookie_jar->clear;

$ag->cookie_jar($cookie_jar);


sub extract_market_cap {
	#print $res->content;
	my $dom = Mojo::DOM->new($_[0]);
#	print STDERR $res->content;

	my @date = $dom->find('table[class=histDataTable] tr td[class=col1]')->text->each;
	my @mc = $dom->find('table[class=histDataTable] tr td[class=col2]')->text->each;

	my %res;

	for my $i (0..$#mc) {
		#print "$date[$i]; $mc[$i]\n";
		$res{$date[$i]} = $mc[$i];
	}
	\%res;
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

	print $res->content;

	#my $url = new URI("http://ycharts.com/login");

#	my %aryParams = (
#		'csrfmiddlewaretoken' => $ycharts_cookies,
#		'email' => 'rt77789%40gmail.com',
#		'password' => 'zh7758521',
#		'next' => '%2Fcompanies%2FAAPL%2Fmarket_cap',
#		'auth_submit' => 'Sign+In',
#		'remember_me' => 'on'
#	);
#	$url->query_form('csrfmiddlewaretoken' => $ycharts_cookies,
#			'email' => 'rt77789%40gmail.com',
#			'password' => 'zh7758521',
#			'next' => '%2Fcompanies%2FAAPL%2Fmarket_cap',
#			'auth_submit' => 'Sign+In',
#			'remember_me' => 'on',
#		);
#
##	for (keys %aryParams) {
##		$url->query_form([$_, $aryParams{$_});
##	}
#
#	my @header = ("Accept-Encoding" => "gzip,deflate,sdch",
#		"Referer" => "http://ycharts.com/login?next=/companies/AAPL/market_cap",
#		"Accept-Language" => "zh-CN,en-US;q=0.8,en;q=0.6,zh;q=0.4",
#		"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
#		"Origin" => "http://ycharts.com",
#		"User-Agent" => "Mozilla/5.0(windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
#		"Content-Type" => "application/x-www-form-urlencoded",
#		"Connection" => "keep-alive",
#		"Host" => "ycharts.com",
#		"Cache-Control" => "max-age=0"
#	);
#
##construct the date.
#
#	$request = HTTP::Request->new('POST'); #GET=>"http://ybh.ybcoin.com/btc_sum?t=".rand());
#
#	$request->header(@header);
#	$request->url($url);
#
#	$res = $ag->request($request);
#
	#print $res->success, "\n";

		#print $res->decoded_content(charset => 'none');

#	my $obj = $json->decode($res->decoded_content(charset => 'none'));
}

sub download_mc {

	#my $dom = Mojo::DOM->new($res->content);
#	print STDERR $res->content;
#<span id="lastPageNum" ng-bind="historicalData.lastPage" class="ng-binding">89</span>

	#my @maxp = $dom->find('span[id=lastPageNum]');
	#print @maxp, "\n";
	my $start = "1%2F1%2F1962";
	my $end = "2%2F19%2F2014";

#	my $res = $ag->post("http://ycharts.com/companies/AAPL/market_cap/data_ajax",
#		{
#			'startDate' => $start,
#			'endDate' => $end,
#			'pageNum' => 2,
#		});
#
#	my $obj = $res->decoded_content(charset => 'none');
#	#print $obj;
#
#	#print $cookie_jar->as_string, "\n";
#	print "The structure of obj: ".Dumper($obj);
#
#	#for my $p (1..$maxp) {
#	#	my $params = "startDate=$start&endDate=$end&pageNum=$p";
#	#	my $mc = &extract_market_cap($res->content);
#	#}
	my $url = new URI("http://ycharts.com/companies/AAPL/market_cap/data_ajax");
	#/companies/AAPL/market_cap/data_ajax
	my %aryParams = (
		'startDate' => $start,
		'endDate' => $end,
		'pageNum' => 2
	);
	$url->query_form('startDate' => $start,
		'endDate' => $end,
		'pageNum' => 2);

	my $header = $h = HTTP::Headers->new(

	my @header = ("Accept" => "application/json, text/plain, */*",
		"Origin" => "http://ycharts.com",
		"User-Agent" => "Mozilla/5.0(windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
		"X-CSRFToken" => $ycharts_cookies,
		"Content-Type" => "application/x-www-form-urlencoded",
		"Referer" => "http://ycharts.com/companies/AAPL/market_cap",
		"Accept-Encoding" => "gzip,deflate,sdch",
		"Accept-Language" => "zh-CN,en-US;q=0.8,en;q=0.6,zh;q=0.4",
		"Connection" => "keep-alive",
		"Host" => "ycharts.com",
		"Cache-Control" => "max-age=0"
	);

	$request = HTTP::Request->new('POST'); #GET=>"http://ybh.ybcoin.com/btc_sum?t=".rand());

	$request->header(@header);
	$request->url($url);

	$res = $ag->request($request);
	my $obj = $res->decoded_content(charset => 'none');
	#print $obj;

	#print $cookie_jar->as_string, "\n";
	print "The structure of obj: ".Dumper($obj);

}



&login;
sleep(10);
&download_mc;
