#!/usr/bin/perl -w
use Configer;

my %date;
my %config = Configer::init;
#my $common_stamp = 'common_stamp';
#my $hist_price = 'n15intraday';
#my $max_day = 391;
#my $step_day = 1;
#my $company_list = 'sp100.list';
#
sub gen_common_data {

    for my $file (`ls ../resource/$config{'hist_price'}`) {
        chomp($file);
        open HP, "<../resource/$config{'hist_price'}/$file" or die "open ../resource/$config{'hist_price'}/$file failed...";
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
    open COM, ">../resource/$config{'common_stamp'}.info" or die "open ../resource/$config{'common_stamp'}.info failed..\n";
    print COM "$_, $md\n" for reverse sort @resd;
    close COM;
}

sub data_build {
    ### read common date.
    my %com_date = Configer::load_common_stamp;
    my $cn = 0;

        #### 
    my %data;
    for my $file (`ls ../resource/$config{'hist_price'}`) {
        chomp($file);
        open HP, "<../resource/$config{'hist_price'}/$file" or die "open ../resource/$config{'hist_price'}/$file failed...";
        my @cp;
        <HP>;
        while(<HP>) {
            chomp;
            my @tk = split /,/;
            last unless defined $com_date{$tk[0]};

            print STDERR "$tk[0], $tk[4], $file\n";

            push @cp, $tk[4];
            last if @cp == $config{'window_size'};
        }
        close HP;
        
        if(@cp >= $config{'window_size'}) {
            $data{$file} = \@cp;
        }
        else {
            print STDERR $#cp+1, ", $config{'window_size'}, $file\n";
        }
    }

    ### Print the data.
    print "$_ " for sort keys %data;
    print "\n";
    for my $i (0..($config{'window_size'}-1)) {
        print "$data{$_}->[$config{'window_size'}-1-$i] " for sort keys %data;
        print "\n";
    }
}

sub sp500_build_multi {
### read common date.
	my %stamp = Configer::load_common_stamp;
	my @stamp = sort keys %stamp;
	#Configer::disp_array(\@stamp);

	for(my $i = 0; $i + $config{'window_size'} - 1 < $config{'max_day'}; $i += $config{'step_day'}) {
	# we only select the last K days' values.
		my %com_date;
		for my $j ($i..($i+$config{'window_size'}-1)) {
			$com_date{$stamp[$j]} = 1;
		}
		&sp500_build_single(\%com_date, "../data/sp500_128_$stamp[$i]_$stamp[$i+$config{'window_size'}-1].data");
	}
}

sub sp500_build_single {

    my %com_date = %{$_[0]};
	my $of = $_[1];
	my $K = keys %com_date;

	open OF, ">$of" or die "open $of failed...\n";
    
	### Read sp 500 company list.
    my %sp500 = Configer::load_company_list;
    my %data;

    for my $file (`ls ../resource/$config{'hist_price'}`) {
        chomp($file);
		my $dn = $file;
		$dn =~ s{\..*?$}{}is;
        ## only select sp500 companies.
        next unless defined $sp500{$dn};

        open HP, "<../resource/$config{'hist_price'}/$file" or die "open ../resource/$config{'hist_price'}/$file failed...";
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
	#print OF "$_ " for sort keys %data;
	for my $k (sort keys %data) {
		$k =~ s{\..*?$}{}isg;
		print OF "$k ";
	}
    print OF "\n";
    for my $i (0..($K-1)) {
		#print OF "$data{$_}->[$K-1-$i] " for sort keys %data;
		# ascent order.
        print OF "$data{$_}->[$i] " for sort keys %data;
        print OF "\n";
    }
	close OF;
}

sub gen_window_data {
	for my $file(`ls ../data/*.raw`) {
		chomp $file;
		#print "$file\n";

		open IN, "<$file" or die "open $file failed...\n";
		my $cname = <IN>;
		$cname =~ s{\s+$}{}isg;
		my @cname = split /\s+/, $cname;
		my @window_data;
		my @stamps;

		while(<IN>) {
			chomp;
			s{\s+$}{}isg;
			my @v = split /\s+/;
			push @stamps, shift @v;
			push @window_data, \@v;
		}
		close IN;

		for(my $i = $config{'window_size'}-1; $i < @window_data; $i += $config{'step_day'}) {
			my $from = ($i-$config{'window_size'}+1);
			my $to = $i;
			open OUT, ">../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].data" or die "open ../data/$config{'file_prefix'}$stamps[$from]_$stamps[$to].data failed...\n";	
			print OUT (join(' ', @cname), "\n");
			print OUT (join(' ', @{$_}), "\n")  for @window_data[$from..$to];
			close OUT;
		}
	}
}

#&gen_common_data;
#&data_build;
#&sp500_build_multi;
&gen_window_data;
