#!/usr/bin/perl -w

use LWP;

sub download {
	my $ag = LWP::UserAgent->new();

	my $url = 'http://finance.yahoo.com/q/ks?s=';
	open IN, "<../data/sp_500.list" or die "open ../data/sp_500.list failed...\n";
	#for my $file(`ls ../data/hist_price/`) {
	my $num = 0;
	while(my $file = <IN>) {
		chomp($file);
		$file =~ s{\.raw$}{}isg;
		$file =~ s{\.}{-}isg;

		my $res = $ag->get($url.$file);
		print STDERR "$file failed...\n" unless $res->is_success;
		
		#### Extract market cap info.	
		my $page = $res->content;
		$page =~ s{\n\r}{}isg;
		#print $page;
		if($page =~ m{<td class="yfnc_tablehead1".*?<td class="yfnc_tabledata1".*?<span[^>]*?>(.+?)</span>}is) {
			print "$file, $1\n";
		}
		else {
			if($page =~ m{<td class="yfnc_tablehead1".*?<td class="yfnc_tabledata1".*?>(.+?)</td>}is) {
				print "$file, $1\n";
			}
			else {
				print STDERR "$file parse failed...\n"
			}
		}
		print STDERR "$num/500\n";
		$num++;
	}
	close IN;
}
&download;
