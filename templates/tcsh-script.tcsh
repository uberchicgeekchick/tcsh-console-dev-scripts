#!/bin/tcsh -f
init:
	set current_label="init";
	set current_cwd="${cwd}";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if( `printf '%s' "${0}" | sed -r 's/^[^\.]*(csh)$/\1/'` == "csh" )	\
		set being_sourced;
	
	if(! ${?eol} ) then
		set eol='$';
		set eol_set;
	endif
	
	set scripts_basename="tcsh-script.tcsh";
	set scripts_alias="`printf '%s' '${scripts_basename}' | sed -r 's/(.*)\.(tcsh|cshrc)${eol}/\1/'`";
	
	set escaped_home_dir="`printf '%s' '${HOME}' | sed -r 's/\//\\\//g'`";
	
	@ errno=0;
	
	#set supports_being_source;
	#set argz="";
	
	goto parse_argv;
#init:

init_complete:
	set current_label="init_complete";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	set init_completed;
#init_complete:

check_dependencies:
	set current_label="check_dependencies";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	set dependencies=("${scripts_basename}");# "${scripts_alias}");
	@ dependencies_index=0;
#check_dependencies:


check_dependencies:
	set current_label="check_dependencies";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	foreach dependency(${dependencies})
		@ dependencies_index++;
		unset dependencies[$dependencies_index];
		foreach dependency("`where '${dependency}'`")
			if( ${?debug} )	\
				printf "\n**%s debug:** looking for dependency: %s.\n\n" "${scripts_basename}" "${dependency}"; 
			
			if(! -x "${dependency}" ) continue;
			
			if(! ${?scripts_dirname} ) then
				if("`basename '${dependency}'`" == "${scripts_basename}" ) then
					set old_owd="${cwd}";
					cd "`dirname '${dependency}'`";
					set scripts_dirname="${cwd}";
					cd "${owd}";
					set owd="${old_owd}";
					unset old_owd;
					set script="${scripts_dirname}/${scripts_basename}";
					if(! ${?TCSH_RC_SESSION_PATH} )	\
						setenv TCSH_RC_SESSION_PATH "${scripts_dirname}/../tcshrc";
					
					if(! ${?TCSH_LAUNCHER_PATH} )	\
						setenv TCSH_LAUNCHER_PATH \$"{TCSH_RC_SESSION_PATH}/../launchers";
				endif
			endif
			
			if( ${?debug} )	then
				switch( "`printf '%s' '${dependency}' | sed -r 's/.*([1-3])${eol}'/\1/`" )
					case "1":
						set suffix="st";
						breaksw;
					
					case "2":
						set suffix="nd";
						breaksw;
					
					case "3":
						set suffix="rd";
						breaksw;
					
					default:
						set suffix="th";
						breaksw;
				endsw
				
				printf "\n**%s debug:** found %d%s dependency: %s.\n\n" "${scripts_basename}" $dependencies_index "$suffix" "${dependency}";
				unset suffix;
			endif
			
			switch("${dependency}")
				case "${scripts_basename}":
				case "./${dependency}":
				case "${TCSH_LAUNCHER_PATH}/${dependency}":
					continue;
					breaksw;
			endsw
			break;
		end
		
		if(! ${?program} )	\
			set program="${script}";
		
		if(!( ${?dependency} && ${?script} && ${?program} )) then
			set missing_dependency;
		else
			if(!( -x ${script} && -x ${dependency} && -x ${program} ))	\
				set missing_dependency;
		endif
		
		if( ${?missing_dependency} ) then
			@ errno=-501;
			goto exception_handler;
		endif
		
		unset dependency;
	end
	
	unset dependency dependencies;
#check_dependencies:


if_sourced:
	set current_label="if_sourced";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if(! ${?being_sourced} )	\
		goto main;
	
	if(! ${?supports_being_source} )	\
		goto sourcing_disabled;
	
	goto sourcing_init;
#if_sourced:


sourcing_disabled:
	set current_label="sourcing_disabled";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	# BEGIN: disable source scripts_basename.  For exception handeling when this file is 'sourced'.
	@ errno=-502;
	goto exception_handler;
	# END: disable source scripts_basename.
#sourcing_disabled:


sourcing_init:
	set current_label="sourcing_init";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	# BEGIN: source scripts_basename support.
	source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
#sourcing_init:


sourcing_main:
	set current_label="sourcing_main";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	# START: special handler for when this file is sourced.
	alias ${scripts_alias} \$"{TCSH_LAUNCHER_PATH}/${scripts_basename}";
	# FINISH: special handler for when this file is sourced.
#sourcing_main:


