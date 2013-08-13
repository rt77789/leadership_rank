#!/usr/bin/perl -w

sub gen_campany_mean_rank {
    
	my %comps;
    my %cnum;
    my $mtype = $_[0] eq 'pagerank' ? 'rank' : 'crank';
    my $ofile = $_[2];

	for my $file (sort `ls ../data/sp*.data`) {
		chomp($file);

		print STDERR "start $file...\n";
		$file =~ s{\.data$}{}isg;
		#
		open RF, "<${file}_comps_thresh_0.$mtype" or die "open ${file}_comps_thresh_0.$mtype failed...\n";
        my $cr = 1;
		while(<RF>) {
			my @tk = split/\s+/;
            if($_[1] eq 'mrank') {
                $comps{$tk[0]} += $cr;
            }
            else {
                ## mscore.
                $comps{$tk[0]} += $tk[1];
            }
            $cnum{$tk[0]}++;
            ++$cr;
		}
		close RF;
    }
    open ME, ">$ofile" or die "open $ofile failed...\n";
    if($_[1] eq 'mrank') {
        for my $c (sort {$comps{$a}/$cnum{$a} <=> $comps{$b}/$cnum{$b}} keys %comps) {
            print ME "$c ", $comps{$c} / $cnum{$c}, "\n";
        }
    }
    else {
        ## mscore.
        for my $c (sort {$comps{$b}/$cnum{$b} <=> $comps{$a}/$cnum{$a}} keys %comps) {
            print ME "$c ", $comps{$c} / $cnum{$c}, "\n";
        }
    }
    close ME;
}

sub main {
my @date;
	my $prefix;
	for my $file (sort `ls ../data/sp*.data`) {
		chomp($file);
		$file =~ s{\.data$}{}isg;
		$file =~ m{(.+)_(.+?)_(.+?)$} or die "$file date extract fail.\n";
		push @date, $2, $3;
		$prefix = $1;
	}
	@date = sort @date;

    &gen_campany_mean_rank('pagerank', 'mrank', ">${prefix}_$date[1]_$date[-1].mrank");
    &gen_campany_mean_rank('pagerank', 'mscore', ">${prefix}_$date[1]_$date[-1].mscore");
    &gen_campany_mean_rank('circuit', 'mcrank', ">${prefix}_$date[1]_$date[-1].mcrank");
    &gen_campany_mean_rank('circuit', 'mcscore', ">${prefix}_$date[1]_$date[-1].mcscore");
}

&main;
