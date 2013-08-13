#!/usr/bin/perl -w

my %date;

sub gen_common_data {

    for my $file (`ls ../resource/hist_price`) {
        chomp($file);
        open HP, "<../resource/hist_price/$file" or die "open ../resource/hist_price/$file failed...";
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
    open COM, ">../resource/common_date.info" or die "open ../resource/common_date.info failed..\n";
    print COM "$_, $md\n" for reverse sort @resd;
    close COM;
}

sub data_build {
    ### read common date.
    open COM, "<../resource/common_date.info" or die "open ../resource/common_date.info failed...\n";
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
    for my $file (`ls ../resource/hist_price`) {
        chomp($file);
        open HP, "<../resource/hist_price/$file" or die "open ../resource/hist_price/$file failed...";
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

sub sp500_build_multi {
### read common date.
    open COM, "<../resource/common_date.info" or die "open ../resource/common_date.info failed...\n";
    my $K = 128;
	while(<COM>) {
		chomp;
		push @stamp, $_;
	}
    close COM;

    #for(my $i = 0; $i+$K-1 < 200; $i += 1) {
	for(my $i = 0; $i < 500; $i += 128) {
	# we only select the last K days' values.
		my %com_date;
		for my $j ($i..($i+$K-1)) {
			$com_date{$stamp[$j]} = 1;
		}
		&sp500_build_single(\%com_date, "../data/sp500_128_$stamp[$i]_$stamp[$i+$K-1].data");
	}
}

sub sp500_build_single {

    my %com_date = %{$_[0]};
	my $of = $_[1];
	my $K = keys %com_date;

	open OF, ">$of" or die "open $of failed...\n";
    
	### Read sp 500 company list.
    my %sp500;
    open LIST, "<../resource/sp500.list" or die "open ../resource/sp500.list failed...\n";
    while(<LIST>) {
        chomp;
        $sp500{"$_.raw"} = 1;
    }
    close LIST;

    #### 
    my %data;
    for my $file (`ls ../resource/hist_price`) {
        chomp($file);
        ## only select sp500 companies.
        next unless defined $sp500{$file};

        open HP, "<../resource/hist_price/$file" or die "open ../resource/hist_price/$file failed...";
        my @cp;
        <HP>;
        while(<HP>) {
            chomp;
            my @tk = split /,/;
            next unless defined $com_date{$tk[0]};

			#print STDERR "$tk[0], $tk[4], $file\n";

            push @cp, $tk[4];
            last if @cp == $K;
        }
        close HP;
        
        if(@cp >= $K) {
			$file =~ s{\.raw$}{}isg;
            $data{$file} = \@cp;
        }
        else {
            print STDERR $#cp+1, ", $K, $file\n";
        }
    }

    ### Print the data.
    print OF "$_ " for sort keys %data;
    print OF "\n";
    for my $i (0..($K-1)) {
        print OF "$data{$_}->[$K-1-$i] " for sort keys %data;
        print OF "\n";
    }
	close OF;
}
sub sp100_build_multi {
### read common date.
    open COM, "<../resource/common_date.info" or die "open ../resource/common_date.info failed...\n";
    my $K = 128;
	while(<COM>) {
		chomp;
		push @stamp, $_;
	}
    close COM;

    #for(my $i = 0; $i+$K-1 < 200; $i += 1) {
	for(my $i = 0; $i < 4400; $i += 64) {
	# we only select the last K days' values.
		my %com_date;
		for my $j ($i..($i+$K-1)) {
			$com_date{$stamp[$j]} = 1;
		}
		&sp100_build_single(\%com_date, "../data/sp100_128_$stamp[$i]_$stamp[$i+$K-1].data");
	}
}

sub sp100_build_single {

    my %com_date = %{$_[0]};
	my $of = $_[1];
	my $K = keys %com_date;

	open OF, ">$of" or die "open $of failed...\n";
    
	### Read sp 100 company list.
    my %sp100;
    open LIST, "<../resource/sp100.list" or die "open ../resource/sp100.list failed...\n";
    while(<LIST>) {
        chomp;
        $sp100{"$_.raw"} = 1;
    }
    close LIST;

    #### 
    my %data;
    for my $file (`ls ../resource/hist_price`) {
        chomp($file);
        ## only select sp100 companies.
        next unless defined $sp100{$file};

        open HP, "<../resource/hist_price/$file" or die "open ../resource/hist_price/$file failed...";
        my @cp;
        <HP>;
        while(<HP>) {
            chomp;
            my @tk = split /,/;
            next unless defined $com_date{$tk[0]};

			#print STDERR "$tk[0], $tk[4], $file\n";

            push @cp, $tk[4];
            last if @cp == $K;
        }
        close HP;
        
        if(@cp >= $K) {
			$file =~ s{\.raw$}{}isg;
            $data{$file} = \@cp;
        }
        else {
            print STDERR $#cp+1, ", $K, $file\n";
        }
    }

    ### Print the data.
    print OF "$_ " for sort keys %data;
    print OF "\n";
    for my $i (0..($K-1)) {
        print OF "$data{$_}->[$K-1-$i] " for sort keys %data;
        print OF "\n";
    }
	close OF;
}


#&gen_common_data;
#&data_build;
#&sp500_build_multi;
&sp100_build_multi;

