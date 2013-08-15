#!/usr/bin/perl -w

my $of = $ARGV[0];
die "please input a name of directory.\n" unless defined $of;
$of = "../data/$of";
my @suf = (
    'data',
    'mat',
    'rank',
    'crank',
    'log',
    'mrank',
    'mcrank',
    'mscore',
    'mcscore',
    'msector',
    'mindustry',
    'evolute',
    'cevolute',
	'raw'
);

`mkdir $of` unless -d $of;

if(-d $of) {
    #print "mv ../data/*.$_ $of\n" for @suf;
    `mv ../data/*.$_ $of` for @suf;
}
