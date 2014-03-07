#!/usr/bin/perl -w

my $top_k = 3;

### Generate evoluting data of sp500. ###
sub gen_top_k_stock {
	my @date;
	my $prefix;
	for my $file (sort `ls ../data/sp*.log`) {
		chomp($file);
		$file =~ s{\.log$}{}isg;
		$file =~ m{(.+)_(.+?)_(.+?)$} or die "$file date extract fail.\n";
		push @date, $2, $3;
		$prefix = $1;
	}
	@date = sort @date;

	my @suf = ('crank');

	for my $i (0..$#suf) {

		my %comps;
		for my $file (sort `ls ../data/sp*.log`) {
			chomp($file);

			#print STDERR "start $file...\n";
			$file =~ s{\.log$}{}isg;
			#
			open RF, "<${file}_comps_thresh_0.$suf[$i] " or die "open ${file}_comps_thresh_0.$suf[$i] failed...\n";
			$file =~ s{.+_(.+?)_(.+?)$}{$1_$2}is;
			my $tnum = 0;
			my %tsec;

			while(<RF>) {
				chomp;
				die "$_ can't match.\n" unless m{^"(.*?)"\s+(\S+)\s+(\S+)\s+"(.*?)"\s+"(.*?)"$}is;
				#my @tk = split/\s+/;
				#$comps{$file} = $tk[1];
				$tsec{$4} = $2 unless defined $tsec{$4};
			}
			close RF;

			print "$file";
			for my $ik (sort { $tsec{$b} <=> $tsec{$a} } keys %tsec) {
				print ",$ik";
				++$tnum;
				last if $tnum >= $top_k;
			}
			print "\n";
		}
	}
}

	&gen_top_k_stock;
