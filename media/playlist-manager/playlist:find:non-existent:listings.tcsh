#!/bin/tcsh -f
set label_current="init";
goto label_stack_set;
init:
	set label_current="init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	onintr exit_script;
	
	set strict;
	set original_owd=${owd};
	set starting_dir=${cwd};
	set escaped_starting_dir=${escaped_cwd};
	
	if(! $?0 ) \
		set being_sourced;
	
	set scripts_basename="playlist:find:non-existent:listings.tcsh";
	set script_alias="`printf '%s' '${scripts_basename}' | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	
	set escaped_home_dir="`printf "\""%s"\"" "\""${HOME}"\"" | sed -r 's/\//\\\//g' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
	
	if( "`alias cwdcmd`" != "" ) then
		set oldcwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	@ errno=0;
	
	#set supports_being_source;
	#set argz="";
	#set script_supported_extensions="mp3|ogg|m4a";
	
	alias	ex	"ex -E -X -n --noplugin";
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias	"curl"	"${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --quiet --continue --output-document";
	#alias	"wget"	"${download_command_with_options}";
#init:

dependencies_check:
	set label_current="dependencies_check";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set dependencies=("${scripts_basename}" "playlist:new:create.tcsh" "playlist:new:save.tcsh");# "${script_alias}");
	@ dependencies_index=0;
#dependencies_check:


dependency_check:
	set label_current="dependency_check";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		set dependency=$dependencies[$dependencies_index];
		foreach dependency("`where '${dependency}'`")
			if( ${?debug} ) \
				printf "\n**%s debug:** looking for dependency: %s.\n\n" "${scripts_basename}" "${dependency}"; 
			
			if(! -x "${dependency}" ) \
				continue;
			
			if(! ${?script_dirname} ) then
				if("`basename '${dependency}'`" == "${scripts_basename}" ) then
					set old_owd="${cwd}";
					cd "`dirname '${dependency}'`";
					set script_dirname="${cwd}";
					cd "${owd}";
					set owd="${old_owd}";
					unset old_owd;
					set script="${script_dirname}/${scripts_basename}";
					if(! ${?TCSH_RC_SESSION_PATH} ) \
						setenv TCSH_RC_SESSION_PATH "${script_dirname}/../tcshrc";
					
					if(! ${?TCSH_LAUNCHER_PATH} ) \
						setenv TCSH_LAUNCHER_PATH \$"{TCSH_RC_SESSION_PATH}/../launchers";
				endif
			endif
			
			if( ${?debug} )	then
				switch( "`printf '%s' '${dependencies_index}' | sed -r 's/.*([1-3])"\$"/\1/'`" )
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
		
		if(! ${?program} ) \
			set program="${script}";
		
		if(!( ${?dependency} && ${?script} && ${?program} )) then
			set missing_dependency;
		else
			if(!( -x ${script} && -x ${dependency} && -x ${program} )) \
				set missing_dependency;
		endif
		
		if( ${?missing_dependency} ) then
			@ errno=-501;
			goto exception_handler;
		endif
		
		unset program;
	end
#dependency_check:


dependencies_found:
	set label_current="dependencies_found";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	unset dependency dependencies dependencies_index;
	
	set callback="parse_argv";
	goto callback_handler;
#dependencies_found:
	


if_sourced:
	set label_current="if_sourced";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! ${?being_sourced} ) \
		goto main;
	
	if(! ${?supports_being_source} ) \
		goto sourcing_disabled;
	
	goto sourcing_init;
#if_sourced:


sourcing_disabled:
	set label_current="sourcing_disabled";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	# BEGIN: disable source scripts_basename.  For exception handeling when this file is 'sourced'.
	@ errno=-502;
	goto exception_handler;
	# END: disable source scripts_basename.
#sourcing_disabled:


sourcing_init:
	set label_current="sourcing_init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	# BEGIN: source scripts_basename support.
	source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
#sourcing_init:


sourcing_main:
	set label_current="sourcing_main";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	# START: special handler for when this file is sourced.
	alias ${script_alias} \$"{TCSH_LAUNCHER_PATH}/${scripts_basename}";
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
	
	if( ${?debug} ) \
		printf "Executing %s's main.\n" "${scripts_basename}";
	
	if(! ${?playlist} ) then
		@ errno=-506;
		goto exception_handler;
	endif
	
	if(! -e "${playlist}" ) then
		@ errno=-506;
		goto exception_handler;
	endif
	
	if( ${?edit_playlist} ) \
		${EDITOR} "${playlist}";
	
	if(! ${?playlist_type} ) then
		set callback="setup_playlist";
		goto callback_handler;
	endif
