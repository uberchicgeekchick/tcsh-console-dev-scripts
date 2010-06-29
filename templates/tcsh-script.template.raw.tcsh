#!/bin/tcsh -f
setup:
	onintr exit_script;
	
	@ minimum_options=-1;
	@ maximum_options=-1;
	# optional
	set supports_being_sourced;
	
	if(! -o /dev/$tty ) then
		set stdout=/dev/null;
		set stderr=/dev/null;
	else
		set stdout=/dev/stdout;
		set stderr=/dev/stderr;
	endif
	
	if( "`alias cwdcmd`" != "" ) then
		set original_cwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	if( ${?GREP_OPTIONS} ) then
		set grep_options="${GREP_OPTIONS}";
		unsetenv GREP_OPTIONS;
	endif
	
	if( "`alias grep`" != "" ) then
		set original_grep="`alias grep`";
		unalias grep;
	endif
	
	set starting_owd="${owd}";
	set starting_cwd="${cwd}";
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias ${download_command} "${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --continue --quiet --output-document";
	#alias ${download_command} "${download_command_with_options}";
	
	alias ex "ex -E -X -n --noplugin";
	
	set scripts_basename="tcsh-script.template.raw.tcsh";
	set scripts_alias="`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	set usage_message="Usage: ${scripts_basename} [-h|--help]...\n\tA template for basic tcsh shell scripts.\n\t\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.";
	
	goto debug_check_init;
#goto setup;


debug_check_init:
	if( ${#argv} < 0 ) then
		@ errno=-503;
		goto exception_handler;
	endif
	
	@ argc=${#argv};
	@ arg=0;
	if( ${?debug} ) \
		printf "**debug:** parsing "\$"argv's %d options.\n" "${scripts_basename}" "${argc}";
	
	set arg_handler="check_mode";
	set arg_parse_complete="debug_check_quit";
	
	goto parse_argv;
#goto debug_check_init;


debug_check_quit:
	if( ${?arg_handler} ) \
		unset arg_handler;
	if( ${?arg_parse_complete} ) \
		unset arg_parse_complete;
	
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if( ${?arg} ) then
		if( $arg >= $argc ) \
			set argv_parsed;
		unset arg;
	endif
	
	goto main;
#goto debug_check_quit;


check_mode:
	switch("${option}")
		case "nodeps":
			if( ${?nodeps} ) \
				continue;
		
			set nodeps;
			breaksw;
		
		case "diagnosis":
		case "diagnostic-mode":
			if( ${?diagnosis} && ${?debug} ) \
				continue;
			
			set diagnosis;
			if(! ${?debug} ) \
				set debug;
			breaksw;
		
		case "debug":
			if( ${?debug} ) \
				continue;
			
			set debug;
			breaksw;
		
		default:
			continue;
			breaksw;
		endsw
	endsw
	
	printf "**%s notice:**, via "\$"argv[%d], %s:\t[enabled]\n" "${scripts_basename}" $arg "${option}" > ${stdout};
	
	goto parse_argv;
#goto check_mode;


dependencies_check:
	set dependencies=("${scripts_basename}" "find" "sed" "ex");# "${scripts_alias}");
	@ dependencies_index=0;
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		
		if( ${?nodeps} && $dependencies_index > 1 ) \
			break;
		
		set dependency=$dependencies[$dependencies_index];
		
		switch( `printf "%d" "${dependencies_index}" | sed -r 's/^.*([0-9])$/\1/'`)
			case 1:
				set suffix="st";
				breaksw;
			case 2:
				set suffix="nd";
				breaksw;
			case 3:
				set suffix="rd";
				breaksw;
			default:
				set suffix="th";
				breaksw;
		endsw
		
		if( ${?debug} ) \
			printf "\n**dependencies:** looking for <%s>'s %d%s dependency: %s.\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" > ${stdout};
			
		foreach program("`where "\""${dependency}"\""`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			@ errno=-501;
			goto exception_handler;
		endif
		
		if( ${?debug} ) \
			printf "**dependencies:** <%s>'s %d%s dependency: %s ( binary: %s )\t[found]\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${program}" > ${stdout};
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?script} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname "\""${program}"\""`";
				set scripts_path="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_path}/${scripts_basename}";
				breaksw;
			
			default:
				if(! ${?execs} ) \
					set execs=()
				set execs=(${execs} "${program}");
				breaksw;
		endsw
		unset program dependency;
	end
	
	if( ${?debug_set} ) \
		unset debug;
	
	unset dependencies dependencies_index;
	
	goto parse_argv;
#goto dependencies_check;


exit_script:
	onintr exit_script;
	goto scripts_main_quit;
#goto exit_script;


scripts_main_quit:
	onintr exit_script;
	if( ${?starting_cwd} ) then
		if( "${starting_cwd}" != "${cwd}" ) \
			cd "${starting_cwd}";
		unset starting_cwd;
	endif
	
	if( ${?starting_owd} ) then
		if( "${starting_owd}" != "${owd}" ) \
			set owd="${starting_owd}";
		unset starting_owd;
	endif
	
	if( ${?original_cwdcmd} ) then
		alias cwdcmd "${original_cwdcmd}";
		unset original_cwdcmd;
	endif
	
	if( ${?grep_options} ) then
		setenv GREP_OPTIONS "${grep_options}";
		unset grep_options;
	endif
	
	if( ${?original_grep} ) then
		alias grep "${original_grep}";
		unset original_grep;
	endif
	
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $status;
#goto scripts_main_quit;


sourced:
	if(! ${?supports_being_sourced} ) then
		@ errno=-502;
		goto exception_handler;
	endif
	
	# START: special handler for when this file is sourced.
	if( -d "${scripts_path}/../tcshrc" && -f "${scripts_path}/../tcshrc/argv:check" ) \
		source "${scripts_path}/argv:check" "${scripts_basename}" ${argv};
	
	if( ${?debug} ) \
		printf "Setting up [%s]'s aliases so [%s]; executes: <file://%s>.\n" "${scripts_alias}" "${script}";
	
	alias "${scripts_alias}" "${script}";
	
	if( -d "${scripts_path}/../tcshrc" && -f "${scripts_path}/../tcshrc/argv:clean-up" ) \
		source "${scripts_path}/argv:clean-up" "${scripts_basename}";
	# FINISH: special handler for when this file is sourced.
	goto exit_script;
#goto sourced;


main:
	if(! ${?0} ) \
		goto sourced;
	
	goto exec;
#goto main;


exec:
	printf "Hello World\!";
	goto exit_script;
#goto exec;


parse_argv_init:
	if( ${#argv} == 0 ) \
		goto usage;
	
	@ argc=${#argv};
	@ arg=0;
	if( ${?debug} ) \
		printf "**debug:** parsing "\$"argv's %d options.\n" "${scripts_basename}" "${argc}";
	
	set arg_handler="check_argv";
	set arg_parse_complete="parse_argv_quit";
	
	goto parse_argv;
#goto parse_argv_init;


parse_argv_quit:
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if( ${?arg} ) then
		if( $arg >= $argc ) \
			set argv_parsed;
		unset arg;
	endif
	
	goto main;
#goto parse_argv_quit;


parse_argv:
	while ( $arg < $argc )
		if(! ${?arg_shifted} ) then
			@ arg++;
		else
			unset arg_shifted;
		endif
		
		if( ${?debug} ) \
			printf "\t**debug:** parsing "\$"argv[%d] (%s).\n" $arg "$argv[$arg]";
		
		goto parse_arg;
	end
	goto $arg_parse_complete;
#goto parse_argv;


parse_arg:
	set tmp_file="`mktemp --tmpdir -u "\"".escaped.argument.${scripts_basename}.argv[${arg}].XXXXXXXX"\""`";
	printf "%s" "$argv[${arg}]" >! "${tmp_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${tmp_file}";
	set escaped_argument="`cat "\""${tmp_file}"\""`";
	rm -f "${tmp_file}";
	unset tmp_file;
	set argument="`printf "\""%s"\"" "\""${escaped_argument}"\""`";
	
	set dashes="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
	if( "${dashes}" == "${argument}" ) \
		set dashes="";
	
	set option="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
	if( "${option}" == "${argument}" ) \
		set option="";
	
	set equals="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
	if( "${equals}" == "${argument}" ) \
		set equals="";
	
	set value="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
	
	if( ${?debug} ) \
		printf "\tparsed "\$"argument: [%s]; "\$"argv[%d] (%s)\n\t\t"\$"dashes: [%s];\n\t\t"\$"option: [%s];\n\t\t"\$"equals: [%s];\n\t\t"\$"value: [%s]\n\n" "${argument}" "${arg}" "$argv[${arg}]" "${dashes}" "${option}" "${equals}" "${value}" > ${stdout};
	
	if(!( "${dashes}" != "" && "${option}" != "" && "${equals}" != "" && "${value}" != "" )) then
		@ arg++;
		if( ${arg} > ${argc} ) then
			@ arg--;
		else
			if( ${?debug} ) \
				printf "**%s debug:** Looking for replacement value.  Checking argv #%d (%s).\n" "${scripts_basename}" ${arg} "$argv[${arg}]" > ${stdout};
			
			set tmp_file="`mktemp --tmpdir -u "\"".escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg.XXXXXXXX"\""`";
			printf "%s" "$argv[${arg}]" >! "${tmp_file}";
			ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${tmp_file}";
			set escaped_test_argument="`cat "\""${tmp_file}"\""`";
			rm -f "${tmp_file}";
			unset tmp_file;
			set test_argument="`printf "\""%s"\"" "\""${escaped_test_argument}"\""`";
			
			set test_dashes="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
			if( "${test_dashes}" == "${test_argument}" ) \
				set test_dashes="";
			
			set test_option="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
			if( "${test_option}" == "${test_argument}" ) \
				set test_option="";
			
			set test_equals="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
			if( "${test_equals}" == "${test_argument}" ) \
				set test_equals="";
			
			set test_value="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
			
			if( ${?debug} ) \
				printf "\n\t\tparsed argument for possible replacement value:\n\t\t\t"\$"test_argument: [%s]; "\$"argv[%d] (%s)\n\t\t\t"\$"test_dashes: [%s];\n\t\t\t"\$"test_option: [%s];\n\t\t\t"\$"test_equals: [%s];\n\t\t\t"\$"test_value: [%s]\n\n" "${test_argument}" "${arg}" "$argv[${arg}]" "${test_dashes}" "${test_option}" "${test_equals}" "${test_value}" > ${stdout};
			
			if(!( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "${test_argument}" )) then
				@ arg--;
			else
				set equals=" ";
				set value="${test_value}";
				set escaped_value="${escaped_test_argument}";
				set arg_shifted;
			endif
			unset escaped_test_argument test_argument test_dashes test_option test_equals test_value;
		endif
	endif
	
	if( "${value}" != "" && ! ${?escaped_value} ) then
		set tmp_file="`mktemp --tmpdir -u "\"".escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg.XXXXXXXX"\""`";
		printf "%s" "${value}" >! "${tmp_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${tmp_file}";
		set escaped_value="`cat "\""${tmp_file}"\""`";
		rm -f "${tmp_file}";
		unset tmp_file;
	endif
	
	if( "${option}" == "${value}" ) \
		set option="";
	
	if( ${?debug} ) \
		printf "\t**debug:** parsed "\$"argv[%d]: %s%s%s%s\n" $arg "${dashes}" "${option}" "${equals}" "${value}";
	
	goto $arg_handler;
#goto parse_arg;


check_arg:
	switch ( "${option}" )
		case "h":
		case "help":
			if(! ${?exit_on_usage} ) \
				set exit_on_usage;
			goto usage;
			breaksw;
		
		case "diagnosis":
		case "diagnostic-mode":
			printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
			set diagnostic_mode;
			set debug;
			breaksw;
		
		case "debug":
			printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
			set debug;
			breaksw;
		
		case "":
		default:
			@ errno=-505;
			set callback="parse_argv";
			goto exception_handler;
			breaksw;
	endsw
	unset argument dashes option equals value escaped_value;
	goto parse_argv;
#goto check_arg;


usage:
	if( ${?script} && ${?program} ) then
		if( "${program}" != "${script}" && -x ${?program} ) then
			${program} --help;
			set usage_displayed;
		endif
	endif
	
	if(! ${?usage_displayed} ) then
		printf "\n";
		if(! ${?usage_message} ) then
			printf "Usage:\t%s [-h|--help]...\n\t[-h|--help]\tDisplays this screen." "${scripts_basename}";
		else
			printf "${usage_message}";
		endif
		printf "\n\n";
		set usage_displayed;
	endif
	
	if( ${?exit_on_usage} || ! ${?callback} ) \
		set callback="exit_script";
	
	goto callback_handler;
#set callback="$!";
#goto usage;


exception_handler:
	if(! ${?errno} ) \
		@ errno=-999;
	
	if( $errno <= -500 ) then
		if(! ${?exit_on_exception} ) \
			set exit_on_exception;
	else if( $errno < -400 ) then
		if(! ${?exit_on_exception} ) \
			set exit_on_exception;
	else if( $errno > -400 && $errno < -100 ) then
		if( ${?exit_on_exception} ) then
			set exit_on_exception_unset;
			unset exit_on_exception;
		endif
	endif
	
	printf "\n" > ${stderr};
	if( $errno > -400 ) \
		printf "\t" > ${stderr};
	printf "**%s error("\$"errno:%d):**\n\t" "${scripts_basename}" ${errno} > ${stderr};
	switch( $errno )
		case -501:
			printf "<%s>'s %d%s dependency: <%s> couldn't be found.\n\t%s requires: [%s]." "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${scripts_basename}" "${dependencies}" > ${stderr};
			unset suffix dependency dependencies dependencies_index;
			breaksw;
		
		case -502:
			printf "Sourcing is not supported. %s may only be executed." "${scripts_basename}" > ${stderr};
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided." > ${stderr};
			breaksw;
		
		case -504:
			printf "To many options have been provided." > ${stderr};
			breaksw;
		
		case -505:
			printf "%s%s%s%s is an unsupported option." "${dashes}" "${option}" "${equals}" "${value}" > ${stderr};
			unset dashes option equals value;
			breaksw;
		
		case -604:
			printf "%sing %s is not supported." "`printf "\""%s"\"" "\""${option}"\"" | sed -r 's/^(.*)e"\$"/\1/`" "${value}" "${scripts_basename}" > ${stderr};
			breaksw;
		
		case -999:
		default:
			printf "An internal script error has occured." > ${stderr}
			breaksw;
	endsw
	printf "\n\n";
	@ last_exception_handled=$errno;
	printf "\tPlease see: "\`"${scripts_basename} --help"\`" for more information and supported options.\n" > ${stderr}
	if(! ${?debug} ) \
		printf "\tOr run: "\`"${scripts_basename} --debug"\`" to diagnose where ${scripts_basename} failed.\n" > ${stderr}
	printf "\n" > ${stderr}
	
	if( ! ${?callback} || ${?exit_on_exception} ) \
		set callback="exit_script";
	
	if( ${?exit_on_exception_unset} ) then
		unset exit_on_exception_unset;
		set exit_on_exception;
	endif
	
	goto callback_handler;
#@ errno=-101;
#set callback="$!";
#goto exception_handler;


