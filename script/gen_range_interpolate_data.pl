#!/usr/bin/perl -w

use Configer;

my %config = Configer::init;
my $prefix = Configer::get_prefix;

for my $f (`ls ../resource/${prefix}_range_price/*.price.range`) {
	chomp $f;
	$f =~ m{_range_price/(.*?).price.range}is or die "$f cannot parse...\n";
`Rscript linear_interpolate.R $f ../resource/${prefix}_range_interpolated_price/$1.price.range.interpolate `;
	print "$f has been processed...\n";
}

for my $f (`ls ../resource/${prefix}_range_market_cap/*.cap.range`) {
	chomp $f;
	$f =~ m{_range_market_cap/(.*?).cap.range}is or die "$f cannot parse...\n";
`Rscript linear_interpolate.R $f ../resource/${prefix}_range_interpolated_market_cap/$1.cap.range.interpolate `;
	print "$f has been processed...\n";
}