#main:


exec:
	set label_current="exec";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?debug} ) \
		printf "Executing %s's exec.\n" "${scripts_basename}";
	
	if( ${?filename_list} ) then
		if( ${?filename} ) then
			if( -e "${filename}.${extension}" ) then
				if( ${?clean_up} ) then
					printf "%s\n" "${filename}.${extension}" >> "${playlist}.new";
				endif
			else
				if(! ${?dead_file_count} ) then
					if( ${?clean_up} ) \
						printf "\n**${scripts_basename} notice:** These files will be removed from [${playlist}]:\n";
					@ dead_file_count=1;
				else
					@ dead_file_count++;
				endif
				printf "${filename}.${extension}\n";
			endif
		endif
		set callback="process_filename_list";
		goto callback_handler;
	endif
	if( ${?clean_up} ) \
		goto format_new_playlist;
	goto script_main_quit;
#exec:

process_filename_list:
	foreach filename("`cat '${filename_list}' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`")
		ex -s '+1d' '+wq!' "${filename_list}";
		set extension="`printf "\""${filename}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/g'`";
		set original_extension="${extension}";
		set filename="`printf "\""${filename}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\1/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		set filename="`printf "\""${filename}"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
		set callback="exec";
		goto callback_handler;
	end
	rm "${filename_list}";
	unset filename filename_list;
#process_filename_list:

format_new_playlist:
	if(! ${?clean_up} ) then
		set callback="script_main_quit";
		goto callback_handler;
	endif
	
	if(! -e "${playlist}.new" ) then
		set callback="script_main_quit";
		goto callback_handler;
	endif
	
	if(! ${?dead_file_count} ) then
		rm "${playlist}.new";
		set callback="script_main_quit";
		goto callback_handler;
	endif
	
	playlist:new:save.tcsh --force "${playlist}";
#format_new_playlist:

