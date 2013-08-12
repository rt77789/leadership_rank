#!/usr/bin/perl -w

my $of = $ARGV[0];
die "please input a name of directory.\n" unless defined $of;
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
    'cevolute'
);

`mkdir ../data/$of` unless -d "../data/$of";

if(-d $of) {
    #print "mv ../data/*.$_ $of\n" for @suf;
    `mv ../data/*.$_ ../data/$of` for @suf;
}
