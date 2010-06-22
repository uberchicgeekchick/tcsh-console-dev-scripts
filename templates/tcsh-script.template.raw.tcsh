#!/bin/tcsh -f
setup:
	onintr exit_script;
	
	@ minimum_options=-1;
	@ maximum_options=-1;
	
	if(! -o /dev/$tty ) then
		set stdout=/dev/null;
		set stderr=/dev/null;
	else
		set stdout=/dev/stdout;
		set stderr=/dev/stdout;
	endif
	
	set starting_owd="${owd}";
	set starting_cwd="${cwd}";
	
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
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias ${download_command} "${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --continue --quiet --output-document";
	#alias ${download_command} "${download_command_with_options}";
	
	alias ex "ex -E -X -n --noplugin";
	
	set scripts_basename="tcsh-script.template.raw.tcsh";
	set scripts_alias="`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	
	goto init;
#goto setup;


debug_check:
	@ arg=0;
	@ argc=${#argv};
	
	while( $arg < $argc )
		@ arg++;
		
		set tmp_file="`mktemp --tmpdir -u "\""escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg.XXXXXXXX"\""`";
		printf "%s" "$argv[${arg}]" >! "${tmp_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${tmp_file}";
		set escaped_argument="`cat "\""${tmp_file}"\""`";
		rm -f "${tmp_file}";
		unset tmp_file;
		set argument="`printf "\""%s"\"" "\""${escaped_argument}"\""`";
		
		set option="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set value="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
		
		if( ${?debug} || ${?debug_arguments} ) \
			printf "**%s debug_check:**"\$"option: [${option}]; "\$"value: [${value}].\n" "${scripts_basename}" > ${stdout};
		
		switch("${option}")
			case "nodeps":
				if( ${?nodeps} ) \
					breaksw;
				set nodeps;
				breaksw;
			
			case "diagnosis":
			case "diagnostic-mode":
				if( ${?diagnosis} ) \
					continue;
				
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode:\t[enabled].\n\n" "${scripts_basename}" ${arg} > ${stdout};
				set diagnosis;
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "debug":
				switch("${value}")
					case "logged":
						if( ${?debug_logged} ) \
							continue;
						set debug_logged;
						breaksw;
					
					case "dependencies":
						if( ${?debug_dependencies} ) \
							continue;
						set debug_dependencies;
						breaksw;
					
					case "arguments":
						if( ${?debug_arguments} ) \
							continue;
						set debug_arguments;
						breaksw;
					
					case "stdin":
						if( ${?debug_stdin} ) \
							continue;
						set debug_stdin;
						breaksw;
					
					case "filenames":
						if( ${?debug_filenames} ) \
							continue;
						set debug_filenames;
						breaksw;
					
					default:
						if( ${?debug} ) \
							continue;
						set debug;
						breaksw;
				endsw
			default:
				continue;
		endsw
		
		printf "**%s notice:**, via "\$"argv[%d], %s mode" "${scripts_basename}" ${arg} "${option}" > ${stdout};
		if( "${value}" != "" ) \
			printf " %s" "${value}" > ${stdout};
		
		if( "${option}" == "debug" ) \
			printf " debugging" > ${stdout};
		
		printf ":\t[enabled].\n\n" > ${stdout};
	end
	
	set callback="dependencies_check";
	goto callback_handler;
#set callback="debug_check";


init:
	set dependencies=("${scripts_basename}" "find" "sed" "ex");# "${scripts_alias}");
	@ dependencies_index=0;
	
dependencies_check:
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		
		if( ${?nodeps} && $dependencies_index > 1 ) \
			goto finalize;
		
		set dependency=$dependencies[$dependencies_index];
		if( ${?debug} ) \
			printf "\n**%s debug:** looking for dependency: %s.\n\n" "${scripts_basename}" "${dependency}" > ${stdout};
			
		foreach program("`where "\""${dependency}"\""`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			printf "One or more of [%s] dependencies couldn't be found.\n\t%s requires: [%s] and [%s] couldn't be found." "${scripts_basename}" "${dependencies}" "${scripts_basename}" "${dependency}" > ${stderr};
			goto exit_script;
		endif
		
		if( ${?debug} ) then
			printf "**%s debug:** dependency: %s ( binary: %s )\t[found]\n" "${scripts_basename}" "${dependency}" "${program}" > ${stdout};
			unset suffix;
		endif
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?script} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname "\""${program}"\""`";
				set scripts_dirname="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_dirname}/${scripts_basename}";
				breaksw;
			
			default:
				if(! ${?execs} ) \
					set execs=()
				set execs=(${execs} "${program}");
				breaksw;
		endsw
		unset program;
	end
#goto dependencies_check;
	goto finalize;
#goto init:

finalize:
	if( ${?debug_set} ) \
		unset debug;
	
	unset dependency dependencies dependencies_index;
	
	goto main;
#goto finalize;


exit_script:
	onintr scripts_main_quit;
	goto scripts_main_quit;
#goto exit_script;

scripts_main_quit:
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


main:
	if(! ${?0} ) \
		goto sourced;
	
	goto exec;
#goto main;


sourced:
	# START: special handler for when this file is sourced.
	if( ${?debug} ) \
		printf "Setting up [%s]'s aliases so [%s]; executes: <file://%s>.\n" "${scripts_alias}" "${script}";
	
	alias "${scripts_alias}" "${script}";
	# FINISH: special handler for when this file is sourced.
	
	goto scripts_main_quit;
#goto sourced;

parse_argv_init:
	if( ${#argv} == 0 ) \
		goto usage;
	
	@ argc=${#argv};
	@ arg=0;
	if( ${?debug} ) \
		printf "**debug:** parsing "\$"argv's %d options.\n" "${scripts_basename}" "${argc}";
	
	goto parse_arg;
#goto parse_argv_init;

parse_arg:
	while ( $arg < $argc )
		if(! ${?arg_shifted} ) \
			@ arg++;
		
		set tmp_file="`mktemp --tmpdir -u "\""escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg.XXXXXXXX"\""`";
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
				
				set tmp_file="`mktemp --tmpdir -u "\""escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg.XXXXXXXX"\""`";
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
					printf "\t\tparsed argument for possible replacement value:\n\t\t\t"\$"test_argument: [%s]; "\$"argv[%d] (%s)\n\t\t\t"\$"test_dashes: [%s];\n\t\t\t"\$"test_option: [%s];\n\t\t\t"\$"test_equals: [%s];\n\t\t\t"\$"test_value: [%s]\n\n" "${test_argument}" "${arg}" "$argv[${arg}]" "${test_dashes}" "${test_option}" "${test_equals}" "${test_value}" > ${stdout};
				if(!( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "${test_argument}" )) then
					@ arg--;
				else
					set equals=" ";
					set value="${test_value}";
					set arg_shifted;
				endif
				unset escaped_test_argument test_argument test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( "${value}" != "" ) then
			set tmp_file="`mktemp --tmpdir -u "\""escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg.XXXXXXXX"\""`";
			printf "%s" "${value}" >! "${tmp_file}";
			ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${tmp_file}";
			set escaped_value="`cat "\""${tmp_file}"\""`";
			rm -f "${tmp_file}";
			unset tmp_file;
			set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
		endif
		
		if( "${option}" == "${value}" ) \
			set option="";
		
		if( ${?debug} || ${?diagnostic_mode} ) \
			printf "\t**debug:** parsing "\$"argv[%d] (%s).\n" $arg "$argv[$arg]";
		
		if( ${?debug} || ${?diagnostic_mode} ) \
			printf "\t**debug:** parsed "\$"argv[%d]: %s%s%s%s\n" $arg "${dashes}" "${option}" "${equals}" "${value}";
		
		switch ( "${option}" )
			case "h":
			case "help":
				goto usage;
				breaksw;
			
			case "diagnosis":
			case "diagnostic-mode":
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				breaksw;
			
			case "debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set debug;
				breaksw;
			
			case "":
				breaksw;
			
			default:
				breaksw;
		endsw
	end
#goto parse_arg;


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


