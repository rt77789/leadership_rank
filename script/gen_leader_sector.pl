#!/usr/bin/perl -w

use Configer;

sub gen_leader_sector {
	my @date;
	my $prefix;
        my %cap = Configer::load_cap_file;
        
	for my $file (sort `ls ../data/sp*.log`) {
		chomp($file);
		$file =~ s{\.log$}{}isg;
		$file =~ m{(.+)_(.+?)_(.+?)$} or die "$file date extract fail.\n";
		push @date, $2, $3;
		$prefix = $1;
	}

	@date = sort @date;

	open SEC, ">${prefix}_$date[0]_$date[-1].msector" or die "${prefix}_$date[0]_$date[-1].msector failed...\n";
	open IND, ">${prefix}_$date[0]_$date[-1].mindustry" or die "${prefix}_$date[0]_$date[-1].mindustry failed...\n";

	print SEC "date,sector,value,model\n";
	print IND "date,industry,value,model\n";

	for my $file (sort `ls ../data/sp*.log`) {
		chomp($file);
		$file =~ s{\.log$}{}isg;
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
				m{^"(.*?)"\s+(.*?)\s+(.*?)\s+"(.*?)"\s+"(.*?)"$}isg or die "$_ can't match.\n";
				my ($tik, $score, $cap, $sector, $industry) = ($1, $2, $3, $4, $5);
				#print "$score, $cap, $sector, $industry\n";
				$sscore{$sector} += $score * $cap{$tik};
				$snum{$sector} += $cap{$tik};
				$iscore{$industry} += $score * $cap{$tik};
				$inum{$industry} += $cap{$tik};
			}
			close RANK;

			for my $si (keys %sscore) {
				print SEC "$date,\"$si\",$sscore{$si},sum_$suf\n";
			}
			#print "$_\n" for keys %snum;
			for my $si (keys %sscore) {
                            print STDERR "$sscore{$si}, $snum{$si}\n";
				print SEC "$date,\"$si\",", $sscore{$si} / $snum{$si}, ",mean_$suf\n";
			}


			for my $ii (keys %iscore) {
				print IND "$date,\"$ii\",$iscore{$ii},sum_$suf\n";
			}
			#print "$_\n" for keys %snum;
			for my $ii (keys %iscore) {
				print IND "$date,\"$ii\",", $inum{$ii} > 0 ? $iscore{$ii} / $inum{$ii} : 0, ",mean_$suf\n";
			}
		}
	}
	close IND;
	close SEC;
}

&gen_leader_sector;
