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
    $md -= 100;
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
    while(<COM>) {
        chomp;
        s{,.*$}{}isg;
        print STDERR "$_\n";
        $com_date{$_} = 1;
    }
    close COM;

    #### 
    my %data;
    my $K = 128;
    for my $file (`ls ../data/hist_price`) {
        chomp($file);
        open HP, "<../data/hist_price/$file" or die "open ../data/hist_price/$file failed...";
        my @cp;
        <HP>;
        while(<HP>) {
            chomp;
            my @tk = split /,/;
            next unless defined $com_date{$tk[0]};

            print STDERR "$tk[0], $tk[4]\n";

            push @cp, $tk[4];
            last if @cp == $K;
        }
        close HP;
        
        if(@cp >= $K) {
            $data{$file} = \@cp;
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
&data_build;

