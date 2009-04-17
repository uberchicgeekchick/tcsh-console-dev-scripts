#!/usr/bin/perl -w
use strict;

sub parse_arg{
}#parse_arg

sub parse_argv{
	for ( my $i=0; $i<@ARGV; $i++ ) { parse_arg($ARGV[$i]); }
}#parse_argv
