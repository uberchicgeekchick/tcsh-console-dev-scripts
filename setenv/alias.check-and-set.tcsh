#!/bin/tcsh -f
if(!( "${1}" != "" && "${2}" != "" )) then
	printf "Missing alias or command.\n" > /dev/null;
	set status=-1;
	exit ${status};
endif

set this_program="`printf '%s' '${2}' | sed -r 's/^([^\ ]+)\ .*/\1/'`";
if( -x "${this_program}" ) then
	set program="${this_program}";
else
	foreach program( "`where '${this_program}'`" )
		if( -x "${program}" ) break;
		unset program;
	end
endif

if(! ${?program} ) then
	printf "Unable to find %s executable.\n" "${this_program}" > /dev/null;
	set status=-1;
	exit ${status};
endif

alias "${1}" "${2}";

