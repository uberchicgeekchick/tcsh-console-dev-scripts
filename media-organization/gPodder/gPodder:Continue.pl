#!/usr/bin/perl
use strict;
my $total=2;
my $wait=10;# How long to wait between sending each interupt signal.

sub parse_arguments{
	for( my $i=0; $i<@ARGV; $i++ ){
		my $argument=$ARGV[$i];
		$argument=~s/\-\-([^=]+)?=(.*)$/$1/;
		my $value=$ARGV[$i];
		$value=~s/\-\-([^=]+)?=(.*)$/$2/;

		if( "$argument" eq "" || $value < 1 ){ next; }

		if( "$argument" eq "send-interupt" ){
			$total=$value;
		} elsif( "$argument" eq "wait" ){
			$wait=$value;
		}
	}
}#parse_arguments

parse_arguments();

printf( "Sending gPodder's PIDs the interupt signal.\nI'll be sending %s interupts and waiting %s seconds each time:\n", $total, $wait );
foreach my $pid(`pidof -x gpodder`){
	chomp($pid);
	printf( "Interupting %s ", $pid );
	my $still_running=1;
	for(my $i=0; $i<$total && $still_running==1; $i++){
		if ( $i ) { sleep($wait); }
		`kill -INT $pid`;
		printf(".");
		$still_running=0;
		foreach my $test_pid(`pidof -x gpodder`){
			chomp($test_pid);
			if($test_pid == $pid){ $still_running=1; }
		}
	}#for($i++)
	printf(" [done]\n");
}
