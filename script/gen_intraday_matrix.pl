#!/usr/bin/perl -w
use Configer;

my %config = Configer::init;

sub gen_inraday_matrix {

	my %comps = Configer::load_company_list;
	my %stamp = Configer::load_common_stamp;
	my %data;
	my %resd;

	#Configer::disp_hash(\%comps);

	for my $file (`ls ../resource/$config{'hist_price'}`) {
		chomp($file);
		my $dn = $file;
		$dn =~ s{\.[^.]+?$}{}is;
		## only select companies in company list file.
		print "$dn\n" unless defined $comps{$dn};

		next unless defined $comps{$dn};

		open HP, "<../resource/$config{'hist_price'}/$file" or die "open ../resource/$config{'hist_price'}/$file failed...";
		my @cp;
		<HP>;
		$file =~ s{\..*?$}{}isg;
		while(<HP>) {
			chomp;
			my @tk = split /,/;
			#print STDERR "$tk[0], $tk[4], $file\n";
			$data{$tk[0]}->{$file} = $tk[4];
		}
		close HP;
		
		### filer or fill the data, first prev is the mean value.
		my $prev = 0;
		my $pnum = 0;

		for (keys %data) {
			if(defined $data{$_}->{$file}) {
				$pnum++, $prev += $data{$_}->{$file} 
			}
		}

		$prev /= $pnum;

		for my $st (sort keys %stamp) {
			$data{$st}->{$file} = $prev unless(defined $data{$st}->{$file});
			$prev = $data{$st}->{$file};
		}

		### Non filter data are used.
		if($pnum == $config{'max_day'}) {
			for my $st (sort keys %data) {
				$resd{$st}->{$file} = $data{$st}->{$file};
			}
		}
	}


	### Print out.
	my @stamp = sort keys %resd;
	my $from = $stamp[0];
	my $to = $stamp[-1];

	die "\@stamp != \$config{'max_day'}" if @stamp != $config{'max_day'};

	open OF, ">../data/$config{'file_prefix'}${from}_$to.raw" or die "open ../data/$config{'file_prefix'}${from}_$to.raw failed...\n";
	for my $k (sort keys %resd) {
		print OF "\"$_\" " for (sort keys %{$resd{$k}});
		last;
	}
    print OF "\n";
	for my $k (sort keys %resd) {
		print OF "$k";
		print OF " \"$resd{$k}->{$_}\"" for (sort keys %{$resd{$k}});
		print OF "\n";
	}
	close OF;
}

#Configer::disp_hash(\%config);
&gen_inraday_matrix;
