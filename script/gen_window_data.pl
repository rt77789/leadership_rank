#!/usr/bin/perl -w

use Configer;

my %config = Configer::init;

sub gen_window_data {
	for my $file(`ls ../data/*.raw`) {
		chomp $file;
		#print "$file\n";

		open IN, "<$file" or die "open $file failed...\n";
		my $cname = <IN>;
		$cname =~ s{\s+$}{}isg;
		my @cname = split /\s+/, $cname;
		my @window_data;
		my @stamps;

		while(<IN>) {
			chomp;
			s{\s+$}{}isg;
			my @v = split /\s+/;
			push @stamps, shift @v;
			push @window_data, \@v;
		}
		close IN;

		for(my $i = $config{'window_size'}-1; $i < @window_data; $i += $config{'step_day'}) {
			my $from = ($i-$config{'window_size'}+1);
			my $to = $i;
			open OUT, ">../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].data" or die "open ../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].data failed...\n";	
			print OUT (join(' ', @cname), "\n");
			print OUT (join(' ', @{$_}), "\n")  for @window_data[$from..$to];
			close OUT;
		}
	}
}

&gen_window_data;
