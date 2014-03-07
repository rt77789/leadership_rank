#!/usr/bin/perl -w

use Configer;

my %config = Configer::init;
my $prefix = Configer::get('prefix');
my %valid_comps;
my %matrix;
my %mc_matrix;

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

		open IN, "<../resource/${prefix}_range_interpolated_market_cap/$f.cap.range.interpolate" or die "open ../resource/${prefix}_range_interpolated_market_cap/$f.cap.range.interpolate failed...\n";

		while(<IN>) {
			chomp;
			my @tk = split /,/;
			$mc_matrix{$tk[1]}->{$f} = $tk[2];
		}
		close IN;
	}

	my $mc_data_matrix = Configer::get('mc_matrix');
	open OUT, ">$mc_data_matrix" or die "open $mc_data_matrix failed...\n";

	for my $d (sort keys %mc_matrix) {
		my @td;
		for my $k (sort keys %{$mc_matrix{$d}}) {
			push @td, "\"$k\"";
		}
		print OUT join(' ', @td), "\n";
		last;
	}
	for my $d (sort keys %mc_matrix) {
		print OUT "$d";
		for my $k (sort keys %{$mc_matrix{$d}}) {
			print OUT " \"$mc_matrix{$d}->{$k}\"";
		}
		print OUT "\n";
	}

	close OUT;

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
