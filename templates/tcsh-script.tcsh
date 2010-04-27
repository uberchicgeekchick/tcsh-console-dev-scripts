#!/bin/tcsh -f
set label_current="init";
goto label_stack_set;
init:
	set label_current="init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	#if(! ${?noglob} ) then
	#	set noglob;
	#	set noglob_set;
	#endif
	
	set strict;
	set original_owd=${owd};
	set starting_dir=${cwd};
	set escaped_starting_dir=${escaped_cwd};
	
	set scripts_basename="tcsh-script.tcsh";
	set scripts_alias="`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	
	set usage_message="Usage: ${scripts_basename} [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.";
	
	#set escaped_starting_dir="`printf "\""%s"\"" "\""${cwd}"\"" | sed -r 's/\//\\\//g' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
	set escaped_home_dir="`printf "\""%s"\"" "\""${HOME}"\"" | sed -r 's/\//\\\//g' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
	#if(! -d "`printf "\""${escaped_home_dir}"\"" | sed -r 's/\\(\[)/\1/g' | sed -r 's/\\([*])/\1/g'`" ) then
	#	set home_files=();
	#else
	#	set home_files="`/bin/ls "\""${escaped_home_dir}"\""`";
	#endif
	
	if( "`alias cwdcmd`" != "" ) then
		set oldcwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	#set supports_being_source;
	#set argz="";
	#set scripts_supported_extensions="mp3|ogg|m4a";
	
	alias	ex	"ex -E -X -n --noplugin -s";
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias	"curl"	"${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --quiet --continue --output-document";
	#alias	"wget"	"${download_command_with_options}";
#init:


debug_check:
	set current_label="debug_check";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		set option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?"\$"/\2/'`";
		set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?"\$"/\4/'`";
		switch("${option}")
			case "diagnosis":
			case "diagnostic-mode":
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "debug":
				switch("${value}")
					case "logged":
						if( ${?logging} ) \
							breaksw;
						
						printf "**%s**, via "\$"argv[%d], debug logging:\t[enabled].\n\n" "${scripts_basename}" $arg;
						set logging;
						breaksw;
					
					default:
						if( ${?debug} ) \
							breaksw;
						
						printf "**%s**, via "\$"argv[%d], debug mode:\t[enabled].\n\n" "${scripts_basename}" $arg;
						set debug="${value}";
						breaksw;
				endsw
				breaksw;
			
			default:
				continue;
		endsw
	end
#debug_check:


check_dependencies:
	set label_current="check_dependencies";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set dependencies=("${scripts_basename}");# "${scripts_alias}");
	@ dependencies_index=0;
#check_dependencies:


check_dependencies:
	set label_current="check_dependencies";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	foreach dependency(${dependencies})
		@ dependencies_index++;
		unset dependencies[$dependencies_index];
		if( ${?debug} ) \
			printf "\n**%s debug:** looking for dependency: %s.\n\n" "${scripts_basename}" "${dependency}"; 
			
		foreach program("`where '${dependency}'`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			@ errno=-501;
			goto exception_handler;
		endif
		
		if( ${?debug} )	then
			switch( "`printf "\""%d"\"" "\""${dependencies_index}"\"" | sed -r 's/^[1]?[0-9]*([1-3])"\$"/\1/'`" )
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
			
			printf "**%s debug:** found %d%s dependency: %s.\n" "${scripts_basename}" $dependencies_index "${suffix}" "${dependency}";
			unset suffix;
		endif
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?scripts_dirname} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname '${program}'`";
				set scripts_dirname="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_dirname}/${scripts_basename}";
				if(! ${?TCSH_RC_SESSION_PATH} ) \
					setenv TCSH_RC_SESSION_PATH "${scripts_dirname}/../tcshrc";
				
				if(! ${?TCSH_LAUNCHER_PATH} ) \
					setenv TCSH_LAUNCHER_PATH \$"{TCSH_RC_SESSION_PATH}/../launchers";
				breaksw;
		endsw
		
		unset program;
	end
	
	unset dependency dependencies;
	
	goto parse_argv;
#check_dependencies:


if_sourced:
	set label_current="if_sourced";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?0} ) \
		goto main;
	
	# BEGIN: disable source scripts_basename.  For exception handeling when this file is 'sourced'.
	if(! ${?supports_being_source} ) then
		@ errno=-502;
		goto exception_handler;
	endif
	# END: disable source scripts_basename.
	
	# BEGIN: source scripts_basename support.
	source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
	
	# START: special handler for when this file is sourced.
	alias ${scripts_alias} \$"{TCSH_LAUNCHER_PATH}/${scripts_basename}";
	# FINISH: special handler for when this file is sourced.
