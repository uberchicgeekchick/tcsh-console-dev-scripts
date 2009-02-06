#!/usr/bin/perl -w
use strict;
my $total=9;
my $timeout=48;# How long to wait between sending each interupt signal.

sub parse_argument{
	my $argument=$_;
	$argument=~s/\-\-([^=]+)?=(.*)$/$1/;
	
	my $value=$_;
	$value=~s/\-\-([^=]+)?=(.*)$/$2/;

	if( "$argument" eq "" || $value < 1){return;}
	
	if("$argument" eq "send-interupt"){
		$total=$value;
	} elsif("$argument" eq "timeout"){
		$timeout=$value;
	}
}#parse_argument

sub parse_arguments{
	foreach(@ARGV){parse_argument($_);}
}#parse_argument

sub still_running{
	my $pid=$_;
	foreach(`pidof -x gpodder`){
		if( (chomp($_))==$pid ){return 0;}
	}
	return 1;
}#still_running

sub interupt_pid{
	my $pid=$_;
	printf("Interupting %s ", $pid);
	for(my $i=0; $i<$total; $i++){
		if ($i){sleep($timeout);}
		`kill -INT $pid`;
		printf(".");
		if(!(still_running($pid))){$i=$total;}
	}#for($i<$total)
	printf(" [done]\n");
}#interupt_pid

sub interupt_gpodder{
	printf("Sending gPodder's PIDs the interupt signal.\nI'll be sending %s interupts and waiting %s seconds each time:\n", $total, $timeout);
	foreach(`pidof -x gpodder`){
		interupt_pid((chomp($_)));
	}
}#interupt_gpodder

parse_arguments();
interupt_gpodder();

