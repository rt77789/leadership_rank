#!/usr/bin/perl -w


use Configer;
use LWP;

#my %cap = Configer::load_cap_file;

#for my $k (sort keys %cap) {
#    print "$k, $cap{$k}\n";
#}

use Mojo::DOM;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
my $ag = LWP::UserAgent->new;
$ag->cookie_jar({});

$res = $ag->get('http://ycharts.com/companies/AAPL/market_cap');

	#print $res->content;
	my $dom = Mojo::DOM->new($res->content);
#	print STDERR $res->content;


	#print $_->text for $dom->find('div')->each;
	my @ds = $dom->find('table[class=histDataTable] tr td[class=col1]')->each;


	print $_, "\n" for @ds;
	



