#!/usr/bin/perl -w


### Generate evoluting data of sp500. ###
sub gen_company_evolute {
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
    
    my @osuf = ('evolute', 'cevolute');
    my @suf = ('rank', 'crank');
    for my $i (0..$#suf) {
        open EVO, ">${prefix}_$date[1]_$date[-1].$osuf[$i]" or die "${prefix}_$date[1]_$date[-1].$osuf[$i] failed...\n";

        my %comps;
        for my $file (sort `ls ../data/sp*.log`) {
            chomp($file);

            print STDERR "start $file...\n";
            $file =~ s{\.log$}{}isg;
            #
            open RF, "<${file}_comps_thresh_0.$suf[$i] " or die "open ${file}_comps_thresh_0.$suf[$i] failed...\n";
            $file =~ s{.+_(.+?)_(.+?)$}{$1_$2}is;
            while(<RF>) {
                my @tk = split/\s+/;
                $comps{$file}->{$tk[0]} = $tk[1];
            }
            close RF;
        }

        my %cc;
        my @cc;
        for my $d (sort keys %comps) {
            for $c (sort keys %{$comps{$d}}) {
                $cc{$c}++;
                push @cc, $c if $cc{$c} == keys %comps;
            }
        }

        for my $c (@cc) {
            print EVO "$c", $c eq $cc[-1] ? "\n" : " ";
        }

        for my $d (sort keys %comps) {
            print EVO "\"$d\" ";
            for $c (@cc) {
                print EVO "$comps{$d}->{$c}", $c eq $cc[-1] ? "\n" : " ";
            }
        }
    }
    close EVO;
}

&gen_company_evolute;
