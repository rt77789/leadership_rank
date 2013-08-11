#!/usr/bin/perl -w

my %sp;
my $comp_num = 0;

sub read_list {
    open LIST, "<../data/company.list" or die "../data/company.list";
    my @res_comps;
    while(<LIST>) {
        chomp;
        s{^\[(.*?)\]}{}is or die "sector match error!!\n";
        my $sec = $1;
        print "$sec\n";
        while(s{^\[(.*?)\]}{}is) {
            my $temp = $1;
            my $delimit = chr(5);
            my @comps = split /$delimit/, $temp;
            my $indust = shift @comps;

            $indust =~ s{\(http:.*?\)$}{}isg;

            @comps = map { s{\(http:.*?\)$}{}isg; $_ } @comps;

            $sp{$sec}->{$indust} = \@comps;
            print "\t$indust\n";

            print "\t\t$_\n" for (@comps);

            $comp_num += @comps;
            push @res_comps, @comps;
        }
    }
    print STDERR "companies number=$comp_num\n";
    close LIST;
    \@res_comps;
}

sub count_line_price {
    my %count;
    for my $file (`ls ../data/hist_price`) {
        chomp($file);
        open HP, "<../data/hist_price/$file" or die "open ../data/hist_price/$file failed...";
        my $lines = 0;
        while(<HP>) {
            $lines++;
        }
        close HP;
        $count{$file} = $lines;
        #print "$file, $lines\n";
    }

    for my $k (sort {$count{$b} <=> $count{$a} } keys %count) {
        print "$k, $count{$k}\n"; 
    }
}

sub get_nonexist_file {
    my $comps =    &read_list;
    my $count = 0;

    for my $c (@{$comps}) {
        $count++, print "$c.raw\n" unless -e "../data/hist_price/$c.raw";
    }

    print "nonexist files number=$count\n";
}

sub count_industry {
    open LIST, "<../data/company.list" or die "../data/company.list";
    while(<LIST>) {
        chomp;
        s{^\[(.*?)\]}{}is or die "sector match error!!\n";
        my $sec = $1;
        print "$sec\n";
        while(s{^\[(.*?)\]}{}is) {
            my $temp = $1;
            my $delimit = chr(5);
            my @comps = split /$delimit/, $temp;
            my $indust = shift @comps;

            $indust =~ s{\(http:.*?\)$}{}isg;

            @comps = map { s{\(http:.*?\)$}{}isg; $_ } @comps;

            $sp{$sec}->{$indust} = \@comps;
            print "\t$indust\n";

            print "\t\t$_\n" for (@comps);

            $comp_num += @comps;
        }
    }
    print STDERR "companies number=$comp_num\n";
    close LIST;

    ####
    my $indus_num = 0;
    for my $k (keys %sp) {
        my @a = keys %{$sp{$k}};
        print "sector=$k, industry_num=", $#a+1, "\n";
        $industry_num += $#a + 1;
    }
    print "total industry_num=$industry_num\n";
}

### Generate evoluting data of sp500. ###
sub gen_sp500_evoluting {
	my %comps;
	for my $file (sort `ls ../data/sp500_128_*.data`) {
		chomp($file);

		print STDERR "start $file...\n";
		$file =~ s{\.data$}{}isg;
		#
		open RF, "<${file}_comps_thresh_0.crank" or die "open ${file}_comps_thresh_0.crank failed...\n";
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
		print "$c", $c eq $cc[-1] ? "\n" : " ";
	}

	for my $d (sort keys %comps) {
		print "\"$d\" ";
		for $c (@cc) {
			print "$comps{$d}->{$c}", $c eq $cc[-1] ? "\n" : " ";
		}
	}
}

sub cal_sp500_mean_rank {
	my %comps;
    my %cnum;
    my $mtype = $_[0] eq 'pagerank' ? 'rank' : 'crank';


	for my $file (sort `ls ../data/sp500_128_*.data`) {
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
    if($_[1] eq 'mrank') {
        for my $c (sort {$comps{$a}/$cnum{$a} <=> $comps{$b}/$cnum{$b}} keys %comps) {
            print "$c ", $comps{$c} / $cnum{$c}, "\n";
        }
    }
    else {
        ## mscore.
        for my $c (sort {$comps{$b}/$cnum{$b} <=> $comps{$a}/$cnum{$a}} keys %comps) {
            print "$c ", $comps{$c} / $cnum{$c}, "\n";
        }
    }
}

sub trim {
    my $res = $_[0];
    $res =~ s{^\s*}{}is;
    $res =~ s{\s*$}{}is;
    $res;
}

sub gen_sp500_sector {
	my %sec;

    print "date,sector,value,model\n";
	for my $file (sort `ls ../data/sp500_128_*.data`) {
		chomp($file);
		$file =~ s{\.data$}{}isg;
		open RF, "<${file}.log" or die "open ${file}.log failed...\n";
        <RF>; <RF>;
		$file =~ s{.+_(.+?)_(.+?)$}{$1_$2}is;
        for my $m (1..4) {
            <RF>;
            for (1..5) {
                my $ts = <RF>;
                my $tv = <RF>;
                chomp($ts);
                chomp($tv);

                my $len = length("Telecommunications Services");
                my $sn1 = &trim(substr($ts, 0, $len));
                my $sv1 = &trim(substr($tv, 0, $len));
                my $sn2 = &trim(substr($ts, $len));
                my $sv2 = &trim(substr($tv, $len));

                #print "$sn1, $sv1, $sn2, $sv2\n";
                print "$file,$sn1,$sv1,$m\n";
                print "$file,$sn2,$sv2,$m\n";
            }
        }
        close RF;
    }
}
#&get_nonexist_file;

#&count_industry;
#&gen_sp500_evoluting;
&cal_sp500_mean_rank($ARGV[0], $ARGV[1]);
#&gen_sp500_sector;
