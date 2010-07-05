#!/bin/tcsh -f
setup:
	onintr scripts_deinit;
	set scripts_basename="set-alias";
#goto setup;


parse_argv:
	@ argc=${#argv};
	@ required_options=2;
	
	if( ${argc} < ${required_options} ) then
		if( ${?TCSH_OUTPUT_ENABLED} ) \
			printf "Missing alias or command.\n" > /dev/stderr;
		
		@ errno=-504;
		goto exit_script;
	endif
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set debug;
				break;
			
			default:
				continue;
		endsw
	end
#goto parse_argv;


prep_exec:
	if( ${?this_program} ) \
		unset this_program;
	if( ${?program} ) \
		unset program;
	
	set this_program="`printf "\""%s"\"" "\""${2}"\"" | sed -r 's/^([^\ ]+) (.*)/\1/'`";
	set arguments="`printf "\""%s"\"" "\""${2}"\"" | sed -r 's/^([^\ ]+) (.*)/\2/'`";
	
	if( "`alias "\""${1}"\""`" != "" ) \
		unalias "${1}";
	
	if( -x "${this_program}" ) then
		set program="${this_program}";
	else
		foreach program( "`where "\""${this_program}"\""`" )
			if( -x "${program}" ) \
				break;
			unset program;
		end
	endif
	
	if(! ${?program} ) \
		goto no_exec;
#goto prep_exec;


set_alias:
	if( ${?debug} ) \
		printf "Seting alias for: <%s> to <%s %s>.\n\t"\$"program: [%s]; "\$"this_program: [%s]; "\$"arguments: [%s].\n" "${1}" "${this_program}" "${arguments}" "${this_program}" "${program}" "${arguments}" > ${stdout};
	
	alias "${1}" "${this_program} ${arguments}";
	
	if( ${?debug} ) \
		alias "${1}";
	
	goto exit_script;
#goto set_alias;


exit_script:
	if(! ${?scripts_deinit} ) then
		goto scripts_deinit;
	else
		unset scripts_deinit;
	endif
	
	if(! ${?errno} ) \
		exit 0;
	unset errno;
	exit -1;
#exit_script:

no_exec:
	printf "**%s error:** alias creation failed! [%s] binary could not be found.\n" "${scripts_basename}" "${this_program}" > ${stderr};
	@ errno=-1;
	goto exit_script;
no_exec:


scripts_deinit:
	unset scripts_basename arg argc;
	if( ${?this_program} ) \
		unset this_program;
	if( ${?program} ) \
		unset program;
	if( ${?debug} ) \
		unset debug;
	if( ${?required_options} ) \
		unset required_options;
	if( ${?arguments} ) \
		unset arguments;
	set scripts_deinit;
	goto exit_script;
#goto scripts_deinit;

