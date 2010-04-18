#!/usr/bin/perl -w
use strict;
my $TRUE=1;
my $FALSE=0;

sub var_escape_for_shell{
	my $value=shift;
	my $for_regexp=shift;
	
	$value=~s/([\$])/\\$1/g;
	$value=~s/([\"])/$1\\$1$1/g;
	#$value=~s/([*])/\\$1/g;
	#$value=~s/([\!])/\\$1/g;
	
	if($for_regexp){ $value=~s/([\[\/])/\\$1/g;  }
	
	return $value;
}#var_escape_for_shell($value);

sub parse_arg{
	my $argv=shift;
	my $dashes=$argv;
	my $option=$argv;
	my $equals=$argv;
	my $quotes=$argv;
	my $value=$argv;
	my $args_used=1;
	$dashes=~s/^([\-]{1,2})([^\=]+)([\=]?)(['"]?)(.*)(['"]?)$/$1/g;
	if("$dashes" eq "$argv"){ $dashes=""; }
	
	$option=~s/^([\-]{1,2})([^\=]+)([\=]?)(['"]?)(.*)(['"]?)$/$2/g;
	if("$option" eq "$argv"){ $option=""; }
	
	$equals=~s/^([\-]{1,2})([^\=]+)([\=]?)(['"]?)(.*)(['"]?)$/$3/g;
	if("$equals" eq "$argv"){ $equals=""; }
	
	$quotes=~s/^([\-]{1,2})([^\=]+)([\=]?)(['"]?)(.*)(['"]?)$/$4/g;
	if("$quotes" eq "$argv"){ $quotes=""; }
	
	$value=~s/^([\-]{1,2})([^\=]+)([\=]?)(['"]?)(.*)(['"]?)$/$5/g;
	if("$value" eq "$argv"){ $value=""; }
	if("$option" ne "" && "$equals" eq "" && "$value" eq ""){ $args_used++; $value=shift; }
	
	if( -e "$value" ){
		my $cmd;
		my $cmd_output;
		
		$cmd="/bin/grep \"".var_escape_for_shell($value, $TRUE)."\" /media/library/playlists/m3u/local.podcasts.m3u";
		$cmd_output=`$cmd`;
		chomp($cmd_output);
		if( "$cmd_output" ne "" ){ printf("%s output:\n\t%s\n", $cmd, $cmd_output); }
		
		$cmd="/bin/ls -l \"".var_escape_for_shell($value, $FALSE)."\" /media/library/playlists/m3u/local.podcasts.m3u";
		$cmd_output=`$cmd`;
		chomp($cmd_output);
		if( "$cmd_output" ne "" ){ printf("%s output:\n\t%s\n", $cmd, $cmd_output); }
	}
	return $args_used;
}#parse_arg($ARGV[0], $ARGV[1]);

sub parse_argv{
	for(my $i=0; $i<@ARGV; ){ $i+=parse_arg($ARGV[$i], ($i<@ARGV ?$ARGV[$i+1] :"")); }
}#parse_argv();

sub main{
	parse_argv();
}#main();

main();
