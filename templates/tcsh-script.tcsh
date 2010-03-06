#!/bin/tcsh -f
init:
	if(! ${?eol} ) then
		set eol='$';
		set eol_set;
	endif
	
	set script_name="tcsh-script.tcsh";
	
	if( `printf '%s' "${0}" | sed -r 's/^[^\.]*(csh)$/\1/'` == "csh" ) then
		# for exception handeling when this file is 'sourced'.
		
		# BEGIN: disabl source script_name.
		set status=-1;
		printf "%s does not support being sourced and can only be executed.\n" "${script_name}";
		goto usage;
		# END: disable source script_name.
		
		# BEGIN: source script_name support.
		if(! ${?TCSH_RC_SESSION_PATH} )	\
			setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
		source "${TCSH_RC_SESSION_PATH}/argv:check" "${script_name}" ${argv};
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
		# FINISH: special handler for when this file is sourced.
		
		source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${script_name}";
		# END: source script_name support.
	endif
	
	set argc=${#argv};
	if( ${argc} < 1 ) then
		set status=-1;
		goto usage;
	endif
	
	set old_owd="${cwd}";
	cd "`dirname '${0}'`";
	set script_path="${cwd}";
	cd "${owd}";
	set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	set owd="${old_owd}";
	unset old_owd;
	
	set script="${script_path}/${script_name}";
	
	alias	ex	"ex -E -n -X --noplugin";
	
	goto parse_argv; # exit's via 'usage:' or 'main:'.
#init:


main:
	set status=0;
	printf "Executing %s's main.\n" "${script_name}";
	goto exit_script;
#main:


exit_script:
	if( ${?debug} ) unset debug;
	if( ${?use_old_owd} ) then
		cd "${owd}";
		set owd="${use_old_owd}";
		unset use_old_owd;
	endif
	if( ${?eol_set} ) unset eol_set eol;
	exit ${status}
#exit_script:


usage:
	if( ${?debug} ) unset debug;
	if(! ${?usage_displayed} ) then
		printf "Usage:\n\t%s [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n" "${script_name}";
		set usage_displayed;
	endif
	if(! ${?no_exit_on_usage} ) then
		set status=-1;
		goto exit_script;
	endif
#usage:


parse_argv:
	@ argc=${#argv};
	
	if( ${argc} == 0 ) goto main;
	
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
	
	if( ${?debug} ) printf "Checking %s's argv options.  %d total.\n" "${script_name}" "${argc}";
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
						printf "enabling %s is not supported by %s.  See %s --help\n" "${value}" "${script_name}" "${script_name}";
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
						printf "disabling %s is not supported by %s.  See %s --help\n" "${value}" "${script_name}" "${script_name}";
						breaksw;
					endsw
				breaksw;
			
			case "":
				breaksw;
			
			default:
				printf "%s%s is an unsupported option.  See %s -h|--help for more information.\n" "${dashes}" "${option}" "${script_name}";
				breaksw;
		endsw
		unset dashes option equals value;
	end
	goto main;
#parse_arg:

