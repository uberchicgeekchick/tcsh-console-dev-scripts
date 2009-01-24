#!/usr/bin/perl
use strict;
my $total=2;
if($ARGV[0]>0){$total=$ARGV[0];}
print("Sending Interupt signal to gPodder's PIDs\n");
foreach(`pidof -x gpodder`){
	$_=~s/[\r\n]+//;
	print("Interupting $_ ");
	for(my $i=0; $i<$total; $i++){
		`kill -INT $_`;
		sleep(4);
		print(".");
	}
	print(" [done]\n");
}
