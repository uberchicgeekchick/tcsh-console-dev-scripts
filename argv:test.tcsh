#!/bin/tcsh -f
init:
	if(! ${?eol} ) then
		set eol='$';
		set eol_set;
	endif
	set supports_being_source;
	set scripts_name="tcsh-script.tcsh";
#init:


check_dependencies:
	set dependencies=("${scripts_name}");
	
	foreach dependency(${dependencies})
		foreach dependency("`where '${dependency}'`")
			if(! -x "${dependency}" ) continue;
			
			switch("${dependency}")
				case "${scripts_name}":
				case "./${dependency}":
				case "${TCSH_LAUNCHER_PATH}/${dependency}":
					continue;
					breaksw;
			endsw
			break;
		end
		
		if(! ${?program} )	\
			set program="${dependency}";
		
		if(!( -x ${dependency} && -x ${program} )) then
			set errno=-501;
			goto exception_handler;
		endif
		
		unset dependency;
	end
	
	unset dependency dependencies;
#check_dependencies:


if_sourced:
	if( `printf '%s' "${0}" | sed -r 's/^[^\.]*(csh)$/\1/'` != "csh" )	\
		goto main;
	
	# for exception handeling when this file is 'sourced'.
	
	# BEGIN: disable source scripts_name.
	if(! ${?supports_being_source} ) then
		set errno=-502;
		goto exception_handler;
	endif
	# END: disable source scripts_name.
	
	# BEGIN: source scripts_name support.
	if(! ${?TCSH_RC_SESSION_PATH} )	\
		setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
	
	if(! ${?TCSH_LAUNCHER_PATH} )	\
		setenv TCSH_LAUNCHER_PATH \$"{TCSH_RC_SESSION_PATH}/../launchers";
	
	source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_name}" ${argv};
	if( $args_handled > 0 ) then
		@ args_shifted=0;
		while( $args_shifted < $args_handled )
			@ args_shifted++;
			shift;
		end
		unset args_shifted;
	endif
	unset args_handled;
	
	# START: special handler for when this file is sourced.
	alias ${scripts_name} \$"{TCSH_LAUNCHER_PATH}/${scripts_name}";
	# FINISH: special handler for when this file is sourced.
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_name}";
	
	# END: source scripts_name support.
	
	goto script_main_quit;
#if_sourced:


main:
	set argc=${#argv};
	if( ${argc} < 1 ) then
		set errno=-503;
		goto exception_handler;
	endif
	
	set old_owd="${cwd}";
	cd "`dirname '${0}'`";
	set scripts_path="${cwd}";
	cd "${owd}";
	set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	set owd="${old_owd}";
	unset old_owd;
	
	set script="${scripts_path}/${scripts_name}";
	
	alias	ex	"ex -E -n -X --noplugin";
	
	goto parse_argv; # exit's via 'usage:' or 'main:'.
#main:


exec:
	set errno=0;
	printf "Executing %s's main.\n" "${scripts_name}";
	goto script_main_quit;
#exec:


script_main_quit:
	if( ${?scripts_name} )	\
		unset scripts_name;
	if( ${?scripts_path} )	\
		unset scripts_path;
	if( ${?script} )	\
		unset script;
	if( ${?argz} )	\
		unset argz;
	if( ${?debug} )	\
		unset debug;
	if( ${?eol_set} )	\
		unset eol_set eol;
	if( ${?escaped_cwd} )	\
		unset escaped_cwd;
	if( ${?dependency} )	\
		unset dependency;
	if( ${?dependencies} )	\
		unset dependencies;
	if( ${?usage_displayed} )	\
		unset usage_displayed;
	if( ${?no_exit_on_usage} )	\
		unset no_exit_on_usage;
	if( ${?callback} )	\
		unset callback;
	if( ${?last_callback} )	\
		unset last_callback;
	
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
#script_main_quit:


usage:
	if( ${?errno} ) then
		if( ${errno} != 0 ) then
			if(! ${?callback} )	\
				set callback="usage";
				goto exception_handler;
			endif
		endif
	endif
	
	if(! ${?script} ) then
		printf "Usage:\n\t%s [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n" "${scripts_name}";
	else if( "${program}" != "${script}" ) then
		${program} --help;
	endif
	
	if(! ${?usage_displayed} )	\
		set usage_displayed;
	
	if( ${?callback} ) then
		set last_callback=$callback;
		unset callback;
		goto $last_callback;
	endif
	
	if(! ${?no_exit_on_usage} )	\
		goto script_main_quit;
	
	goto parse_arg;
#usage:


exception_handler:
	if(! ${?errno} )	\
		set errno=-599;
	printf "\n**%s error("\$"errno:%d):**\n\t" "${scripts_name}"  $errno;
	switch( $errno )
		case -501:
			printf "Sourcing is not supported and may only be executed" > /dev/stderr;
			breaksw;
		
		case -502:
			printf "One or more required dependencies couldn't be found.\n\n[%s] couldn't be found.\n\n%s requires: %s" "${dependency}" "${scripts_name}" "${dependencies}";
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided" "${dashes}" "${option}" '`' "${scripts_name}" '`' > /dev/stderr;
			breaksw;
		
		case -504:
			printf "%s%s is an unsupported option.\n\tRun %s%s --help%s for supported options and details" "${dashes}" "${option}" '`' "${scripts_name}" '`' > /dev/stderr;
			breaksw;
		
		case -599:
		default:
			printf "An unknown error "\$"errno: %s has occured" "${errno}" > /dev/stderr;
			breaksw;
	endsw
	printf "\n" > /dev/stderr;
	
	if( ${?callback} ) then
		set last_callback=$callback;
		unset callback;
		goto $last_callback;
	endif
	
	if(! ${?exit_on_error} )	\
		goto usage;
	
	goto script_main_quit;
#exception_handler:


default_callback:
	printf "handling callback to [%s].\n", "${last_callback}";
	unset last_callback;
	goto script_main_quit;
#default_callback:


parse_argv:
	@ argc=${#argv};
	
	if( ${argc} == 0 )	\
		goto exec;
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		if( "$argv[$arg]" != "--debug" ) continue;
		printf "Enabling debug mode; via "\$"argv[%d].\n" $arg;
		set argv[$my_arg]="";
		set debug;
		break;
	end
	if( ! ${?debug} || $arg > 1 )	\
		@ arg=0;
	
	if( ${?debug} )	\
		printf "Checking %s's argv options.  %d total.\n" "${scripts_name}" "${argc}";
#parse_argv:

parse_arg:
	while( $arg < $argc )
		@ arg++;
		
		set equals="";
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?${eol}/\3/'`";
		if( "${value}" == "$argv[$arg]" ) then
			set value="";
		else
			set equals="=";
		endif
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?${eol}/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?${eol}/\2/'`";
		if( "${option}" == "$argv[$arg]" ) set option="";
		
		if( ${?debug} )		\
			printf "Checking argv #%d (%s).\n\tParsed option: %s%s%s%s\n" "${arg}" "$argv[$arg]" "${dashes}" "${option}" "${equals}" "${value}";
		
		switch("${option}")
			case "numbered_option":
				if(! ( "${value}" != "" && "${value}" != "$argv[$arg]" && ${value} > 0 )) then
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
			
			case "enable":
				switch("${value}")
					case "verbose":
						if(! ${?be_verbose} ) set be_verbose;
						breaksw;
					
					case "debug":
						if(! ${?debug} ) set debug;
						breaksw;
					
					default:
						printf "enabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_name}" "${scripts_name}";
						breaksw;
					endsw
				
				breaksw;
			
			case "disable":
				switch("${value}")
					case "verbose":
						if( ${?be_verbose} ) unset be_verbose;
						breaksw;
					
					case "debug":
						if( ${?debug} ) unset debug;
						breaksw;
					
					default:
						printf "disabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_name}" "${scripts_name}";
						breaksw;
					endsw
				breaksw;
			
			case "":
				breaksw;
			
			default:
				if(! ${?argz} ) then
					set errno=-504;
					set callback="parse_arg";
					goto exception_handler;
					breaksw;
				endif
				
				if( "${argz}" == "" ) then
					set argz="$argv[$arg]";
				else
					set argz="${argz} $argv[$arg]";
				endif
				breaksw;
		endsw
		unset dashes option equals value;
	end
	unset arg argc;
	goto exec;
#parse_arg:

