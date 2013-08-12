#!/usr/bin/perl -w

my %sector;
my %industry;
my $page;

sub read_list {
	open SEC, "<../resource/sp500.sector" or die "open ../resource/sp500.sector failed...\n";
	open IND, "<../resource/sp500.industry" or die "open ../resource/sp500.industry failed...\n";
	while(<SEC>) {
		chomp;
		m{^"(.*?)","(.*?)"$}is;
		$sector{$1} = $2;
	}
	while(<IND>) {
		chomp;
		m{^"(.*?)","(.*?)"$}is;
		$industry{$1} = $2;
	}
	close IND;
	close SEC;
}

sub main {

	&read_list;

	open P, "<../resource/sp100.page" or die "open ../resource/sp100.page failed...\n";
	open COM, ">../resource/sp100.list" or die "open ../resource/sp100.list failed...\n";
open IND, ">../resource/sp100.industry" or die "open ../resource/sp100.industry failed...\n";
open SEC, ">../resource/sp100.sector" or die "open ../resource/sp100.sector...\n";



	while(<P>) {
		chomp;
		$page .= $_;
	}
	close P;

#print $page, "\n";

	while($page =~ s{\|\s*(\S+)\s*\|\s*\[\[(.*?)\]\]\|}{}is) {
		my $com = $1;
		#print "$1, $2\n";
		print COM "$com\n";
		print SEC "\"$com\",\"$sector{$com}\"\n";
		print IND "\"$com\",\"$industry{$com}\"\n";
	}

#my @tk = split /\|/, $page;
#print $_, "\n" for @tk;
	close COM;
	close SEC;
	close IND;
	close P;
}

&main;
