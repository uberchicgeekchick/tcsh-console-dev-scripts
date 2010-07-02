#!/usr/bin/perl -w
use strict;

if(!( $ARGV[0] && "$ARGV[0]" ne "" ) ){
	printf( "Usage:\n\t%s\n", $ARGV[0] );
	exit( -1 );
}

my $template="`dirname $0`/gobject";

my $object=lc($ARGV[0]);
my $struct=ucfirst($object);
my $type=uc($object);

`cp "$template.c" "$object.c"`;
`ex '+1,\$s/This_Object/$struct/g' '+1,\$s/THIS_OBJECT/$type/g' '+1,\$s/ThisObject/$struct/g' '+1,\$s/this/$object/g' '+wq' '$object.c'`;

`cp "$template.c" "$object.h"`;
`ex '+1,\$s/This_Object/$struct/g' '+1,\$s/THIS_OBJECT/$type/g' '+1,\$s/ThisObject/$struct/g' '+1,\$s/this/$object/g' '+wq' '$object.h'`;

