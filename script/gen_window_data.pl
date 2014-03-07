#!/usr/bin/perl -w

use Configer;

my %config = Configer::init;

sub gen_price_window_data {
	#for my $file(`ls ../data/*.raw`) {
	my $file = Configer::get('data_matrix');
	my $mc_file = Configer::get('mc_matrix');

	open MCIN, "<$mc_file" or die "open $file failed...\n";
		#print "$file\n";

		open IN, "<$file" or die "open $file failed...\n";
		my $cname = <IN>;
		my $mc_cname = <MCIN>;
		$cname =~ s{\s+$}{}isg;
		$mc_cname =~ s{\s+$}{}isg;
		die "cname does not equal to mc_cname.\n" unless $cname eq $mc_cname;

		my @cname = split /\s+/, $cname;

		my @window_data;
		my @stamps;
		my $mcline;

		while(<IN>) {
			chomp;
			$mcline = <MCIN>;
			s{\s+$}{}isg;
			$mcline =~ s{\s+$}{}isg;

			my @v = split /\s+/;
			my @mcv = split /\s+/, $mcline;
			die "price date does not match market cap date.\n" unless $mcv[0] == $v[0];
			shift @mcv;

			push @stamps, shift @v;
			push @window_data, \@v;
			push @mc_window_data, \@mcv;
		}
		close IN;
	close MCIN;

		for(my $i = $config{'window_size'}-1; $i < @window_data; $i += $config{'step_day'}) {
			my $from = ($i-$config{'window_size'}+1);
			my $to = $i;

			open OUT, ">../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].data" or die "open ../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].data failed...\n";	
			print OUT (join(' ', @cname), "\n");
			print OUT (join(' ', @{$_}), "\n")  for @window_data[$from..$to];
			close OUT;

			open OUT, ">../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].dcap" or die "open ../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].dcap failed...\n";	
			for my $xi (0..$#cname) {
				print OUT $cname[$xi], " ", $mc_window_data[$to]->[$xi], "\n";
			}
			close OUT;
		}
		#}
}

&gen_price_window_data;
