# 
package Configer;
use strict;
use warnings;
#use Sub::Exporter -setup => {
#    exports => [ qw/foo bar/ ],
#};

my %config = &init;

sub trim {
	my $res = $_[0];
	$res =~ s{^\s+}{}isg;
	$res =~ s{\s+$}{}isg;
	$res
}

sub init { 
	my $conf_dir = '../resource/config.file';
	open C, "<$conf_dir" or die "open $conf_dir...\n";
	while(<C>) {
		chomp;
		my @tk = split /,/;
		@tk = map { &trim($_) } @tk;
		$config{$tk[0]} = $tk[1];
	}
	close C;
	%config;
}

### Load company List file.
sub load_company_list {
	my %comps;
	open LIST, "<../resource/$config{'company_list'}" or die "open ../resource/$config{'company_list'} failed...\n";
	while(<LIST>) {
		chomp;
		$comps{"$_"} = 1;
	}
	close LIST;
	%comps;
}

####
sub load_common_stamp {
	my %stamp;
	open COM, "<../resource/$config{'common_stamp'}.info" or die "open ../resource/$config{'common_stamp'}.info failed...\n";
	while(<COM>) {
		chomp;
		$stamp{$_} = 1 if($_ <= $config{'end_stamp'} && $config{'start_stamp'} <= $_);

	}
    close COM;
	%stamp;
}

### 
sub disp_hash {
	my $h = $_[0];
	print "$_, $h->{$_}\n" for sort keys %{$h};
}

sub disp_array {
	my $h = $_[0];
	print "-$_-\n" for @{$h};

}
####

1;
