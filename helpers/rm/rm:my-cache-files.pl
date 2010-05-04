#!/usr/bin/perl
use strict;
	my $search_dir;
	if(!( "$ARGV[0]" ne "" && -d "$ARGV[0]" )) {
		$search_dir=`pwd`;
		chomp($search_dir);
	}else{
		$search_dir="$ARGV[0]";
	}
	
	my $seconds=`date '+%s'`;
	chomp($seconds);
	my $rm_list="$search_dir/.rm.$seconds.lst";
	system("find -L '$search_dir' -ignore_readdir_race -regextype posix-extended -iregex '.*\/.(oggconvert|tcsh\-template|perl\-template|filelist|alacast|my\.feed|gPodder|New|rm).*' > '$rm_list' 2> /dev/null");
	my @files=`cat "$rm_list"`;
	if( @files > 0 ) {
		system("rm -v `cat '$rm_list'`");
	}
	
	if( -e "$rm_list" ) {
		`rm '$rm_list'`;
	}

