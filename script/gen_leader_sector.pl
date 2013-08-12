#!/usr/bin/perl -w

sub gen_leader_sector {
	my @date;
	my $prefix;
	for my $file (sort `ls ../data/sp500_128_*.data`) {
		chomp($file);
		$file =~ s{\.data$}{}isg;
		$file =~ m{(.+)_(.+?)_(.+?)$} or die "$file date extract fail.\n";
		push @date, $2, $3;
		$prefix = $1;
	}

	@date = sort @date;

	open SEC, ">${prefix}_$date[1]_$date[-1].msector" or die "${prefix}_$date[1]_$date[-1].msector failed...\n";
	open IND, ">${prefix}_$date[1]_$date[-1].mindustry" or die "${prefix}_$date[1]_$date[-1].mindustry failed...\n";

	print SEC "date,sector,value,model\n";
	print IND "date,industry,value,model\n";

	for my $file (sort `ls ../data/sp500_128_*.data`) {
		chomp($file);
		$file =~ s{\.data$}{}isg;
		my $date = $file;
		$date =~ s{.+_(.+?)_(.+?)$}{$1_$2}is;

		for my $suf ("rank", "crank") {
			my %sscore;
			my %snum;
			my %iscore;
			my %inum;
			open RANK, "<${file}_comps_thresh_0.$suf" or die "open ${file}_comps_thresh_0.$suf failed...\n";
			while(<RANK>) {
				# 
				chomp;
				m{^".*?"\s+(.*?)\s+(.*?)\s+"(.*?)"\s+"(.*?)"$}isg or die "$_ can't match.\n";
				my ($score, $cap, $sector, $industry) = ($1, $2, $3, $4);
				#print "$score, $cap, $sector, $industry\n";
				$sscore{$sector} += $score;
				$snum{$sector}++;
				$iscore{$industry} += $score;
				$inum{$industry}++;
			}
			close RANK;

			for my $si (keys %sscore) {
				print SEC "$date,\"$si\",$sscore{$si},sum_$suf\n";
			}
			#print "$_\n" for keys %snum;
			for my $si (keys %sscore) {
				print SEC "$date,\"$si\",", $sscore{$si} / $snum{$si}, ",mean_$suf\n";
			}


			for my $ii (keys %iscore) {
				print IND "$date,\"$ii\",$iscore{$ii},sum_$suf\n";
			}
			#print "$_\n" for keys %snum;
			for my $ii (keys %iscore) {
				print IND "$date,\"$ii\",", $iscore{$ii} / $inum{$ii}, ",mean_$suf\n";
			}
		}
	}
	close IND;
	close SEC;

}

&gen_leader_sector;
