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
	my $rm_lst="$search_dir/.rm.$seconds.lst";
	system("tcsh -f -c '(find -L \"".var_escape_for_shell($search_dir, $FALSE)."\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/.(oggconvert|tcsh\-script\.template|tcsh\-template|perl\-script\.template|perl\-template|filelist|filenames|alacast|my\.feed|gPodder|New|rm|argument|escaped).*\" > \"$rm_lst\" ) >& /dev/null;'");
	my @files=`cat "$rm_lst"`;
	if( @files > 0 ) {
		system("tcsh -f -c 'rm -v \"`cat \"$rm_lst\"`\";'");
	}
	
	if( -e "$rm_lst" ) {
		my $rm_command="tcsh -f -c 'rm -v \"".var_escape_for_shell($rm_lst, $FALSE)."\";'";
		printf("Running:\n\t%s\n", $rm_command);
		system($rm_command);
	}

