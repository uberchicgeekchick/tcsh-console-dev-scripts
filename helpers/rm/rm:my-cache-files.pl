#!/usr/bin/perl
use strict;

my $TRUE=1;
my $FALSE=0;


sub var_escape_for_shell{
	my $value=shift;
	my $for_regexp=shift;
	
	$value=~s/([\$])/\\$1/g;
	$value=~s/([\"])/$1\\$1$1/g;
	$value=~s/([\`])/\\$1/g;
	#$value=~s/([*])/\\$1/g;
	#$value=~s/([\!])/\\$1/g;
	
	if($for_regexp){ $value=~s/([\[\/])/\\$1/g;  }
	
	return $value;
}#var_escape_for_shell($value);


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
	system("find -L \"".var_escape_for_shell($search_dir, $FALSE)."\" -ignore_readdir_race -regextype posix-extended -iregex '.*\/.(oggconvert|tcsh\-template|perl\-template|filelist|filenames|alacast|my\.feed|gPodder|New|rm).*' > '$rm_list' 2> /dev/null");
	my @files=`cat "$rm_list"`;
	if( @files > 0 ) {
		system("rm -v `cat '$rm_list'`");
	}
	
	if( -e "$rm_list" ) {
		`rm '$rm_list'`;
	}