script_main_quit:
	set label_current="script_main_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?label_current} ) \
		unset label_current;
	if( ${?label_previous} ) \
		unset label_previous;
	if( ${?labels_previous} ) \
		unset labels_previous;
	if( ${?label_next} ) \
		unset label_next;
	
	if( ${?argc} ) \
		unset argc;
	if( ${?argz} ) \
		unset argz;
	if( ${?parsed_arg} ) \
		unset parsed_arg;
	if( ${?parsed_argv} ) \
		unset parsed_argv;
	if( ${?parsed_argc} ) \
		unset parsed_argc;
	
	if( ${?being_sourced} ) \
		unset being_sourced;
	if( ${?supports_being_source} ) \
		unset supports_being_source;
	
	if( ${?script} ) \
		unset script;
	if( ${?script_alias} ) \
		unset script_alias;
	if( ${?scripts_basename} ) \
		unset scripts_basename;
	if( ${?script_dirname} ) \
		unset script_dirname;
	
	if( ${?dependency} ) \
		unset dependency;
	if( ${?dependencies} ) \
		unset dependencies;
	if( ${?missing_dependency} ) \
		unset missing_dependency;
	
	if( ${?usage_displayed} ) \
		unset usage_displayed;
	if( ${?no_exit_on_usage} ) \
		unset no_exit_on_usage;
	if( ${?display_usage_on_error} ) \
		unset display_usage_on_error;
	if( ${?last_exception_handled} ) \
		unset last_exception_handled;
	
	if( ${?label_previous} ) \
		unset label_previous;
	if( ${?label_next} ) \
		unset label_next;
	
	if( ${?callback} ) \
		unset callback;
	if( ${?last_callback} ) \
		unset last_callback;
	if( ${?callback_stack} ) \
		unset callback_stack;
	
	if( ${?argc_required} ) \
		unset argc_required;
	if( ${?arg_shifted} ) \
		unset arg_shifted;
	
	if( ${?escaped_cwd} ) \
		unset escaped_cwd;
	if( ${?escaped_home_dir} ) \
		unset escaped_home_dir;
	if( ${?escaped_starting_dir} ) \
		unset escaped_starting_dir;
	
	if( ${?old_owd} ) \
		unset old_owd;
	
	if( ${?starting_cwd} ) then
		if( "${starting_cwd}" != "${cwd}" ) \
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
	
	if( ${?script_supported_extensions} ) \
		unset script_supported_extensions;
	if( ${?filename_list} ) then
		if( ${?filename} ) \
			unset filename;
		if( ${?extension} ) \
			unset extension;
		if( ${?original_extension} ) \
			unset original_extension;
		
		if( -e "${filename_list}" ) \
			rm "${filename_list}";
		unset filename_list;
	endif
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if( ${?debug} ) \
		unset debug;
	if( ${?script_diagnosis_log} ) \
		unset script_diagnosis_log;
	
	if( ${?strict} ) \
		unset strict;
	
	if(! ${?errno} ) then
		set status=0;
	else
		set status=$errno;
		unset errno;
	endif
	exit ${status}
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
	
	if(! ${?script} ) then
		printf "Usage:\n\t%s [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n" "${scripts_basename}";
	else if( "${program}" != "${script}" ) then
		${program} --help;
	endif
	
	if(! ${?usage_displayed} ) \
		set usage_displayed;
	
	if(! ${?no_exit_on_usage} ) \
		goto script_main_quit;
	
	if(! ${?callback} ) \
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
			printf "Debug mode has triggered an exception for diagnosis.  Please see any output above.\n" "${scripts_basename}" > /dev/stderr;
			@ errno=0;
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
			printf ".\n" > /dev/stderr;
			breaksw;
		
		case -504:
			printf "One or more required options have not been provided." > /dev/stderr;
			breaksw;
		
		case -505:
			printf "%s%s is an unsupported option.\n\tPlease see: %s%s --help%s for supported options and details" "${dashes}" "${option}" '`' "${scripts_basename}" '`' > /dev/stderr;
			breaksw;
		
		case -506:
			printf "<file://%s> does not exist.\nA valid and existing playlist must be specified.\n\tPlease see: %s%s --help%s for supported options and details" "${playlist}" '`' "${scripts_basename}" '`' > /dev/stderr;
			unset playlist;
			breaksw;
		
		case -599:
		default:
			printf "An unknown error "\$"errno: %s has occured" "${errno}" > /dev/stderr;
			breaksw;
	endsw
	set last_exception_handled=$errno;
	printf "\nrun: %s%s --help%s for more information\n" '`' "${scripts_basename}" '`' > /dev/stderr;
	
	if( ${?display_usage_on_error} ) \
		goto usage;
	
	if( ${?callback} ) \
		goto callback_handler;
	
	goto script_main_quit;
#exception_handler:

parse_argv:
	set label_current="parse_argv";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ argc=${#argv};
	@ required_options=0;
	
	if( ${argc} < ${required_options} ) then
		@ errno=-504;
		set callback="parse_argv_quit";
		goto exception_handler;
	endif
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--diagnosis":
			case "--diagnostic-mode":
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				break;
			
			case "--debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set debug;
				break;
			
			default:
				continue;
		endsw
	end
	
	if( ${?debug} ) \
		printf "**%s debug:** checking argv.  %d total arguments.\n\n" "${scripts_basename}" "${argc}";
	
	@ arg=0;
	@ parsed_argc=0;
	unset strict;
#parse_argv:

parse_arg:
	set label_current="parse_arg";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	while( $arg < $argc )
		if(! ${?arg_shifted} ) \
			@ arg++;
		
		if( ${?debug} ) \
			printf "**%s debug:** Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
		
		set dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
		if( "${option}" == "$argv[$arg]" ) \
			set option="";
		
		set equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
		if( "${equals}" == "$argv[$arg]" ) \
			set equals="";
		
		set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
		if( "${option}" != "$argv[$arg]" && "${equals}" == "" && ( "${value}" == "" || "${value}" == "$argv[$arg]" ) ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				if( ${?debug} ) \
					printf "**%s debug:** Looking for replacement value.  Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
				
				set test_dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
				if( "${test_dashes}" == "$argv[$arg]" ) \
					set test_dashes="";
				
				set test_option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
				if( "${test_option}" == "$argv[$arg]" ) \
					set test_option="";
				
				set test_equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
				if( "${test_equals}" == "$argv[$arg]" ) \
					set test_equals="";
				
				set test_value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
				
				if( ${?debug} ) \
					printf "\tparsed %sargv[%d] (%s) to test for replacement value.\n\tparsed %stest_dashes: [%s]; %stest_option: [%s]; %stest_equals: [%s]; %stest_value: [%s]\n" \$ "${arg}" "$argv[$arg]" \$ "${test_dashes}" \$ "${test_option}" \$ "${test_equals}" \$ "${test_value}";
				
				if( "${test_dashes}" != "" && "${test_option}" != "" && ( "${test_value}" == "" || "${test_value}" == "$argv[$arg]" ) ) then
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
			
			case "edit-playlist":
				if(! ${?edit_playlist} ) \
					set edit_playlist;
				breaksw;
			
			case "h":
			case "help":
				goto usage;
				breaksw;
			
			case "verbose":
				if(! ${?be_verbose} ) \
					set be_verbose;
				breaksw;
			
			case "playlist":
				set playlist="${value}";
				if(! -e "${value}" ) then
					@ errno=-506;
					set callback="parse_arg";
					goto exception_handler;
					breaksw;
				endif
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
			
			case "clean-up":
				set clean_up;
				
				if( ${?debug} ) \
					printf "**%s debug:**, via "\$"argv[%d], %s:\t[enabled].\n\n" "${scripts_basename}" $arg "${option}";
				breaksw;
			
			case "enable":
				switch("${value}")
					case "clean-up":
						if( ${?clean_up} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**%s debug:**, via "\$"argv[%d], clean-up mode:\t[%sed].\n\n" "${scripts_basename}" $arg "${option}";
						set clean_up;
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
					case "clean-up":
						if(! ${?clean_up} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**%s debug:**, via "\$"argv[%d], clean-up mode:\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						unset clean_up;
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
				if( -e "${value}" && ! ${?playlist} ) then
					set playlist="${value}";
					breaksw;
				endif
				
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
		unset arg argc;
	else
		if( "${callback}" != "parse_arg" ) then
			unset arg;
		endif
	endif
	if( ${?diagnostic_mode} ) then
		set callback="diagnostic_mode";
	else
		if(! ${?being_sourced} ) then
			set callback="main";
		else
			set callback="sourcing_main";
		endif
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

setup_playlist:
	set label_current="setup_playlist";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! ${?playlist} ) then
		@ errno=-506;
		goto exception_handler;
	endif
	
	playlist:new:create.tcsh "${playlist}";
	if(! ${?filename_list} ) \
		set filename_list="`mktemp --tmpdir filenames.${scripts_basename}.XXXXXX`";
	mv -f "${playlist}.swp" "${filename_list}";
	set callback="exec";
	goto callback_handler;
#setup_playlist:


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
		set script_diagnosis_log="/tmp/${scripts_basename}.diagnosis.log";
	else
		set script_diagnosis_log="${HOME}/tmp/${scripts_basename}.diagnosis.log";
	endif
	if( -e "${script_diagnosis_log}" ) \
		rm -v "${script_diagnosis_log}";
	touch "${script_diagnosis_log}";
	printf "----------------%s debug.log-----------------\n" "${scripts_basename}" >> "${script_diagnosis_log}";
	printf \$"argv:\n\t%s\n\n" "$argv" >> "${script_diagnosis_log}";
	printf \$"parsed_argv:\n\t%s\n\n" "$parsed_argv" >> "${script_diagnosis_log}";
	printf \$"{0} == [%s]\n" "${0}" >> "${script_diagnosis_log}";
	@ arg=0;
	while( "${1}" != "" )
		@ arg++;
		printf \$"{%d} == [%s]\n" $arg "${1}" >> "${script_diagnosis_log}";
		shift;
	end
	printf "\n\n----------------<%s> environment-----------------\n" "${scripts_basename}" >> "${script_diagnosis_log}";
	env >> "${script_diagnosis_log}";
	printf "\n\n----------------<%s> variables-----------------\n" "${scripts_basename}" >> "${script_diagnosis_log}";
	set >> "${script_diagnosis_log}";
	printf "Create %s diagnosis log:\n\t%s\n" "${scripts_basename}" "${script_diagnosis_log}";
	@ errno=-500;
	if(! ${?being_sourced} ) then
		set callback="script_main_quit";
	else
		set callback="sourcing_main_quit";
	endif
	goto exception_handler;
#diagnostic_mode:

