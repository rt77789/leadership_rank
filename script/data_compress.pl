#!/usr/bin/perl -w

###
my $cn = <>;
open MP, ">../data/company.map" or die "open ../data/company.map fail.\n";
print MP $cn;
close MP;

chomp($cn);
my %comps;
my $num = 1;
my $thresh = 0.4;

$comps{$_} = $num++ for (split /\s+/, $cn);

while(<>) {
	chomp;
	my @tk = split /\s+/;
	my $i = $comps{$tk[0]};
	for my $j (1..$#tk) {
		#$tk[$j] = 0 if $tk[$j] < $thresh;
		print "$i $j $tk[$j]\n" if $tk[$j] > $thresh;
	}
}
