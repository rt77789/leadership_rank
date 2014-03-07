#!/usr/bin/perl -w

use Configer;

my %config = Configer::init;
my $prefix = Configer::get('prefix');
my $type = 'mean_crank';

my %data;

for my $f (`ls ../data/*.msector`) {
	chomp $f;
	open IN, "<$f" or die "open $f failed...\n";
	while(<IN>) {
		chomp;
		my @tk = split /,/;

		$data{$tk[-1]}->{$tk[0]}->{$tk[1]} = $tk[2];
	}
	close IN;
}

for my $k (sort keys %{$data{$type}}) {
	print $k;
	for my $ik (sort { $data{$type}->{$k}->{$b} <=> $data{$type}->{$k}->{$a} } keys %{$data{$type}->{$k}}) {
		print ",", $ik, ":", $data{$type}->{$k}->{$ik};
	}
	print "\n";
}

