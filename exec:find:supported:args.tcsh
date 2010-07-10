#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script does not support being sourced.\n";
	@ errno=-1;
	goto exit_script;
endif

if( ${#argv} != 1 ) \
	goto usage;

touch --help >! touch.help;
ex '+1,$s/\v[ \t](\-{1,2}[^,= \t]+)/\r\1\r/g' '+wq!' touch.help;
/bin/grep -P '^\-{1,2}.+$' touch.help | sort | uniq | sed -r 's/^\-{1,2}//';

exit_script:
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;

usage:
	goto exit_script;
#goto usage;
