#!/usr/bin/perl -w
use Configer;

my %config = Configer::init;
my $prefix = Configer::get('prefix');

print "generate intraday data file...\n";
`perl download_intraday_data_goog.pl`;
## gen_intraday_matrix.
print "run gen_intraday_matrix...\n";
`perl gen_intraday_matrix.pl`;

## gen_window_data.
print "run gen_window_data...\n";
`perl gen_window_data.pl`;


print "clean previous data...\n";
`perl clean.pl`;


print "run market_cap_process.pl...\n";
`perl market_cap_process.pl`;

print "run gen_complete_date_list.pl...\n";
`perl gen_complete_date_list.pl`;

print "run gen_range_interpolate_data.pl...\n";
`perl gen_range_interpolate_data.pl`;

print "run gen_day_matrix.pl...\n";
`perl gen_day_matrix.pl`;

print "run gen_window_data.pl...\n";
`perl gen_window_data.pl`;

print "run leader_rank.R...\n";
for my $file (sort `ls ../data/$prefix*.data`) {
	chomp($file);

	print STDERR "start $file...\n";
	$file =~ s{\.data$}{}isg;
#
	`Rscript leader_rank.R ../data/$file`;
}

print "run gen_leader_sector...\n";
# Generate leaders by sector.
`perl gen_leader_sector.pl`;

print "run gen_company_evolute...\n";
# Generate company's evolute data.
`perl gen_company_evolute.pl`;

print "run gen_company_mean_rank...\n";
# Generate company's mean rank and mean score data.
`perl gen_company_mean_rank.pl`;
