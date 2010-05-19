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
	
	my $rm_lst=`mktemp --tmpdir .rm.my-cache-files.lst.XXXXXX`;
	chomp($rm_lst);
	system("tcsh -f -c '(find -L \"".var_escape_for_shell($search_dir, $FALSE)."\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/tmpdir\.for\..*\" -type -d | sed -r \'\\\'\'s/(.*)/if(\ \-d \"\\1\"\ ) rm \-rv\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
	system("tcsh -f -c '(find -L \"".var_escape_for_shell($search_dir, $FALSE)."\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/.(oggconvert|tcsh\-script\.template|tcsh\-template|perl\-script\.template|perl\-template|filelist|filenames|alacast|my\.feed|gPodder|New|rm|argument|escaped).*\" | sed -r \'\\\'\'s/(.*)/\\tif(\ \-e \"\\1\"\ ) rm \-v\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
	
	if( -d "/tmp" ){
		system("tcsh -f -c '(find -L \"/tmp\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/tmpdir\.for\..*\" -type d | sed -r \'\\\'\'s/(.*)/if(\ \-d \"\\1\"\ ) rm \-rv\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
		system("tcsh -f -c '(find -L \"/tmp\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/.(oggconvert|tcsh\-script\.template|tcsh\-template|perl\-script\.template|perl\-template|filelist|filenames|alacast|my\.feed|gPodder|New|rm|argument|escaped).*\" | sed -r \'\\\'\'s/(.*)/\\tif(\ \-e \"\\1\"\ ) rm \-v\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
	}
	
	if( -d "$ENV{HOME}/tmp" ){
		system("tcsh -f -c '(find -L \"$ENV{HOME}/tmp\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/tmpdir\.for\..*\" -type d | sed -r \'\\\'\'s/(.*)/if(\ \-d \"\\1\"\ ) rm \-rv\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
		system("tcsh -f -c '(find -L \"$ENV{HOME}/tmp\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/.(oggconvert|tcsh\-script\.template|tcsh\-template|perl\-script\.template|perl\-template|filelist|filenames|alacast|my\.feed|gPodder|New|rm|argument|escaped).*\" | sed -r \'\\\'\'s/(.*)/\\tif(\ \-e \"\\1\"\ ) rm \-v\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
	}
	
	if( "$ENV{TMPDIR}"ne"" && "$ENV{TMPDIR}"ne"/tmp" && "$ENV{TMPDIR}"ne"$ENV{HOME}/tmp" && -d "$ENV{TMPDIR}" ){
		system("tcsh -f -c '(find -L \"$ENV{TMPDIR}\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/tmpdir\.for\..*\" -type d | sed -r \'\\\'\'s/(.*)/if(\ \-d \"\\1\"\ ) rm \-rv\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
		system("tcsh -f -c '(find -L \"$ENV{TMPDIR}\" -ignore_readdir_race -regextype posix-extended -iregex \".*\/.(oggconvert|tcsh\-script\.template|tcsh\-template|perl\-script\.template|perl\-template|filelist|filenames|alacast|my\.feed|gPodder|New|rm|argument|escaped).*\" | sed -r \'\\\'\'s/(.*)/\\tif(\ \-e \"\\1\"\ ) rm \-v\ \"\\1\";/\'\\\'\' >> \"$rm_lst\" ) >& /dev/null;'");
	}
	
	my @files=`cat "$rm_lst"`;
	if( @files > 0 ) {
		my $tcsh_script="$rm_lst.tcsh";
		open(tcsh_script, ">", "$tcsh_script");
		open(rm_lst, "<", "$rm_lst");
		print tcsh_script "#!/bin/tcsh -f\n";
		while(my $line = <rm_lst>){
			print tcsh_script "$line";
		}
		print tcsh_script "rm -v $tcsh_script\n";
		close(rm_lst);
		close(tcsh_script);
		chmod(0777, $tcsh_script);
		system("tcsh -f -c '$ENV{EDITOR} $tcsh_script;'");
		system("tcsh -f -c '$tcsh_script;'");
	}
	
	if( -e "$rm_lst" ) {
		my $rm_command="tcsh -f -c 'rm -v \"".var_escape_for_shell($rm_lst, $FALSE)."\";'";
		printf("Running:\n\t%s\n", $rm_command);
		system($rm_command);
	}

