#!/bin/tcsh -f
setup:
	if(! ${?0} ) then
		printf "This script cannot be sourced.";
		exit -1;
	endif
	
	@ arg=0;
	@ argc=${#argv};
#goto setup;


parse_argv:
	while( $arg < $argc )
		@ arg++;
		switch( "$argv[$arg]" )
			case "--help":
				goto usage;
				breaksw;
			
			case "--debug":
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "--no-debug":
				if( ${?debug} ) \
					unset debug;
				breaksw;
			
			case "--restricted":
			case "--only-missing":
			case "--none-unset-vars-only":
			case "--unset-missing-only":
				if(! ${?show_unset_for_all_vars} ) \
					set show_unset_for_all_vars;
				breaksw;
			
			case "--all":
			case "--all-vars":
			case "--unset-all":
				if(! ${?show_unset_for_all_vars} ) \
					set show_unset_for_all_vars;
				breaksw;
			
			default:
				if(! -e "$argv[$arg]" ) then
					@ errno=-1;
					goto usage;
				else
					set tcsh_script="$argv[$arg]";
					goto check_vars;
				endif
				breaksw;
		endsw
	end
	goto exit_script;
#goto parse_argv;


check_vars:
	foreach var(`grep -P '[ \t](set|\@|setenv)([ \t][a-zA-Z][a-zA-Z0-9_]+)[\+\-\=\;\ ]' "${tcsh_script}" | sed -r 's/[ \t]*(set|\@|setenv)[ \t]([a-zA-Z][a-zA-Z0-9_]+)[\+\-\=\;\ ].*$/\2/'`)
		if( ${?show_unset_for_all_vars} || "`grep -P 'unset.*[ \t]+$var' "\""${tcsh_script}"\""`" == "" ) \
			printf "\tif( "\$"{?%s} ) \\\n\t\tunset %s;\n" "${var}" "${var}";
		unset var;
	end
	
	foreach var(`grep -P '^(set|\@|setenv)([ \t][a-zA-Z][a-zA-Z0-9_]+)[\+\-\=\;\ ]' "${tcsh_script}" | sed -r 's/[ \t]*(set|\@|setenv)[ \t]([a-zA-Z][a-zA-Z0-9_]+)[\+\-\=\;\ ].*$/\2/'`)
		if( ${?show_unset_for_all_vars} || "`grep -P 'unset.*[ \t]+$var' "\""${tcsh_script}"\""`" == "" ) \
			printf "\tif( "\$"{?%s} ) \\\n\t\tunset %s;\n" "${var}" "${var}";
		unset var;
	end
	unset tcsh_script;
	goto parse_argv;
#goto check_vars;


exit_script:
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;

usage:
	printf "Usage: "\`"%s [script.tcsh]'\n\n\tFinds all variable set within "\`"script.tcsh"\`" and displays any needed unset checks.\n" > ${stdout};
	goto exit_script;
#goto usage;

