#!/bin/tcsh -f
parse_argv:
	@ argc=${#argv};
	@ required_options=2;
	
	if( ${argc} < ${required_options} ) then
		if( ${?TCSH_OUTPUT_ENABLED} ) \
			printf "Missing alias or command.\n" > /dev/stderr;
		
		@ errno=-504;
		godo exit_script;
	endif
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${script_basename}" $arg;
				set debug;
				break;
			
			default:
				continue;
		endsw
	end
#parse_argv:

if( ${?this_program} ) \
	unset this_program;
if( ${?program} ) \
	unset program;

set this_program="`printf '%s' '${2}' | sed -r 's/^([^\ ]+)\ .*/\1/'`";

if( "`alias "\""${1}"\""`" != "" ) \
	unalias "${1}";

if( -x "${this_program}" ) then
	set program="${this_program}";
else
	foreach program( "`where '${this_program}'`" )
		if( -x "${program}" ) then
			break;
		endif
		unset program;
	end
endif

if(! ${?program} ) \
	goto no_exec;

	if( ${?debug} || ${?TCSH_RC_DEBUG} ) \
		printf "Seting alias for: <%s> to <%s>.\n\t"\$"this_program: %s; "\$"program: %s.\n" "${1}" "${2}" "${this_program}" "${program}" > /dev/stdout;
alias "${1}" "${2}";
goto exit_script;

exit_script:
	if( ${?this_program} ) \
		unset this_program;
	if( ${?program} ) \
		unset program;
	
	if(! ${?errno} ) \
		exit 0;
	unset errno;
	exit -1;
#exit_script:

no_exec:
	if( ${?TCSH_OUTPUT_ENABLED} ) \
		printf "**error: alias creation failed**: [%s] binary could not be found.\n" "${this_program}" > /dev/stderr;
	@ errno=-1;
	goto exit_script;
no_exec:

