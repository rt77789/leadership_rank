#!/usr/bin/perl -w

my %date;

sub gen_common_data {

    for my $file (`ls ../data/hist_price`) {
        chomp($file);
        open HP, "<../data/hist_price/$file" or die "open ../data/hist_price/$file failed...";
        my @cp;
        <HP>;
        while(<HP>) {
            chomp;
            my @tk = split /,/;
            $date{$tk[0]}++;            
        }
        close HP;
    }

    my $md = 0;
    for my $k (keys %date) {
        $md = $date{$k} if $md < $date{$k};
        #print "$k, $date{$k}\n";
    }

    my @resd;
    $md -= 500;
    for (keys %date) {
        push @resd, $_ if $date{$_} > $md;
    }
    open COM, ">../data/common_date.info" or die "open ../data/common_date.info failed..\n";
    print COM "$_, $md\n" for reverse sort @resd;
    close COM;
}

sub data_build {
    ### read common date.
    open COM, "<../data/common_date.info" or die "open ../data/common_date.info failed...\n";
    my %com_date;
    my $K = 128;
    my $cn = 0;
    while(<COM>) {
        chomp;
        s{,.*$}{}isg;
        print STDERR "$_\n";
        $com_date{$_} = 1;
        $cn++;
        # we only select the last K days' values.
        last if $cn >= $K;
    }
    close COM;

    #### 
    my %data;
    for my $file (`ls ../data/hist_price`) {
        chomp($file);
        open HP, "<../data/hist_price/$file" or die "open ../data/hist_price/$file failed...";
        my @cp;
        <HP>;
        while(<HP>) {
            chomp;
            my @tk = split /,/;
            last unless defined $com_date{$tk[0]};

            print STDERR "$tk[0], $tk[4], $file\n";

            push @cp, $tk[4];
            last if @cp == $K;
        }
        close HP;
        
        if(@cp >= $K) {
            $data{$file} = \@cp;
        }
        else {
            print STDERR $#cp+1, ", $K, $file\n";
        }
    }

    ### Print the data.
    print "$_ " for sort keys %data;
    print "\n";
    for my $i (0..($K-1)) {
        print "$data{$_}->[$K-1-$i] " for sort keys %data;
        print "\n";
    }
}

sub sp500_build {
    ### read common date.
    open COM, "<../data/common_date.info" or die "open ../data/common_date.info failed...\n";
    my %com_date;
    my $K = 128;
    my $cn = 0;
    while(<COM>) {
        chomp;
        s{,.*$}{}isg;
        print STDERR "$_\n";
        $com_date{$_} = 1;
        $cn++;
        # we only select the last K days' values.
        last if $cn >= $K;
    }
    close COM;

    my %sp500;
    open LIST, "<../data/sp_500.list" or die "open ../data/sp_500.list failed...\n";
    while(<LIST>) {
        chomp;
        $sp500{"$_.raw"} = 1;
    }
    close LIST;

    #### 
    my %data;
    for my $file (`ls ../data/hist_price`) {
        chomp($file);
        ## only select sp500 companies.
        next unless defined $sp500{$file};

        open HP, "<../data/hist_price/$file" or die "open ../data/hist_price/$file failed...";
        my @cp;
        <HP>;
        while(<HP>) {
            chomp;
            my @tk = split /,/;
            last unless defined $com_date{$tk[0]};

            print STDERR "$tk[0], $tk[4], $file\n";

            push @cp, $tk[4];
            last if @cp == $K;
        }
        close HP;
        
        if(@cp >= $K) {
            $data{$file} = \@cp;
        }
        else {
            print STDERR $#cp+1, ", $K, $file\n";
        }
    }

    ### Print the data.
    print "$_ " for sort keys %data;
    print "\n";
    for my $i (0..($K-1)) {
        print "$data{$_}->[$K-1-$i] " for sort keys %data;
        print "\n";
    }
}

#&gen_common_data;
#&data_build;
&sp500_build;

