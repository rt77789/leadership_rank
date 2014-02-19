#!/usr/bin/perl -w


use Configer;

my %cap = Configer::load_cap_file;

for my $k (sort keys %cap) {
    print "$k, $cap{$k}\n";
}
