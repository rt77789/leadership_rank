#!/usr/bin/perl -w
use Configer;

my $file_prefix = Configer::get('file_prefix');
my $prefix = Configer::get('prefix');

## clean market_cap_clean.
`rm ../resource/${prefix}_market_cap_clean/*.clean`;

## clean range_price and range_market_cap.
`rm ../resource/${prefix}_range_price/*.price.range`;
`rm ../resource/${prefix}_range_market_cap/*.cap.range`;

## clean range_interpolated.
`rm ../resource/${prefix}_range_interpolated_price/*.price.range.interpolate`;
`rm ../resource/${prefix}_range_interpolated_market_cap/*.cap.range.interpolate`;

## clean the data files.
`rm ../data/*.data`;
`rm ../data/*.log`;
`rm ../data/*.rank`;
`rm ../data/*.crank`;
`rm ../data/*.mat`;

