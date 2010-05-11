#!/usr/bin/perl -w
use strict;
#use lib "$scripts_dir/my_perl_lib";

my $TRUE=1;
my $FALSE=0;

my $scripts_dir;
my $scripts_basename;

my %debug=();
my @files=();


sub script_init {
	my $starting_dir=`pwd`;
	chomp($starting_dir);
	$scripts_dir=$0;
	$scripts_dir=~s/^(.*)\/([^\/]+)$/$1/;
	chdir($scripts_dir);
	$scripts_dir=`pwd`;
	chomp($scripts_dir);
	chdir($starting_dir);
	undef $starting_dir;
	$scripts_basename=$0;
	$scripts_basename=~s/^(.*)\/([^\/]+)$/$2/;
	if( $debug{'all'} ) {
		printf("\$script: %s/%s\n", $scripts_dir, $scripts_basename);
	}
}#script_init();#


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


sub debug_check {
	for(my $i=0; $i<@ARGV; $i++){
		my $option=$ARGV[$i];
		$option=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$2/g;
		if("$option" eq "$ARGV[$i]"){ $option=""; }
		my $value=$ARGV[$i];
		$value=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$4/g;
		if( "$option" ne "debug" ) { next; }
		
		if(
			"$value" ne "arguments"
			&&
			"$value" ne "files"
			&&
			"$value" ne "logging"
		) { next; }
		
		printf("**%s notice** via \$ARGV[%d] debugging %s\t[enabled]\n", $scripts_basename, $i, $value);
		$debug{$value}=$TRUE;
	}
}#debug_check();#


sub parse_arg{
	my $i=shift;
	my $argv=shift;
	my $dashes=$argv;
	my $option=$argv;
	my $equals=$argv;
	my $value=$argv;
	
	$dashes=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$1/g;
	if("$dashes" eq "$argv"){ $dashes=""; }
	
	$option=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$2/g;
	if("$option" eq "$argv"){ $option=""; }
	
	$equals=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$3/g;
	if("$equals" eq "$argv"){ $equals=""; }
	
	$value=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$4/g;
	
	if("$dashes" ne "" && "$option" ne "" && "$equals" eq "" && "$value" eq ""){ $value=shift; }
	
	if($debug{'arguments'}){
		printf("parsed \$ARGV[%d]: \$dashes: [%s]; \$option: [%s]; \$equals: [%s]; \$value: [%s].\n", $i, $dashes, $option, $equals, $value);
	}
	
	if( -e "$value" ){
		append_files($value);
	}
}#parse_arg($ARGV[0], $ARGV[1]);


sub append_files {
	my $value=shift;
	my $scripts_supported_extensions="";
	my $tmp_file=`mktemp --tmpdir filename.from.$scripts_basename.arguments.XXXXXX`;
	chomp($tmp_file);
	if( $debug{'files'} ){ printf("looking for %s files to add to \$files found in: [%s]\n", $scripts_supported_extensions, $value); }
	system("find -L \"".var_escape_for_shell($value, $FALSE)."\" -ignore_readdir_race -regextype posix-extended -iregex '.*\.$scripts_supported_extensions\$' > '$tmp_file' 2> /dev/null");
	my @files_found=`cat "$tmp_file"`;
	if( @files_found <= 0 ) {
		if( -e "$tmp_file" ) { system("rm '$tmp_file'"); }
		return;
	}
	for(my $i=0; $i<@files_found; $i++){
		my $file_found=$FALSE;
		$value=$files_found[$i];
		chomp($value);
		for(my $x=0; $x<@files && !$file_found; $x++){
			if( $debug{'files'} ){ printf("comparing \$files[%d], [%s], against [%s]\n", $x, $files[$x], $value); }
			if( "$files[$x]" eq "$value" ){ $file_found=$TRUE; }
		}
		
		if(!$file_found){
			$files[@files]=$value;
		}
	}
	
	if( -e "$tmp_file" ) {
		system("rm '$tmp_file'");
	}
}#append_files($value);#


sub process_files {
	if(!@files) { return $FALSE; }
	my $x=0;
	for( my $i=0; $i<@files; $i++ ) {
		if( $debug{'files'} ){ printf("processing \$files[%d]: [%s]\n", $i, $files[$i]); }
		if(! -e "$files[$i]" ) {
			printf("**%s error** %s can no longer be found.\n", $scripts_basename, $files[$i]);
			next;
		}
		
		$x++;
		process_file( $files[$i] );
	}
	if(!$x) {
		return $FALSE;
	}
	return $TRUE;
}#process_files();#


sub process_file {
	my $file=shift;
	if( $debug{'files'} ){ printf("processing file: [%s]\n", $file); }
	display_command_output("/bin/grep \"".var_escape_for_shell($file, $TRUE)."\" /media/library/playlists/m3u/local.podcasts.m3u");
	display_command_output("/bin/ls -l \"".var_escape_for_shell($file, $FALSE)."\"");
	printf("\n\n");
}#process_file();#


sub display_command_output {
	my $cmd=shift;
	my @cmd_output=`$cmd`;
	
	if(!@cmd_output){ return $FALSE; }
	
	my $x=0;
	printf("\n%s output:", $cmd);
	for( my $i=0; $i<@cmd_output; $i++) {
		chomp($cmd_output[$i]);
		if( "$cmd_output[$i]" ne "" ){
			printf("\n\t%s", $cmd_output[$i]);
			$x++;
		}
	}
	if(!$x) { return $FALSE; }
	
	return $TRUE;
}#display_command_output("command");#


sub parse_argv{
	for(my $i=0; $i<@ARGV; $i++){ parse_arg($i, $ARGV[$i], ($i<@ARGV ?$ARGV[$i+1] :"")); }
}#parse_argv();

sub main{
	debug_check();
	script_init();
	#use lib "$scripts_dir/my_perl_lib";
	parse_argv();
	if( @files ) { process_files(); }
	exit_script();
}#main();#


sub exit_script {
}#exit_script();#


# And here's where we actually get started.
main();
