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

&get_nonexist_file;