#sourcing_main:


sourcing_main_quit:
	set label_current="sourcing_main_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
	# END: source scripts_basename support.
	
	goto script_main_quit;
#sourcing_main_quit:


main:
	set label_current="main";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ required_options=1;
	
	if( ${argc} < ${required_options} ) then
		@ errno=-504;
		set callback="parse_argv_quit";
		goto exception_handler;
	endif
#main:


exec:
	set label_current="exec";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?filename_list} ) then
		set file_count="`cat '${filename_list}'`";
		if(! ${#file_count} > 0 ) \
			goto usage;
		set callback="process_filename_list";
		goto callback_handler;
	endif
	
	if( ${?debug} ) \
		printf "Executing %s's main.\n" "${scripts_basename}";
	goto script_main_quit;
#exec:

process_filename_list:
	foreach filename("`cat '${filename_list}' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`")
		ex '+1d' '+wq!' "${filename_list}";
		set extension="`printf "\""${filename}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/g'`";
		set original_extension="${extension}";
		set filename="`printf "\""${filename}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\1/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		if(! -e "`printf "\""${filename}"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`.${extension}" ) \
			continue;
		
		set filename="`printf "\""${filename}"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
		
		/bin/ls "${filename}.${extension}";
		
		set callback="exec";
		goto callback_handler;
	end
#process_filename_list:


script_main_quit:
	set label_current="script_main_quit";
	if( "${label_current}" != "${label_previous}" )	 \
		goto label_stack_set;
	
	if( ${?label_current} )				 \
		unset label_current;
	if( ${?label_previous} )			 \
		unset label_previous;
	if( ${?labels_previous} )			 \
		unset labels_previous;
	if( ${?label_next} )				 \
		unset label_next;
	
	if( ${?arg} )					 \
		unset arg;
	if( ${?argc} )					 \
		unset argc;
	if( ${?argz} )					 \
		unset argz;
	if( ${?parsed_arg} )				 \
		unset parsed_arg;
	if( ${?parsed_argv} )				 \
		unset parsed_argv;
	if( ${?parsed_argc} )				 \
		unset parsed_argc;
	
	if( ${?noglob_set} ) \
		unset noglob noglob_set;
	
	if( ${?supports_being_source} )			 \
		unset supports_being_source;
	
	if( ${?script} )				 \
		unset script;
	if( ${?scripts_alias} )				 \
		unset scripts_alias;
	if( ${?scripts_basename} )			 \
		unset scripts_basename;
	if( ${?scripts_dirname} )			 \
		unset scripts_dirname;
	
	if( ${?dependency} )				 \
		unset dependency;
	if( ${?dependencies} )				 \
		unset dependencies;
	if( ${?missing_dependency} )			 \
		unset missing_dependency;
	
	if( ${?usage_displayed} )			 \
		unset usage_displayed;
	if( ${?no_exit_on_usage} )			 \
		unset no_exit_on_usage;
	if( ${?display_usage_on_error} )		 \
		unset display_usage_on_error;
	if( ${?last_exception_handled} )		 \
		unset last_exception_handled;
	
	if( ${?label_previous} )			 \
		unset label_previous;
	if( ${?label_next} )				 \
		unset label_next;
	
	if( ${?callback} )				 \
		unset callback;
	if( ${?last_callback} )				 \
		unset last_callback;
	if( ${?callback_stack} )			 \
		unset callback_stack;
	
	if( ${?argc_required} )				 \
		unset argc_required;
	if( ${?arg_shifted} ) 				 \
		unset arg_shifted;
	
	if( ${?escaped_cwd} )				 \
		unset escaped_cwd;
	if( ${?escaped_home_dir} )			 \
		unset escaped_home_dir;
	if( ${?escaped_starting_dir} )			 \
		unset escaped_starting_dir;
	
	if( ${?old_owd} )				 \
		unset old_owd;
	
	if( ${?starting_cwd} ) then
		if( "${starting_cwd}" != "${cwd}" )	 \
			cd "${starting_cwd}";
	endif
	
	if( ${?original_owd} ) then
		set owd="${original_owd}";
		unset original_owd;
	endif
	
	if( ${?oldcwdcmd} ) then
		alias cwdcmd "${oldcwdcmd}";
		unset oldcwdcmd;
	endif
	
	if( ${?scripts_supported_extensions} ) \
		unset scripts_supported_extensions;
	if( ${?filename_list} ) then
		if( ${?filename} ) \
			unset filename;
		if( ${?extension} ) \
			unset extension;
		if( ${?original_extension} ) \
			unset original_extension;
		if( ${?file_count} ) \
			unset file_count;
		
		if( -e "${filename_list}" ) \
			rm "${filename_list}";
		unset filename_list;
	endif
	
	if( ${?debug} )					 \
		unset debug;
	if( ${?scripts_diagnosis_log} ) \
		unset scripts_diagnosis_log;
	
	if( ${?strict} )				 \
		unset strict;
	
	if(! ${?errno} ) \
		@ errno=0;
	
	@ status=$errno;
	exit ${errno}
#script_main_quit:


usage:
	set label_current="usage";
	if( "${label_next}" != "${label_current}" ) \
		goto label_stack_set;
	
	if( ${?errno} ) then
		if( ${errno} != 0 ) then
			if(! ${?last_exception_handled} ) \
				set last_exception_handled=0;
			if( ${last_exception_handled} != ${errno} ) then
				if(! ${?callback} ) \
					set callback="usage";
				goto exception_handler;
			endif
		endif
	endif
	
	if(!( ${?script} && ${?program} )) then
		printf "${usage_message}\n";
	else
		if( "${program}" != "${script}" ) then
			${program} --help;
		else
			printf "${usage_message}\n";
		endif
	endif
	
	if(! ${?usage_displayed} ) \
		set usage_displayed;
	
	if(! ${?no_exit_on_usage} ) \
		goto script_main_quit;
	
	if(! ${?callback} )	 \
		set callback="parse_arg";
	goto callback_handler;
#usage:


exception_handler:
	set label_current="exception_handler";
	if( "${label_next}" != "${label_current}" ) \
		goto label_stack_set;
	
	if(! ${?errno} ) \
		@ errno=-599;
	printf "\n**%s error("\$"errno:%d):**\n\t" "${scripts_basename}" $errno;
	switch( $errno )
		case -500:
			printf "Debug mode has triggered an exception for diagnosis.  Please see any output above" "${scripts_basename}" > /dev/stderr;
			breaksw;
		
		case -501:
			printf "One or more required dependencies couldn't be found.\n\t[%s] couldn't be found.\n\t%s requires: %s" "${dependency}" "${scripts_basename}" "${dependencies}";
			breaksw;
		
		case -502:
			printf "Sourcing is not supported and may only be executed" > /dev/stderr;
			breaksw;
		
		case -503:
			printf "An internal script error has caused an exception.  Please see any output above" > /dev/stderr;
			if(! ${?debug} ) \
				printf " or run: %s%s --debug%s to find where %s failed" '`' "${scripts_basename}" '`' "${scripts_basename}" > /dev/stderr;
			breaksw;
		
		case -504:
			printf "One or more required options have not been provided" > /dev/stderr;
			breaksw;
		
		case -505:
			printf "%s%s is an unsupported option" "${dashes}" "${option}" > /dev/stderr;
			breaksw;
		
		case -599:
		default:
			printf "An unknown error, "\$"errno: %s, has occured" "${errno}" > /dev/stderr;
			breaksw;
	endsw
	set last_exception_handled=$errno;
	printf ".\n\tPlease see: %s%s --help%s for more information and supported options\n" '`' "${scripts_basename}" '`' > /dev/stderr;
	
	if( ${?display_usage_on_error} ) \
		goto usage;
	
	if( ${?callback} )		 \
		goto callback_handler;
	
	goto script_main_quit;
#exception_handler:

parse_argv:
	set label_current="parse_argv";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ arg=0;
	
	if( ${?debug} ) \
		printf "**%s debug:** checking argv.  %d total arguments.\n\n" "${scripts_basename}" "${argc}";
	
	@ arg=0;
	@ parsed_argc=0;
	@ argc=${#argv};
	if( ${?strict} ) \
		unset strict;
#parse_argv:

parse_arg:
	set label_current="parse_arg";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	while( $arg < $argc )
		if(! ${?arg_shifted} ) \
			@ arg++;
		
		if( ${?debug} )	 \
			printf "**%s debug:** Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
		
		if( -e "$argv[$arg]" ) then
			if(! ${?filename_list} ) then
				set filename_list="./.${scripts_basename}.filenames@`date '+%s'`";
				touch "${filename_list}";
			endif
			if(! -d "$argv[$arg]" ) then
				if( ${?debug} ) \
					printf "Handling %sargv[%d] adding file:\n\t<%s>\n\t\tto\n\t<%s>.\n" \$ $arg "$argv[$arg]" "${filename_list}";
				printf "%s\n" "$argv[$arg]" >> "${filename_list}";
			else
				if(! ${?scripts_supported_extensions} ) then
					if( ${?debug} ) \
						printf "Adding the contents of [%s] to [%s].\n" "$argv[$arg]" "${filename_list}";
					find -L "$argv[$arg]" -type f | sort >> "${filename_list}";
				else
					if( ${?debug} ) \
						printf "Adding any (%s) files found under [%s] to [%s].\n" "${scripts_supported_extensions}" "$argv[$arg]" "${filename_list}";
					find -L "$argv[$arg]" -type f -regextype posix-extended -iregex '.*\.(scripts_supported_extensions)$' | sort >> "${filename_list}";
				endif
			endif
			continue;
		endif
		
		set dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\2/'`";
		if( "${option}" == "$argv[$arg]" ) \
			set option="";
		
		set equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\3/'`";
		if( "${equals}" == "" ) \
			set equals="";
		
		set quotes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\4/'`";
		if( "${quotes}" == "" ) \
			set quotes="";
		
		#set equals="";
		set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\5/'`";
		#if( "${value}" != "" && "${value}" != "$argv[$arg]" ) then
		#	set equals="=";
		#else if( "${option}" != "" ) then
		if( "${option}" != "$argv[$arg]" && "${equals}" == "" && ( "${value}" == "" || "${value}" == "$argv[$arg]" ) ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else if( -e "$argv[$arg]" ) then
				@ arg--;
			else
				if( ${?debug} )	 \
					printf "**%s debug:** Looking for replacement value.  Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
				
				set test_dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\1/'`";
				set test_option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\2/'`";
				set test_equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\3/'`";
				set test_quotes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\4/'`";
				set test_value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)(['\''"\""]?)(.*)(['\''"\""]?)"\$"/\5/'`";
				
				if( ${?debug} ) \
					printf "\tparsed %sargv[%d] (%s) to test for replacement value.\n\tparsed %stest_dashes: [%s]; %stest_option: [%s]; %stest_equals: [%s]; %stest_quotes: [%s]; %stest_value: [%s]\n" \$ "${arg}" "$argv[$arg]" \$ "${test_dashes}" \$ "${test_option}" \$ "${test_equals}" \$ "${test_quotes}" \$ "${test_value}";
				
				if(!("${test_dashes}" == "$argv[$arg]" && "${test_option}" == "$argv[$arg]" && "${test_equals}" == "$argv[$arg]" && "${test_value}" == "$argv[$arg]")) then
					@ arg--;
				else
					set equals="=";
					set value="`printf "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
					set arg_shifted;
				endif
				unset test_dashes test_option test_equals test_value;
			endif
		endif
		
		#if( "`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/\1/"\""`" == "~" ) then
		#	set value="`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/${escaped_home_dir}\2/"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/['"\$"']/"\""\\'"\$"'"\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		#endif
		
		#if( "`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/\1/"\""`" == "." ) then
		#	set value="`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/${escaped_starting_dir}\2/"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/['"\$"']/"\""\\'"\$"'"\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		#endif
		
		#if( "`printf "\""${value}"\"" | sed -r "\""s/^(.*)(\*)/\2/"\""`" == "*" ) then
		#	set dir="`printf "\""${value}"\"" | sed -r "\""s/^(.*)\*'"\$"'/\2/"\""`";
		#	set value="`/bin/ls --width=1 "\""${dir}"\""*`";
		#endif
		
		@ parsed_argc++;
		set parsed_arg="${dashes}${option}${equals}${value}";
		if(! ${?parsed_argv} ) then
			set parsed_argv="${parsed_arg}";
		else
			set parsed_argv="${parsed_argv} ${parsed_arg}";
		endif
		
		if( ${?debug} ) \
			printf "\tparsed option %sparsed_argv[%d]: %s\n" \$ "$parsed_argc" "${parsed_arg}";
		
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
				if(! ${?be_verbose} ) \
					set be_verbose;
				breaksw;
			
			case "debug":
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "diagnosis":
			case "diagnostic-mode":
				if( ${?diagnostic_mode} ) \
					breaksw;
				
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "switch-option":
				switch("${value}")
					case "iv":
					case "verbose":
					case "interactive":
						set switch_option="${dashes}${value}";
						breaksw;
					
					default:
						set switch_option;
						breaksw;
				endsw
				
				if( ${?debug} ) \
					printf "**%s debug:**, via "\$"argv[%d], %s:\t[disabled].\n\n" "${scripts_basename}" $arg "${option}";
				breaksw;
			
			case "enable":
				switch("${value}")
					case "switch-option":
						if( ${?switch_option} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**%s debug:**, via "\$"argv[%d], %s mode:\t[%sd].\n\n" "${scripts_basename}" $arg "${value}" "${option}";
						set switch_option;
						breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], verbose output\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						set be_verbose;
						breaksw;
					
					case "debug":
						if( ${?debug} ) \
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], debug mode\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						set debug;
						breaksw;
					
					case "diagnosis":
					case "diagnostic-mode":
						if( ${?diagnostic_mode} ) \
							breaksw;
						
				
						printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						set diagnostic_mode;
						if(! ${?debug} ) \
							set debug;
						breaksw;
					
					default:
						printf "enabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_basename}" "${scripts_basename}";
						breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch("${value}")
					case "switch-option":
						if(! ${?switch_option} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**%s debug:**, via "\$"argv[%d], %s mode:\t[%sd].\n\n" "${scripts_basename}" $arg "${value}" "${option}";
						unset switch_option;
						breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], verbose output\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						unset be_verbose;
						breaksw;
					
					case "debug":
						if(! ${?debug} ) \
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], debug mode\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						unset debug;
						breaksw;
					
					case "diagnosis":
					case "diagnostic-mode":
						if(! ${?diagnostic_mode} ) \
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						unset diagnostic_mode;
						breaksw;
					
					default:
						printf "disabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_basename}" "${scripts_basename}";
						breaksw;
				endsw
				breaksw;
			
			default:
				if(! ${?strict} ) \
					breaksw;
				
				if(! ${?argz} ) then
					@ errno=-505;
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
#parse_arg:


parse_argv_quit:
	set label_current="parse_argv_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! ${?callback} ) then
		unset arg;
	else
		if( "${callback}" != "parse_arg" ) then
			unset arg;
		endif
	endif
	if( ${?diagnostic_mode} ) then
		set callback="diagnostic_mode";
	else if(! ${?callback} ) \
		set callback="if_sourced";
	endif
	
	goto callback_handler;
#parse_argv_quit:


label_stack_set:
	if( ${?current_cwd} ) then
		if( ${current_cwd} != ${cwd} ) \
			cd ${current_cwd};
		unset current_cwd;
	endif
	
	if( ${?old_owd} ) then
		if( ${old_owd} != ${owd} ) then
			set owd=${old_owd};
		endif
	endif
	
	set old_owd="${owd}";
	set current_cwd="${cwd}";
	set escaped_cwd="`printf "\""%s"\"" "\""${cwd}"\"" | sed -r 's/\//\\\//g' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/([\[])/\\\1/g'`";
	#if(! -d "`printf "\""${escaped_cwd}"\"" | sed -r 's/\\([*])/\1/g' | sed -r 's/\\([\[])/\1/g'`" ) then
	#	set cwd_files=();
	#else
	#	set cwd_files="`/bin/ls "\""${escaped_cwd}"\""`";
	#endif
	
	set label_next=${label_current};
	
	if(! ${?labels_previous} ) then
		set labels_previous=("${label_current}");
		set label_previous="$labels_previous[${#labels_previous}]";
	else
		if("${label_current}" != "$labels_previous[${#labels_previous}]" ) then
			set labels_previous=($labels_previous "${label_current}");
			set label_previous="$labels_previous[${#labels_previous}]";
		else
			set label_previous="$labels_previous[${#labels_previous}]";
			unset labels_previous[${#labels_previous}];
		endif
	endif
	
	#set label_previous=${label_current};
	
	set callback=${label_previous};
	
	if( ${?debug} ) \
		printf "handling label_current: [%s]; label_previous: [%s].\n" "${label_current}" "${label_previous}" > /dev/stdout;
	
	#unset label_previous;
	#unset label_current;
	
	goto callback_handler;
#label_stack_set:


callback_handler:
	if(! ${?callback} ) \
		goto script_main_quit;
	
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
	if( ${?debug} ) \
		printf "handling callback to [%s].\n" "${last_callback}" > /dev/stdout;
	
	goto $last_callback;
#callback_handler:


diagnostic_mode:
	set label_current="diagnostic_mode";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! -d "${HOME}/tmp" ) then
		set scripts_diagnosis_log="/tmp/${scripts_basename}.diagnosis.log";
	else
		set scripts_diagnosis_log="${HOME}/tmp/${scripts_basename}.diagnosis.log";
	endif
	
	touch "${scripts_diagnosis_log}";
	printf "[%s] diagnosis log: <file://%s> created at: [%s]\n\n" "${scripts_basename}" "${scripts_diagnosis_log}" `date "+%I:%M:%S%P"` >> "${scripts_diagnosis_log}";
	printf \$"{0}:\t[%s]\n" "${0}" >> "${scripts_diagnosis_log}";
	printf "---------------- %s "\$"argv shift values: -----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	@ arg=0;
	while( "${1}" != "" )
		@ arg++;
		printf \$"{1} ("\$"argv[%d]):\t[%s]\n" $arg "${1}" >> "${scripts_diagnosis_log}";
		shift;
	end
	printf "---------------- %s "\$"argv: -----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	printf "\t%s\n\n" "$argv" >> "${scripts_diagnosis_log}";
	printf "---------------- %s "\$"parsed_argv: -----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	printf "\t%s\n\n" "$parsed_argv" >> "${scripts_diagnosis_log}";
	printf "\n\n---------------- <%s> environment: -----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	env >> "${scripts_diagnosis_log}";
	printf "\n\n---------------- <%s> variables: -----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	set >> "${scripts_diagnosis_log}";
	printf "[%s] diagnosis log: <file://%s> created at: [%s]\n\t%s\n" "${scripts_basename}" `date "+%I:%M:%S%P"` "${scripts_diagnosis_log}";
	@ errno=-500;
	if(! ${?0} ) then
		set callback="script_main_quit";
	else
		set callback="sourcing_main_quit";
	endif
	goto exception_handler;
#diagnostic_mode:

