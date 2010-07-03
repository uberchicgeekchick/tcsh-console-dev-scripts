#!/bin/tcsh -f
setup:
	onintr exit_script;
	
	if(! -o /dev/$tty ) then
		set stdout=/dev/null;
		set stderr=/dev/null;
	else
		set stdout=/dev/stdout;
		set stderr=/dev/stderr;
	endif
	
	if(! ${?0} ) then
		@ errno=-1;
		goto exception_handler;
	endif
	
	goto main;
#goto setup;


exit_script:
	if(! ${?errno} ) \
		@ errno=0;
	
	if( ${?stdout} ) \
		unset stdout;
	if( ${?stderr} ) \
		unset stderr;
	
	set status=$errno;
	exit $errno;
#goto exit_script;


main:
	printf "Hello World\!\n";
	goto exit_script;
#goto main;


exception_handler:
	if(! ${?errno} ) \
		goto exit;
	
	if( `printf "%s" "$errno" | sed -r 's/^[0-9]+$/\1/'` != "" ) \
		@ errno=-999;
	
	printf "**%s error:** "\$"errno:%d:**\n\t" "${scripts_basename}" ${errno} > ${stderr};
	switch( $errno )
		case -1:
			printf "This script cannot be sourced." > ${stderr};
			breaksw;
		
		case -999:
			printf "An unknown error has occured." > ${stderr};
			breaksw;
	endsw
	
	goto exit_script;
#goto exception_handler;