sourcing_main_quit:
	set current_label="sourcing_main_quit";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
	
	# END: source scripts_basename support.
	
	goto scripts_main_quit;
#sourcing_main_quit:


main:
	set current_label="main";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	set argc=${#argv};
	if( ${argc} < 1 ) then
		@ errno=-503;
		goto exception_handler;
	endif
	
	alias	ex	"ex -E -n -X --noplugin";
#main:


exec:
	set current_label="exec";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if( ${?debug} )	\
		printf "Executing %s's main.\n" "${scripts_basename}";
	goto scripts_main_quit;
#exec:


scripts_main_quit:
	set current_label="scripts_main_quit";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if( ${?argc} )	\
		unset argc;
	
	if( ${?init_completed} )	\
		unset init_completed;
	
	if( ${?eol_set} )	\
		unset eol_set eol;
	if( ${?being_sourced} )	\
		unset being_sourced;
	if( ${?supports_being_source} )	\
		unset supports_being_source;
	
	if( ${?scripts_basename} )	\
		unset scripts_basename;
	if( ${?scripts_dirname} )	\
		unset scripts_dirname;
	if( ${?scripts_alias} )	\
		unset scripts_alias;
	if( ${?script} )	\
		unset script;
	
	if( ${?missing_dependency} )	\
		unset missing_dependency;
	
	if( ${?parsed_arg} )	\
		unset parsed_arg;
	if( ${?parsed_argv} )	\
		unset parsed_argv;
	if( ${?parsed_argc} )	\
		unset parsed_argc;
	if( ${?argz} )	\
		unset argz;
	
	if( ${?debug} )	\
		unset debug;
	if( ${?escaped_cwd} )	\
		unset escaped_cwd;
	if( ${?escaped_home_dir} )	\
		unset escaped_home_dir;
	if( ${?dependency} )	\
		unset dependency;
	if( ${?dependencies} )	\
		unset dependencies;
	if( ${?usage_displayed} )	\
		unset usage_displayed;
	if( ${?no_exit_on_usage} )	\
		unset no_exit_on_usage;
	if( ${?display_usage_on_error} )	\
		unset display_usage_on_error;
	if( ${?last_exception_handled} )	\
		unset last_exception_handled;
	
	if( ${?current_label} )	\
		unset current_label;
	if( ${?callback} )	\
		unset callback;
	if( ${?last_callback} )	\
		unset last_callback;
	if( ${?callback_stack} )	\
		unset callback_stack;
	
	if( ${?arg_shifted} ) 	\
		unset arg_shifted;
	
	if( ${?old_owd} ) then
		cd "${owd}";
		set owd="${old_owd}";
		unset old_owd;
	endif
	
	if(! ${?errno} ) then
		set status=0;
	else
		set status=$errno;
		unset errno;
	endif
	exit ${status}
#scripts_main_quit:


usage:
	set current_label="usage";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if( ${?errno} ) then
		if( ${errno} != 0 ) then
			if(! ${?last_exception_handled} )	\
				set last_exception_handled=0;
			if( ${last_exception_handled} != ${errno} ) then
				if(! ${?callback} )	\
					set callback="usage";
				goto exception_handler;
			endif
		endif
	endif
	
	if(! ${?script} ) then
		printf "Usage:\n\t%s [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n" "${scripts_basename}";
	else if( "${program}" != "${script}" ) then
		${program} --help;
	endif
	
	if(! ${?usage_displayed} )	\
		set usage_displayed;
	
	if(! ${?no_exit_on_usage} )	\
		goto scripts_main_quit;
	
	if(! ${?callback} )	\
		set callback="parse_arg";
	goto callback_handler;
#usage:


exception_handler:
	set current_label="exception_handler";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if(! ${?errno} )	\
		@ errno=-599;
	printf "\n**%s error("\$"errno:%d):**\n\t" "${scripts_basename}"  $errno;
	switch( $errno )
		case -500:
			printf "%s is being debugged.  Please see any output above.\n" "${scripts_basename}" > /dev/stderr;
			@ errno=0;
			breaksw;
		
		case -501:
			printf "One or more required dependencies couldn't be found.\n\t[%s] couldn't be found.\n\t%s requires: %s" "${dependency}" "${scripts_basename}" "${dependencies}";
			breaksw;
		
		case -502:
			printf "Sourcing is not supported and may only be executed" > /dev/stderr;
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided" "${dashes}" "${option}" '`' "${scripts_basename}" '`' > /dev/stderr;
			breaksw;
		
		case -504:
			printf "%s%s is an unsupported option.\n\tRun %s%s --help%s for supported options and details" "${dashes}" "${option}" '`' "${scripts_basename}" '`' > /dev/stderr;
			breaksw;
		
		case -599:
		default:
			printf "An unknown error "\$"errno: %s has occured" "${errno}" > /dev/stderr;
			breaksw;
	endsw
	set last_exception_handled=$errno;
	printf "\n\n" > /dev/stderr;
	
	if( ${?display_usage_on_error} )	\
		goto usage;
	
	if( ${?callback} )	\
		goto callback_handler;
	
	goto scripts_main_quit;
#exception_handler:



parse_argv:
	set current_label="parse_argv";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if( ${?init_completed} ) then
		if(! ${?being_sourced} ) then
			set callback="exec";
		else
			set callback="sourcing_main";
		endif
		goto callback_handler;
	endif
	
	@ argc=${#argv};
	
	if( ${argc} == 0 ) then
		if(! ${?being_sourced} ) then
			set callback="exec";
		else
			set callback="sourcing_main";
		endif
		goto callback_handler;
	endif
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--diagnosis":
			case "--diagnostic-mode":
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				break;
			
			case "--debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set debug;
				break;
			
			default:
				continue;
		endsw
	end
	
	if( ${?debug} || ${?diagnostic_mode} )	\
		printf "**%s debug:** checking argv.  %d total arguments.\n\n" "${scripts_basename}" "${argc}";
	
	@ arg=0;
	@ parsed_argc=0;
#parse_argv:

parse_arg:
	set current_label="parse_arg";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	while( $arg < $argc )
		if(! ${?arg_shifted} )	\
			@ arg++;
		
		if( ${?debug} || ${?diagnostic_mode} )		\
			printf "**%s debug:** Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\2/'`";
		if( "${option}" == "$argv[$arg]" ) set option="";
		
		set equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\3/'`";
		if( "${equals}" == "$argv[$arg]" || "${equals}" == "" ) set equals="";
		
		set equals="";
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\4/'`";
		if( "${value}" != "" && "${value}" != "$argv[$arg]" ) then
			set equals="=";
		else if( "${option}" != "" ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				set test_dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\1/'`";
				set test_option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\2/'`";
				set test_equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\3/'`";
				set test_value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?${eol}/\4/'`";
				
				if( ${?debug} || ${?diagnostic_mode} )	\
					printf "\tparsed %sargv[%d] (%s) to test for replacement value.\n\tparsed %stest_dashes: [%s]; %stest_option: [%s]; %stest_equals: [%s]; %stest_value: [%s]\n" \$ "${arg}" "$argv[$arg]" \$ "${test_dashes}" \$ "${test_option}" \$ "${test_equals}" \$ "${test_value}";
				
				if(!("${test_dashes}" == "$argv[$arg]" && "${test_option}" == "$argv[$arg]" && "${test_equals}" == "$argv[$arg]" && "${test_value}" == "$argv[$arg]")) then
					@ arg--;
				else
					set equals="=";
					set value="$argv[$arg]";
					set arg_shifted;
				endif
				unset test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( "`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/\1/"\""`" == "~" ) then
			set value="`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/${escaped_home_dir}\2/"\""`";
		endif
		
		if( "`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/\1/"\""`" == "." ) then
			set value="`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/${escaped_cwd}\2/"\""`";
		endif
		
		@ parsed_argc++;
		set parsed_arg="${dashes}${option}${equals}${value}";
		if(! ${?parsed_argv} ) then
			set parsed_argv="${parsed_arg}";
		else
			set parsed_argv="${parsed_argv} ${parsed_arg}";
		endif
		if( ${?debug} || ${?diagnostic_mode} )	\
			printf "\tparsed option %sparsed_argv[%d]: %s\n" \$ "$parsed_argc" "${dashes}${option}${equals}${value}";
		
		switch("${option}")
			case "numbered_option":
				if(! ( "${value}" != "" && ${value} > 0 )) then
					printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
					breaksw;
				endif
			
				set numbered_option="${value}";
				breaksw;
			
			case "h":
			case "help":
				goto usage;
				breaksw;
			
			case "verbose":
				if(! ${?be_verbose} ) set be_verbose;
				breaksw;
			
			case "debug":
				if(! ${?debug} ) set debug;
				breaksw;
			
			case "diagnosis":
			case "diagnostic-mode":
				if( ${?diagnostic_mode} )	\
					breaksw;
				
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				breaksw;
			
			case "enable":
				switch("${value}")
					case "verbose":
						if(! ${?be_verbose} )	\
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], verbose output\t[enabled].\n\n" "${scripts_basename}" $arg;
						set be_verbose;
						breaksw;
					
					case "debug":
						if( ${?debug} )	\
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
						set debug;
						breaksw;
					
					case "diagnosis":
					case "diagnostic-mode":
						if( ${?diagnostic_mode} )	\
							breaksw;
						
				
						printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
						set diagnostic_mode;
						breaksw;
					
					default:
						printf "enabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_basename}" "${scripts_basename}";
						breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch("${value}")
					case "verbose":
						if(! ${?be_verbose} )	\
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], verbose output\t[disabled].\n\n" "${scripts_basename}" $arg;
						unset be_verbose;
						breaksw;
					
					case "debug":
						if(! ${?debug} )	\
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], debug mode\t[disabled].\n\n" "${scripts_basename}" $arg;
						unset debug;
						breaksw;
					
					case "diagnosis":
					case "diagnostic-mode":
						if(! ${?diagnostic_mode} )	\
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[disabled].\n\n" "${scripts_basename}" $arg;
						unset diagnostic_mode;
						breaksw;
					
					default:
						printf "disabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_basename}" "${scripts_basename}";
						breaksw;
				endsw
				breaksw;
			
			default:
				if(! ${?argz} ) then
					@ errno=-504;
					set callback="parse_arg";
					goto exception_handler;
					breaksw;
				endif
				
				if( "${argz}" == "" ) then
					set argz="$parsed_arg";
				else
					set argz="${argz} $parsed_arg";
				endif
				breaksw;
		endsw
		
		if( ${?arg_shifted} ) then
			unset arg_shifted;
			@ arg--;
		endif
		
		unset dashes option equals value parsed_arg;
	end
	if(! ${?callback} ) then
		unset arg argc;
	else
		if( "${callback}" != "parse_arg" ) then
			unset arg;
		endif
	endif
	if( ${?diagnostic_mode} ) then
		set callback="diagnostic_mode";
	else
		if(! ${?callback} ) then
			if(! ${?init_completed} ) then
				set callback="init_complete";
			else if(! ${?being_sourced} ) then
				set callback="exec";
			else
				set callback="sourcing_main";
			endif
		endif
	endif
	
	goto callback_handler;
#parse_arg:

callback_handler:
	set current_label="callback_handler";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if(! ${?callback} )	\
		goto scripts_main_quit;
	
	if(! ${?callback_stack} ) then
		set callback_stack=("${callback}");
		set last_callback="$callback_stack[${#callback_stack}]";
	else
		if("${callback}" != "$callback_stack[${#callback_stack}]" ) then
			set callback_stack=($callback_stack "${callback}");
			set last_callback="$callback_stack[${#callback_stack}]";
		else
			set last_callback="$callback_stack[${#callback_stack}]";
			unset callback_stack[${#callback_stack}];
		endif
		unset callback;
	endif
	if( ${?debug} || ${?diagnostic_mode} )	\
		printf "handling callback to [%s].\n" "${last_callback}" > /dev/stdout;
	
	goto $last_callback;
#callback_handler:


diagnostic_mode:
	set current_label="diagnostic_mode";
	if( "${cwd}" != "${current_cwd}" ) then
		set current_cwd="${cwd}";
		set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	endif
	
	if( -e "/tmp/${scripts_basename}-debug.log" ) rm -v "/tmp/${scripts_basename}-debug.log";
	touch "/tmp/${scripts_basename}-debug.log";
	printf "----------------%s debug.log-----------------\n" "${scripts_basename}" >> "/tmp/${scripts_basename}-debug.log";
	printf \$"argv:\n\t%s\n\n" "$argv" >> "/tmp/${scripts_basename}-debug.log";
	printf \$"parsed_argv:\n\t%s\n\n" "$parsed_argv" >> "/tmp/${scripts_basename}-debug.log";
	printf \$"{0} == [%s]\n" "${0}" >> "/tmp/${scripts_basename}-debug.log";
	@ arg=0;
	while( "${1}" != "" )
		@ arg++;
		printf \$"{%d} == [%s]\n" $arg "${1}" >> "/tmp/${scripts_basename}-debug.log";
		shift;
	end
	printf "\n\n----------------<%s> environment-----------------\n" "${scripts_basename}" >> "/tmp/${scripts_basename}-debug.log";
	env >> "/tmp/${scripts_basename}-debug.log";
	printf "\n\n----------------<%s> variables-----------------\n" "${scripts_basename}" >> "/tmp/${scripts_basename}-debug.log";
	set >> "/tmp/${scripts_basename}-debug.log";
	printf "Create %s debug log:\n\t/tmp/%s-debug.log\n" "${scripts_basename}" "${scripts_basename}";
	@ errno=-500;
	set callback="sourcing_main_quit";
	goto exception_handler;
#diagnostic_mode:

