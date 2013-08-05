#!/usr/bin/perl -w

###
my $cn = <>;
print $cn;
my $thresh = 0.4;

while(<>) {
	chomp;
	my @tk = split /\s+/;
	
	for my $i (1..$#tk) {
		$tk[$i] = 0 if $tk[$i] < $thresh;
	}
	print join(' ', @tk), "\n";
}
