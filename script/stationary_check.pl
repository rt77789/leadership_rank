#!/usr/bin/perl -w

for my $file (sort `ls ../data/sp500_128_20*.log`) {
	chomp($file);

	print STDERR "start $file...\n";
    print "$file\n";
	`Rscript stationary_check.R $file`;
}
