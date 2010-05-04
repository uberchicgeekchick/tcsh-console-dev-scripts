#!/usr/bin/perl -w
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

sub parse_arg{
	my $argv=shift;
	my $dashes=$argv;
	my $option=$argv;
	my $equals=$argv;
	my $value=$argv;
	my $args_used=1;
	$dashes=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$1/g;
	if("$dashes" eq "$argv"){ $dashes=""; }
	
	$option=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$2/g;
	if("$option" eq "$argv"){ $option=""; }
	
	$equals=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$3/g;
	if("$equals" eq "$argv"){ $equals=""; }
	
	$value=~s/^([\-]{1,2})([^\=]+)([\=]?)(.*)$/$4/g;
	
	if("$option" ne "" && "$equals" eq "" && "$value" eq ""){ $args_used++; $value=shift; }
	
	if( -e "$value" ){
		my $cmd;
		my @cmd_output;
		
		$cmd="/bin/grep \"".var_escape_for_shell($value, $TRUE)."\" /media/library/playlists/m3u/local.podcasts.m3u";
		@cmd_output=`$cmd`;
		if( @cmd_output > 0 ){
			printf("\n%s output:", $cmd);
			for( my $i=0; $i<@cmd_output; $i++) {
				chomp($cmd_output[$i]);
				if( "$cmd_output[$i]" ne "" ){
					printf("\n\t%s\n", $cmd_output[$i]);
				}
			}
		}
		
		$cmd="/bin/ls -l \"".var_escape_for_shell($value, $FALSE)."\"";
		@cmd_output=`$cmd`;
		if( @cmd_output > 0 ){
			printf("\n%s output:", $cmd);
			for( my $i=0; $i<@cmd_output; $i++) {
				chomp($cmd_output[$i]);
				if( "$cmd_output[$i]" ne "" ){
					printf("\n\t%s", $cmd_output[$i]);
				}
			}
		}
		printf("\n\n");
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
