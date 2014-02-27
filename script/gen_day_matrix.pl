#!/usr/bin/perl -w

use Configer;

my %config = Configer::init;
my $prefix = Configer::get('prefix');
my %valid_comps;
my %matrix;

sub get_valid_comps {
		for my $f (`ls ../resource/${prefix}_range_interpolated_price/*`) {
		chomp $f;
		$f =~ s{^.*?_range_interpolated_price/(.*?).price\.range\.interpolate$}{$1}isg;
		$valid_comps{$f}++;	
	}

	for my $f (`ls ../resource/${prefix}_range_interpolated_market_cap/*`) {
		chomp $f;
		$f =~ s{^.*?_range_interpolated_market_cap/(.*?)\.cap.range\.interpolate$}{$1}isg;
		$valid_comps{$f}++;	
	}
}

sub gen_day_matrix {
	for my $f (sort keys %valid_comps) {
		next if $valid_comps{$f} != 2;

		open IN, "<../resource/${prefix}_range_interpolated_price/$f.price.range.interpolate" or die "open ../resource/${prefix}_range_interpolated_price/$f.price.range.interpolate failed...\n";

		while(<IN>) {
			chomp;
			my @tk = split /,/;
			$matrix{$tk[1]}->{$f} = $tk[5];
		}
		close IN;
	}

	my $data_matrix = Configer::get('data_matrix');

	open OUT, ">$data_matrix" or die "open $data_matrix failed...\n";

	for my $d (sort keys %matrix) {
		my @td;
		for my $k (sort keys %{$matrix{$d}}) {
			push @td, "\"$k\"";
		}
		print OUT join(' ', @td), "\n";
		last;
	}
	for my $d (sort keys %matrix) {
		print OUT "$d";
		for my $k (sort keys %{$matrix{$d}}) {
			print OUT " \"$matrix{$d}->{$k}\"";
		}
		print OUT "\n";
	}
	close OUT;
}

&get_valid_comps;
&gen_day_matrix;
