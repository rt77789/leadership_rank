#!/usr/bin/perl -w

for my $file (sort `ls ../data/sp*.data`) {
	chomp($file);

	print STDERR "start $file...\n";
	$file =~ s{\.data$}{}isg;
#
	`Rscript leader_rank.R ../data/$file`;
}
# Generate leaders by sector.
`perl gen_leader_sector.pl`;
# Generate company's evolute data.
`perl gen_company_evolute.pl`;
# Generate company's mean rank and mean score data.
`perl gen_company_mean_rank.pl`;
