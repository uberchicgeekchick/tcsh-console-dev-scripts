#!/usr/bin/perl
use strict;
my $total=2;
if($ARGV[0]>0){$total=$ARGV[0];}
print("Sending Interupt signal to gPodder's PIDs");
foreach(`pidof -x gpodder`){
	print("Interupting $_");
	for(my $i=0; $i<$total; $i++){
		print(".");
		`kill -INT $_`;
		sleep(2);
	}
	print("\n");
}
